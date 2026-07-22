import 'package:mobile/core/network/api_endpoints.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile/core/network/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import '../provider/my_project_provider.dart';

class ProjectDefenseChatPage extends StatefulWidget {
  final String teamId;
  final String studentName;
  final String proposalSummary;
  final Map<String, dynamic> analysisResult;
  final String? authToken;
  final List<String>? teamMembers;

  const ProjectDefenseChatPage({
    super.key,
    required this.teamId,
    required this.studentName,
    required this.proposalSummary,
    required this.analysisResult,
    this.authToken,
    this.teamMembers,
  });

  @override
  State<ProjectDefenseChatPage> createState() => _ProjectDefenseChatPageState();
}

class _ProjectDefenseChatPageState extends State<ProjectDefenseChatPage> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = true;
  String? _sessionId;
  bool _defensePassed = false;
  int _messageCount = 0;
  final int _maxMessages = 10;
  late MyProjectProvider _providerRef;
  Timer? _pollTimer;
  String _previousText = '';

  void _onTextChanged(String newText) {
    final diff = newText.length - _previousText.length;
    // Si se pegan más de 15 caracteres de golpe (típico de pegar texto o dictado por voz)
    if (diff > 15) {
      _textController.text = _previousText;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _previousText.length),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Por integridad académica, no se permite pegar texto ni usar dictado por voz del teclado. Redacta tu respuesta a mano.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }
    _previousText = newText;
  }
  
  @override
  void initState() {
    super.initState();
    _providerRef = context.read<MyProjectProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_providerRef.activeSessionId != null && _providerRef.activeChatMessages.isNotEmpty) {
        setState(() {
          _sessionId = _providerRef.activeSessionId;
          _messages.addAll(_providerRef.activeChatMessages.map((m) => Map<String, String>.from(m)));
          _messageCount = _providerRef.activeMessageCount;
          _isLoading = false;
        });
        _scrollToBottom();
        _startPolling();
      } else {
        _startSession();
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    if (_sessionId != null && !_defensePassed) {
      _providerRef.saveActiveSession(_sessionId!, _messages, _messageCount);
    }
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _startSession() async {
    try {
      final token = widget.authToken ?? context.read<AuthProvider>().currentUser?.token;
      final url = Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.llmSessionStart}');
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      headers['Content-Type'] = 'application/json';
      if (token != null) headers['Authorization'] = 'Bearer $token';
      
      final body = jsonEncode({
        'team_id': widget.teamId,
        'team_members': widget.teamMembers ?? [widget.studentName],
        'proposal_summary': widget.proposalSummary,
        'analysis_result': widget.analysisResult,
      });

      final response = await http.post(url, headers: headers, body: body).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        _sessionId = data['session_id'];
        
        setState(() {
          if (data['messages'] != null && (data['messages'] as List).isNotEmpty) {
            _messages.clear();
            for (var m in data['messages']) {
              if (m['role'] != 'system') {
                _messages.add({'role': m['role'], 'content': m['content']});
              }
            }
            _messageCount = _messages.where((m) => m['role'] == 'user').length;
          } else {
            final aiOpening = data['ai_opening_message'] ?? 'Hola, soy Corvus Evaluator. Hablemos de tu proyecto.';
            _messages.add({'role': 'assistant', 'content': aiOpening});
          }
          _isLoading = false;
        });
        
        if (_messages.isNotEmpty && _messages.last['role'] == 'assistant') {
          _checkIfPassed(_messages.last['content'] ?? '');
        }
      } else {
        _showError('No se pudo iniciar la sesión de defensa. (Error ${response.statusCode})');
      }
    } catch (e) {
      _showError('Error de conexión al iniciar la defensa.');
    }
    _startPolling();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_defensePassed && _sessionId != null) {
        _fetchNewMessages();
      }
    });
  }

  Future<void> _fetchNewMessages() async {
    if (_sessionId == null) return;
    try {
      final token = widget.authToken ?? context.read<AuthProvider>().currentUser?.token;
      final url = Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.llmSessionMessages(_sessionId!)}');
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final remoteMsgs = data['messages'] as List;
        
        int newUserCount = 0;
        
        final List<Map<String, String>> parsedMsgs = [];
        for (var m in remoteMsgs) {
          if (m['role'] != 'system') {
            parsedMsgs.add({'role': m['role'], 'content': m['content']});
            if (m['role'] == 'user') newUserCount++;
          }
        }
        
        if (parsedMsgs.length > _messages.length) {
          setState(() {
            _messages.clear();
            _messages.addAll(parsedMsgs);
            _messageCount = newUserCount;
            // If the last message is from assistant, we are no longer loading
            if (_messages.isNotEmpty && _messages.last['role'] == 'assistant') {
              _isLoading = false;
            }
          });
          _scrollToBottom();
          if (_messages.isNotEmpty && _messages.last['role'] == 'assistant') {
             _checkIfPassed(_messages.last['content'] ?? '');
          }
        }
      }
    } catch (e) {
      // Ignoramos errores silenciosos de polling
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _sessionId == null) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _previousText = '';
      _isLoading = true;
      _messageCount++;
    });
    
    _textController.clear();
    _scrollToBottom();

    try {
      final token = widget.authToken ?? context.read<AuthProvider>().currentUser?.token;
      final url = Uri.parse('${ApiConfig.apiGatewayUrl}${ApiEndpoints.llmSessionMessage}');
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      headers['Content-Type'] = 'application/json';
      if (token != null) headers['Authorization'] = 'Bearer $token';
      
      final body = jsonEncode({
        'session_id': _sessionId,
        'user_message': text,
        'student_name': widget.studentName,
      });

      final response = await http.post(url, headers: headers, body: body).timeout(const Duration(seconds: 40));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final aiMessage = data['ai_message'] ?? '';
        
        setState(() {
          _messages.add({'role': 'assistant', 'content': aiMessage});
          _isLoading = false;
        });
        _scrollToBottom();
        _checkIfPassed(aiMessage);
      } else {
        setState(() => _isLoading = false);
        _showError('Error al enviar el mensaje. Intenta de nuevo.');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error de conexión.');
    }
  }

  void _checkIfPassed(String aiMessage) {
    if (aiMessage.contains('[DEFENSA_SUPERADA]')) {
      setState(() {
        _defensePassed = true;
      });
      _showSuccessDialog('¡Felicidades! Has defendido tu propuesta exitosamente.');
    } else if (_messageCount >= _maxMessages) {
      // Se rindió el límite
      setState(() {
        _defensePassed = true;
        _messages.add({
          'role': 'system',
          'content': 'Límite de mensajes alcanzado. Se enviará el score actual a revisión.'
        });
      });
      _showSuccessDialog('Límite de mensajes alcanzado. Has terminado la defensa.');
    }
  }

  void _showError(String msg) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text('Defensa Finalizada'),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context, _messages); // Return to previous page with history
            },
            child: const Text('Continuar a Envío'),
          )
        ],
      ),
    );
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

  Widget _buildMessageBubble(Map<String, String> msg) {
    final isUser = msg['role'] == 'user';
    final isSystem = msg['role'] == 'system';
    final colors = Theme.of(context).colorScheme;
    
    if (isSystem) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(msg['content'] ?? '', style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12)),
        ),
      );
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isUser ? colors.primary.withValues(alpha: 0.15) : colors.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? const Radius.circular(4) : null,
            bottomLeft: !isUser ? const Radius.circular(4) : null,
          ),
          border: Border.all(
            color: isUser ? colors.primary.withValues(alpha: 0.3) : colors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: SelectableText(
          msg['content']?.replaceAll('[DEFENSA_SUPERADA]', '') ?? '',
          style: TextStyle(
            color: colors.onSurface,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(widget.analysisResult['approved'] == true ? 'Defensa de Propuesta' : 'Retroalimentación IA'),
        backgroundColor: colors.surface,
        scrolledUnderElevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text('$_messageCount / $_maxMessages msg', style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12)),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty && _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 20, top: 10),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageBubble(_messages[index]);
                  },
                ),
          ),
          if (_isLoading && _messages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 12),
                  Text('Evaluando respuesta...', style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12)),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(top: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.3))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      enabled: !_isLoading && !_defensePassed,
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.text,
                      contextMenuBuilder: (context, editableTextState) => const SizedBox.shrink(),
                      onChanged: _onTextChanged,
                      maxLines: 4,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: _defensePassed ? 'Defensa finalizada' : 'Justifica tu respuesta...',
                        filled: true,
                        fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.3),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (val) {
                        if (!_isLoading && !_defensePassed) _sendMessage(val);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: _isLoading || _defensePassed ? colors.surfaceContainerHighest : colors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send_rounded, color: _isLoading || _defensePassed ? colors.onSurfaceVariant : colors.onPrimary),
                      onPressed: _isLoading || _defensePassed ? null : () => _sendMessage(_textController.text),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
