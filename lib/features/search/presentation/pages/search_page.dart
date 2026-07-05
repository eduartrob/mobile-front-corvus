import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/shared/widgets/corvus_top_bar.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _hasResults = false;
  
  // Speech to text
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  
  // Mock Data
  final List<String> _tendencias = ['Flutter', 'Redes Neuronales', 'Clean Architecture', 'Scrum', 'MLOps'];
  final List<Map<String, dynamic>> _categorias = [
    {'title': 'Ing. Software', 'icon': Icons.code, 'color': Colors.blueAccent},
    {'title': 'Bases de Datos', 'icon': Icons.storage, 'color': Colors.orangeAccent},
    {'title': 'Inteligencia Art.', 'icon': Icons.psychology, 'color': Colors.purpleAccent},
    {'title': 'Redes', 'icon': Icons.router, 'color': Colors.tealAccent},
    {'title': 'Seguridad', 'icon': Icons.security, 'color': Colors.redAccent},
    {'title': 'Gestión', 'icon': Icons.auto_graph, 'color': Colors.greenAccent},
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }
  
  void _initSpeech() async {
    await _speechToText.initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _toggleListening() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(
          onResult: (result) {
            setState(() {
              _searchController.text = result.recognizedWords;
            });
          },
          localeId: 'es_MX',
        );
      } else {
        // Manejar permisos si es necesario
        var status = await Permission.microphone.request();
        if (status.isGranted) {
           _toggleListening();
        }
      }
    } else {
      setState(() => _isListening = false);
      _speechToText.stop();
      if (_searchController.text.isNotEmpty) {
        _submitSearch(_searchController.text);
      }
    }
  }

  void _submitSearch(String query) {
    if (query.isNotEmpty) {
      setState(() {
        _hasResults = true;
        _isListening = false;
        _speechToText.stop();
      });
      // TODO: Conectar con backend RAG
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    
    // Forzamos un ambiente oscuro para el "Dark Mode Premium"
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? colorScheme.surface : const Color(0xFF0F172A); // Tailwind slate-900
    final textColor = isDark ? colorScheme.onSurface : Colors.white;

    return Theme(
      data: Theme.of(context).copyWith(
        brightness: Brightness.dark, // Forzar colores oscuros
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: CorvusTopBar(
          showLogo: false,
          titleWidget: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: SizedBox(
              height: 48,
              child: TextField(
                controller: _searchController,
                autofocus: false,
                style: const TextStyle(color: Colors.white),
                textInputAction: TextInputAction.search,
                onSubmitted: _submitSearch,
                onChanged: (value) {
                  if (_hasResults) {
                    setState(() => _hasResults = false);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Pregúntale a la IA sobre tus clases...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20, color: Colors.white70),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _hasResults = false);
                          },
                        ),
                      IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic : Icons.mic_none, 
                          color: _isListening ? Colors.redAccent : Colors.white70
                        ),
                        onPressed: _toggleListening,
                      ),
                    ],
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: _hasResults ? _buildResultsView(textColor) : _buildExploreView(textColor),
      ),
    );
  }

  Widget _buildExploreView(Color textColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección Tendencias
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.orangeAccent, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Tendencias en tus materias',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              itemCount: _tendencias.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return ActionChip(
                  label: Text(_tendencias[index], style: const TextStyle(color: Colors.white)),
                  backgroundColor: Colors.white.withOpacity(0.05),
                  side: BorderSide(color: Colors.white.withOpacity(0.1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onPressed: () {
                    _searchController.text = _tendencias[index];
                    _submitSearch(_tendencias[index]);
                  },
                );
              },
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Sección Explorar Categorías (Grid)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Explorar por Categoría',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: _categorias.length,
              itemBuilder: (context, index) {
                final cat = _categorias[index];
                return _buildGlassCard(
                  title: cat['title'],
                  icon: cat['icon'],
                  color: cat['color'],
                  onTap: () {
                    _searchController.text = 'Dime sobre ${cat['title']}';
                    _submitSearch(_searchController.text);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: color),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsView(Color textColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Buscando resultados para: "${_searchController.text}"',
            style: TextStyle(
              fontSize: 16,
              color: textColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          // Placeholder para la respuesta RAG
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent.withOpacity(0.1), Colors.purpleAccent.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.blueAccent),
                    SizedBox(width: 8),
                    Text(
                      'Respuesta de la IA',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Este es un ejemplo simulado de respuesta RAG. En el futuro, aquí verás el resumen generado por el LLM basado en los PDFs del maestro, citando las fuentes correctas.',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
