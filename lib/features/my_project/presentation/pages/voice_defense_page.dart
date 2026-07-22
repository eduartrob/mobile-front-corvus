import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/core/network/api_config.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import '../provider/my_project_provider.dart';

class DefenseMessage {
  final String sender; // 'sinodal' | 'student'
  final String text;
  final DateTime timestamp;
  final String type; // 'voice' | 'text'

  DefenseMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
    this.type = 'voice',
  });
}

class VoiceDefensePage extends StatefulWidget {
  final String teamId;
  final String studentName;
  final String proposalSummary;
  final String sessionId;

  const VoiceDefensePage({
    super.key,
    required this.teamId,
    required this.studentName,
    required this.proposalSummary,
    required this.sessionId,
  });

  @override
  State<VoiceDefensePage> createState() => _VoiceDefensePageState();
}

class _VoiceDefensePageState extends State<VoiceDefensePage> {
  WebSocketChannel? _channel;
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  bool _isConnected = false;
  bool _isListening = false;
  bool _isAISpeaking = false;
  bool _sttAvailable = false;
  bool _isLoadingVerdict = false;
  bool _isSendingAnswer = false;
  bool _showTextInput = false;
  String? _lastSentAnswer;
  DateTime? _lastSentTime;
  
  final List<DefenseMessage> _messages = [];
  String _liveSpokenText = '';
  String _previousTypedText = '';

  @override
  void initState() {
    super.initState();
    _initAudioAndStt();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<MyProjectProvider>();
      await provider.loadVoiceSessionFromPrefs();
      if (provider.activeVoiceMessages.isNotEmpty) {
        if (mounted) {
          setState(() {
            _messages.clear();
            for (var m in provider.activeVoiceMessages) {
              _messages.add(DefenseMessage(
                sender: m['sender'] ?? 'sinodal',
                text: m['text'] ?? '',
                timestamp: m['timestamp'] != null 
                    ? DateTime.parse(m['timestamp']) 
                    : DateTime.now(),
                type: m['type'] ?? 'voice',
              ));
            }
          });
          _scrollToBottom();
        }
      }
      _connectWebSocket();
    });
  }

  void _saveCurrentVoiceState({Map<String, dynamic>? verdictReport}) {
    if (!mounted) return;
    try {
      final provider = context.read<MyProjectProvider>();
      final List<Map<String, dynamic>> serialized = _messages.map((m) => {
        'sender': m.sender,
        'text': m.text,
        'timestamp': m.timestamp.toIso8601String(),
        'type': m.type,
      }).toList();
      provider.saveActiveVoiceSession(serialized, verdictReport: verdictReport);
    } catch (_) {}
  }

  void _onTypedTextChanged(String newText) {
    final diff = newText.length - _previousTypedText.length;
    if (diff > 15) {
      _textController.text = _previousTypedText;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _previousTypedText.length),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Por integridad académica, no se permite pegar texto ni usar dictado por voz del teclado. Redacta a mano.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }
    _previousTypedText = newText;
  }

  Future<void> _initAudioAndStt() async {
    try {
      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() => _isAISpeaking = false);
        }
      });

      _sttAvailable = await _speechToText.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted && (_isListening || _liveSpokenText.isNotEmpty)) {
              _stopListeningAndSend();
            }
          }
        },
        onError: (error) {
          debugPrint("STT error: $error");
          if (mounted) setState(() => _isListening = false);
        },
      );
    } catch (e) {
      debugPrint("Error inicializando audio/voz: $e");
    }
  }

  Future<void> _connectWebSocket() async {
    final token = context.read<AuthProvider>().currentUser?.token;
    
    final gatewayHost = Uri.parse(ApiConfig.apiGatewayUrl).host;
    final wsScheme = ApiConfig.apiGatewayUrl.startsWith('https') ? 'wss' : 'ws';
    final wsPort = wsScheme == 'wss' ? 443 : 80;
    final wsPath = '/api/v1/llm/ws/defense-live/${widget.sessionId}';
    final uri = Uri(
      scheme: wsScheme,
      host: gatewayHost,
      port: wsPort,
      path: wsPath,
      queryParameters: {'token': token},
    );
    
    _channel = WebSocketChannel.connect(uri);

    final authProvider = context.read<AuthProvider>();
    final email = authProvider.currentUser?.email;

    _channel!.stream.listen(
      (message) {
        if (message is String) {
          try {
            final data = jsonDecode(message);
            if (data['type'] == 'ready') {
              if (mounted) {
                setState(() => _isConnected = true);
              }
            } else if (data['type'] == 'text') {
              final text = data['text'] as String?;
              if (text != null && text.isNotEmpty) {
                if (mounted) {
                  setState(() {
                    _isAISpeaking = true;
                    _isSendingAnswer = false;
                    _messages.add(DefenseMessage(
                      sender: 'sinodal',
                      text: text,
                      timestamp: DateTime.now(),
                      type: 'voice',
                    ));
                  });
                  _scrollToBottom();
                  _saveCurrentVoiceState();
                }
                _speechToText.stop();
              }
            } else if (data['type'] == 'verdict_report') {
              if (mounted) {
                setState(() => _isLoadingVerdict = false);
                final report = data['report'] as Map<String, dynamic>?;
                if (report != null) {
                  _saveCurrentVoiceState(verdictReport: report);
                  _showVerdictModal(report);
                }
              }
            } else if (data['type'] == 'error') {
              if (mounted) {
                setState(() => _isLoadingVerdict = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(data['message'] ?? 'Error de conexión')),
                );
              }
            }
          } catch (_) {}
        } else if (message is Uint8List) {
          if (mounted) {
            setState(() => _isAISpeaking = true);
          }
          _audioPlayer.stop();
          _audioPlayer.play(BytesSource(message));
        }
      },
      onDone: () => _cleanup(),
      onError: (_) => _cleanup(),
    );

    _channel!.sink.add(jsonEncode({
      "email": email,
      "student_name": widget.studentName,
      "proposal_summary": widget.proposalSummary
    }));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _requestVerdict() {
    if (_channel == null || !_isConnected || _isLoadingVerdict) return;
    
    setState(() => _isLoadingVerdict = true);
    _channel!.sink.add(jsonEncode({"type": "request_verdict"}));
  }

  void _showVerdictModal(Map<String, dynamic> report) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final score = report['score'] ?? 85;
    final verdict = report['verdict'] ?? 'APROBADO';
    final oralFluency = report['oral_fluency'] ?? 'Alta / Sobresaliente';
    final argumentationRigor = report['argumentation_rigor'] ?? 'Fuerte y fundamentado';
    final summary = report['summary'] ?? '';
    final strengths = (report['strengths'] as List?)?.cast<String>() ?? [];
    final weaknesses = (report['weaknesses'] as List?)?.cast<String>() ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF161622) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black26,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    const Icon(Icons.workspace_premium, color: Colors.amber, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Dictamen de Evaluación de Defensa Oral',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1C1C28),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Divider(color: isDark ? Colors.white12 : Colors.black12, height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF202030) : const Color(0xFFF2F4FA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: verdict.toString().contains('MENCIÓN')
                          ? Colors.amber
                          : verdict.toString().contains('APROBADO')
                              ? Colors.green
                              : Colors.orange,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.amber.withValues(alpha: 0.15),
                        ),
                        child: Center(
                          child: Text(
                            '$score',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$verdict',
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF1C1C28),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Calificación global de la defensa oral',
                              style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A2620) : const Color(0xFFE8F7F0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.record_voice_over, size: 14, color: isDark ? Colors.greenAccent : Colors.green),
                                const SizedBox(width: 4),
                                Text(
                                  'Fluidez Oral',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.greenAccent : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              oralFluency,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF1C1C28),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2B221A) : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.gavel, size: 14, color: Colors.amber),
                                const SizedBox(width: 4),
                                const Text(
                                  'Réplica de Objeciones',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              argumentationRigor,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF1C1C28),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Text(
                  'Resumen del Jurado:',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1C1C28),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  summary,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),

                if (strengths.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Puntos Fuertes:',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  ...strengths.map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(s, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13)),
                            ),
                          ],
                        ),
                      )),
                ],

                if (weaknesses.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Aspectos a Reforzar:',
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  ...weaknesses.map((w) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(w, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13)),
                            ),
                          ],
                        ),
                      )),
                ],

                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cerrar', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: const Text('Enviar al Profesor', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.pop(context);
                          _promptSendToProfessor();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _promptSendToProfessor() async {
    final colorScheme = Theme.of(context).colorScheme;
    final studentMsgCount = _messages.where((m) => m.sender == 'student').length;

    if (studentMsgCount < 4) {
      final shouldSend = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '¿Enviar propuesta con defensa incompleta?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          content: Text(
            'Llevas únicamente $studentMsgCount intervenciones con el tribunal IA. Enviar el expediente con poca fundamentación aumenta la posibilidad de que esté incompleto y que tu profesor RECHACE tu propuesta.\n\n¿Deseas profundizar más con la IA o enviar de todos modos?',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('PROFUNDIZAR DEFENSA IA', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('ENVIAR DE TODOS MODOS', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      if (shouldSend != true) return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Expediente de defensa enviado a revisión del profesor exitosamente.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.pop(context);
    }
  }

  void _toggleVoiceRecording() async {
    if (_isAISpeaking) {
      _audioPlayer.stop();
      setState(() => _isAISpeaking = false);
      return;
    }

    if (_isListening) {
      _stopListeningAndSend();
    } else {
      _startListening();
    }
  }

  void _startListening() async {
    var micStatus = await Permission.microphone.status;
    if (!micStatus.isGranted) {
      micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) return;
    }

    if (!_sttAvailable) {
      _sttAvailable = await _speechToText.initialize();
    }

    if (_sttAvailable && !_isListening) {
      setState(() {
        _isListening = true;
        _liveSpokenText = '';
      });
      
      _speechToText.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _liveSpokenText = result.recognizedWords;
            });
          }
        },
        listenOptions: stt.SpeechListenOptions(
          localeId: 'es_MX',
          listenFor: const Duration(seconds: 90),
          pauseFor: const Duration(seconds: 10),
          cancelOnError: false,
          partialResults: true,
        ),
      );
    }
  }

  void _stopListeningAndSend() {
    _speechToText.stop();
    final textToSend = _liveSpokenText.trim();
    _liveSpokenText = '';
    
    if (mounted) {
      setState(() {
        _isListening = false;
      });
    }

    if (textToSend.isNotEmpty) {
      _sendStudentAnswer(textToSend, isWrittenText: false);
    }
  }

  void _sendStudentAnswer(String text, {bool isWrittenText = false}) {
    final cleanText = text.trim();
    if (cleanText.isEmpty || _channel == null || !_isConnected) return;
    
    if (_isSendingAnswer) return;
    if (_lastSentAnswer == cleanText &&
        _lastSentTime != null &&
        DateTime.now().difference(_lastSentTime!) < const Duration(seconds: 4)) {
      debugPrint("Bloqueando envío duplicado de respuesta: $cleanText");
      return;
    }

    _isSendingAnswer = true;
    _lastSentAnswer = cleanText;
    _lastSentTime = DateTime.now();
    _liveSpokenText = '';
    
    _speechToText.stop();
    _audioPlayer.stop();
    
    if (mounted) {
      setState(() {
        _isListening = false;
        _isAISpeaking = false;
        _messages.add(DefenseMessage(
          sender: 'student',
          text: cleanText,
          timestamp: DateTime.now(),
          type: isWrittenText ? 'text' : 'voice',
        ));
        _textController.clear();
        _previousTypedText = '';
      });
      _scrollToBottom();
      _saveCurrentVoiceState();
    }

    _channel!.sink.add(jsonEncode({"text": cleanText}));
  }

  void _cleanup() {
    _speechToText.stop();
    _audioPlayer.stop();
    _channel?.sink.close();
    if (mounted) {
      setState(() {
        _isConnected = false;
        _isListening = false;
        _isAISpeaking = false;
      });
    }
  }

  @override
  void dispose() {
    _saveCurrentVoiceState();
    _cleanup();
    _textController.dispose();
    _audioPlayer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F0F14) : const Color(0xFFF4F6F9);
    final appBarColor = isDark ? const Color(0xFF181822) : Colors.white;
    final appBarTextColor = isDark ? Colors.white : const Color(0xFF181822);
    final cardColor = isDark ? const Color(0xFF181824) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C28);
    final subtextColor = isDark ? Colors.white54 : Colors.black54;

    final sinodalBubbleColor = isDark ? const Color(0xFF1E1E2C) : const Color(0xFFEAEFFC);
    final sinodalTextColor = isDark ? Colors.white : const Color(0xFF1A1A2C);
    
    final studentBubbleColor = isDark ? const Color(0xFF16382C) : const Color(0xFFE2F7ED);
    final studentTextColor = isDark ? Colors.white : const Color(0xFF0A3D2E);

    final bottomPanelColor = isDark ? const Color(0xFF161622) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: isDark ? 0 : 1,
        iconTheme: IconThemeData(color: appBarTextColor),
        title: Text(
          'Simulador de Defensa por Voz',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: appBarTextColor),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.send_rounded, color: Colors.green),
            tooltip: 'Enviar a Revisión del Profesor',
            onPressed: _promptSendToProfessor,
          ),
          IconButton(
            icon: _isLoadingVerdict
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber),
                  )
                : const Icon(Icons.analytics_outlined, color: Colors.amber),
            tooltip: 'Ver Dictamen del Jurado',
            onPressed: _requestVerdict,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Cabecera Jurado Evaluador
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark ? [] : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: _isAISpeaking ? Colors.amber : (isDark ? const Color(0xFF28283C) : const Color(0xFFE2E4EC)),
                    child: Icon(
                      Icons.gavel_rounded,
                      color: _isAISpeaking ? Colors.black : (isDark ? Colors.amber : const Color(0xFF555570)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Docente IA Evaluador',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isAISpeaking
                              ? 'Exponiendo interrogante (escucha)...'
                              : _isListening
                                  ? 'Escuchando tu exposición oral...'
                                  : 'Tribunal en espera de tu réplica',
                          style: TextStyle(
                            color: _isAISpeaking
                                ? (isDark ? Colors.amber : const Color(0xFFD97706))
                                : _isListening
                                    ? (isDark ? Colors.greenAccent : Colors.green)
                                    : subtextColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _requestVerdict,
                    icon: const Icon(Icons.bar_chart_rounded, size: 16, color: Colors.amber),
                    label: const Text(
                      'Dictamen',
                      style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            // Historial de Mensajes de Conversación
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(color: Colors.amber),
                          const SizedBox(height: 16),
                          Text(
                            'La Docente IA Evaluador está iniciando el tribunal...',
                            style: TextStyle(color: subtextColor, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        final isSinodal = msg.sender == 'sinodal';
                        final isWritten = msg.type == 'text';

                        return Align(
                          alignment: isSinodal ? Alignment.centerLeft : Alignment.centerRight,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.82,
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSinodal ? sinodalBubbleColor : studentBubbleColor,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isSinodal ? 4 : 16),
                                bottomRight: Radius.circular(isSinodal ? 16 : 4),
                              ),
                              boxShadow: isDark ? [] : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isSinodal 
                                          ? Icons.record_voice_over 
                                          : (isWritten ? Icons.edit_note_rounded : Icons.mic),
                                      size: 14,
                                      color: isSinodal 
                                          ? (isDark ? Colors.amber : const Color(0xFFD97706)) 
                                          : (isDark ? Colors.greenAccent : const Color(0xFF059669)),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isSinodal 
                                          ? 'Docente IA Evaluador' 
                                          : (isWritten ? 'Tu Defensa Escrita' : 'Tu Defensa Oral'),
                                      style: TextStyle(
                                        color: isSinodal 
                                            ? (isDark ? Colors.amber : const Color(0xFFD97706)) 
                                            : (isDark ? Colors.greenAccent : const Color(0xFF059669)),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  msg.text,
                                  style: TextStyle(
                                    color: isSinodal ? sinodalTextColor : studentTextColor,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Captura de Voz en Tiempo Real
            if (_isListening && _liveSpokenText.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B2E24) : const Color(0xFFE6F9F0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.greenAccent.withValues(alpha: 0.5) : Colors.green.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.graphic_eq, color: isDark ? Colors.greenAccent : Colors.green, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Capturando voz en tiempo real:',
                          style: TextStyle(
                            color: isDark ? Colors.greenAccent : Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _liveSpokenText,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

            // PANEL MULTIMODAL PREMIUM DE INTERACCIÓN (VOZ + TECLADO TEXTO)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: bottomPanelColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: isDark ? [] : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Botón Conmutador de Teclado Texto vs Micrófono
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: _showTextInput
                              ? (isDark ? Colors.amber.withValues(alpha: 0.2) : Colors.amber.shade100)
                              : (isDark ? const Color(0xFF28283C) : const Color(0xFFF0F2F6)),
                        ),
                        icon: Icon(
                          _showTextInput ? Icons.mic_rounded : Icons.keyboard_alt_rounded,
                          color: _showTextInput ? Colors.amber : (isDark ? Colors.white70 : Colors.black87),
                        ),
                        tooltip: _showTextInput ? 'Cambiar a Micrófono' : 'Cambiar a Teclado Texto',
                        onPressed: () {
                          setState(() {
                            _showTextInput = !_showTextInput;
                          });
                        },
                      ),
                      const SizedBox(width: 8),

                      if (_showTextInput) ...[
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            enableSuggestions: false,
                            autocorrect: false,
                            keyboardType: TextInputType.text,
                            contextMenuBuilder: (context, editableTextState) => const SizedBox.shrink(),
                            onChanged: _onTypedTextChanged,
                            decoration: InputDecoration(
                              hintText: 'Redacta tu réplica escrita...',
                              filled: true,
                              fillColor: isDark ? const Color(0xFF222232) : const Color(0xFFF0F2F6),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onSubmitted: (val) {
                              if (val.trim().isNotEmpty) {
                                _sendStudentAnswer(val, isWrittenText: true);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                          ),
                          icon: const Icon(Icons.send_rounded),
                          onPressed: () {
                            if (_textController.text.trim().isNotEmpty) {
                              _sendStudentAnswer(_textController.text, isWrittenText: true);
                            }
                          },
                        ),
                      ] else ...[
                        Expanded(
                          child: GestureDetector(
                            onTap: _toggleVoiceRecording,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: _isListening
                                    ? (isDark ? Colors.greenAccent : Colors.green)
                                    : _isAISpeaking
                                        ? Colors.amber
                                        : (isDark ? const Color(0xFF28283C) : const Color(0xFFE5E7EB)),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: _isListening
                                        ? (isDark ? Colors.greenAccent.withValues(alpha: 0.5) : Colors.green.withValues(alpha: 0.4))
                                        : _isAISpeaking
                                            ? Colors.amber.withValues(alpha: 0.4)
                                            : Colors.black12,
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  )
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isAISpeaking
                                        ? Icons.volume_up_rounded
                                        : _isListening
                                            ? Icons.send_rounded
                                            : Icons.mic_rounded,
                                    color: (_isListening || _isAISpeaking) ? Colors.black : (isDark ? Colors.amber : const Color(0xFFD97706)),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    _isAISpeaking
                                        ? 'Silenciar Evaluación'
                                        : _isListening
                                            ? 'ENVIAR DEFENSA ORAL'
                                            : 'HABLAR POR MICRÓFONO',
                                    style: TextStyle(
                                      color: (_isListening || _isAISpeaking) ? Colors.black : (isDark ? Colors.white : const Color(0xFF1C1C28)),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _showTextInput
                        ? '✍️ Modo Redacción Escrita Activo (Anti Copy-Paste Habilitado)'
                        : _isAISpeaking
                            ? 'Toca para silenciar la voz del evaluador'
                            : _isListening
                                ? '🔴 Grabando... Toca para ENVIAR tu respuesta oral'
                                : '👑 Modo Multimodal Premium: Puedes intercambiar entre Voz y Teclado',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: subtextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
