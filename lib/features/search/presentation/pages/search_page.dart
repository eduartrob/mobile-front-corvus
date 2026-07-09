import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/shared/widgets/corvus_top_bar.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile/features/search/presentation/provider/search_provider.dart';
import 'package:mobile/core/di/di.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<SearchProvider>(),
      child: const _SearchPageView(),
    );
  }
}

class _SearchPageView extends StatefulWidget {
  const _SearchPageView();

  @override
  State<_SearchPageView> createState() => _SearchPageViewState();
}

class _SearchPageViewState extends State<_SearchPageView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _hasResults = false;

  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  final FlutterTts _flutterTts = FlutterTts();
  final FocusNode _searchFocusNode = FocusNode();

  final List<Map<String, dynamic>> _materias = [
    {
      'title': 'Algoritmos',
      'icon': Icons.account_tree_rounded,
      'color': Colors.orange,
    },
    {
      'title': 'Programación para móviles',
      'icon': Icons.smartphone_rounded,
      'color': Colors.blue,
    },
    {
      'title': 'Programación Orientada a Objetos',
      'icon': Icons.integration_instructions_rounded,
      'color': Colors.green,
    },
    {
      'title': 'Minería de datos',
      'icon': Icons.data_exploration_rounded,
      'color': Colors.purple,
    },
  ];

  final List<String> _tendencias = [
    'Algoritmos voraces',
    'Ciclo de vida en móviles',
    'Herencia y polimorfismo',
    'Datos atípicos en datasets',
  ];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  void _toggleListening() async {
    _flutterTts
        .stop(); // Detener cualquier lectura actual al interactuar con el micrófono
    if (!_isListening) {
      bool available = await _speechToText.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
            if (_searchController.text.isNotEmpty && !_hasResults) {
              _submitSearch(_searchController.text, fromVoice: true);
            }
          }
        },
      );
      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(
          onResult: (result) {
            setState(() {
              _searchController.text = result.recognizedWords;
            });
            if (result.finalResult) {
              setState(() => _isListening = false);
              _submitSearch(_searchController.text, fromVoice: true);
            }
          },
          localeId: 'es_MX',
        );
      } else {
        var status = await Permission.microphone.request();
        if (status.isGranted) {
          _toggleListening();
        }
      }
    } else {
      setState(() => _isListening = false);
      _speechToText.stop();
      if (_searchController.text.isNotEmpty) {
        _submitSearch(_searchController.text, fromVoice: true);
      }
    }
  }

  void _submitSearch(String query, {bool fromVoice = false}) async {
    if (query.isNotEmpty) {
      setState(() {
        _hasResults = true;
        _isListening = false;
        _speechToText.stop();
      });
      await _flutterTts.stop();
      await context.read<SearchProvider>().performSearch(query);
      if (fromVoice && mounted) {
        final result = context.read<SearchProvider>().currentResult;
        if (result != null) {
          final cleanText = result.summary.replaceAll(RegExp(r'[*#]'), '');
          await _flutterTts.setLanguage("es-MX");
          await _flutterTts.speak(cleanText);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final bgColor = colorScheme.surface;
    final textColor = colorScheme.onSurface;

    return PopScope(
      canPop: !_hasResults,
      onPopInvokedWithResult: (didPop, dynamic result) {
        if (didPop) return;
        if (_hasResults) {
          _flutterTts.stop();
          setState(() => _hasResults = false);
          context.read<SearchProvider>().clearSearch();
          _searchController.clear();
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: CorvusTopBar(
          showLogo: false,
          hideActions: _searchFocusNode.hasFocus || _hasResults,
          titleWidget: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: Row(
              children: [
                if (_hasResults)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: textColor),
                      onPressed: () {
                        _flutterTts.stop();
                        setState(() => _hasResults = false);
                        context.read<SearchProvider>().clearSearch();
                        _searchController.clear();
                      },
                    ),
                  ),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      autofocus: false,
                      style: TextStyle(color: textColor, fontSize: 16),
                      textInputAction: TextInputAction.search,
                      onSubmitted: _submitSearch,
                      onChanged: (value) {
                        if (_hasResults) {
                          _flutterTts.stop();
                          setState(() => _hasResults = false);
                          context.read<SearchProvider>().clearSearch();
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Buscar sobre tus materias...',
                        hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 0,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: textColor.withOpacity(0.7),
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_searchController.text.isNotEmpty)
                              IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  size: 20,
                                  color: textColor.withOpacity(0.7),
                                ),
                                onPressed: () {
                                  _flutterTts.stop();
                                  _searchController.clear();
                                  setState(() => _hasResults = false);
                                  context.read<SearchProvider>().clearSearch();
                                },
                              ),
                            IconButton(
                              icon: Icon(
                                _isListening ? Icons.mic : Icons.mic_none,
                                color: _isListening
                                    ? colorScheme.error
                                    : colorScheme.primary,
                              ),
                              onPressed: _toggleListening,
                            ),
                          ],
                        ),
                        filled: true,
                        fillColor: _searchFocusNode.hasFocus
                            ? colorScheme.surface
                            : colorScheme.primaryContainer.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(26),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(26),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(26),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent, // Esto permite detectar toques en zonas transparentes (espacios vacíos)
          onTap: () => FocusScope.of(context).unfocus(),
          child: _hasResults
              ? _buildResultsView(textColor, colorScheme)
              : _buildExploreView(textColor, colorScheme),
        ),
      ),
    );
  }

  Widget _buildExploreView(Color textColor, ColorScheme colorScheme) {
    return Consumer<SearchProvider>(
      builder: (context, provider, child) {
        final recentSearches = provider.recentSearches;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (recentSearches.isNotEmpty)
                Column(
                  children: recentSearches.map((query) {
                    return Dismissible(
                      key: Key(query),
                      direction: DismissDirection.startToEnd,
                      onDismissed: (direction) {
                        provider.removeHistoryItem(query);
                      },
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 24),
                        color: Colors.transparent,
                        child: Icon(Icons.delete, color: colorScheme.error.withOpacity(0.5)),
                      ),
                      child: InkWell(
                        onTap: () {
                          _searchController.text = query;
                          _submitSearch(query);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          child: Row(
                            children: [
                              Icon(Icons.history, color: textColor.withOpacity(0.6), size: 20),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  query,
                                  style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 15),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(Icons.north_west, color: textColor.withOpacity(0.5), size: 18),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 15), // Espacio por encima de TODA la sección de tendencias
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 5), // Quitamos el top porque el SizedBox ya hace la separación
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tendencias de Búsqueda',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500, // Grosor medio
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Wrap(
                  spacing: MediaQuery.sizeOf(context).width * 0.015, // Responsivo horizontal (1.5% del ancho)
                  runSpacing: MediaQuery.sizeOf(context).height * 0.005, // Responsivo vertical (0.5% del alto, muy poco espacio)
                  children: _tendencias.map((tendencia) {
                    return ActionChip(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Permite que el runSpacing de 8 sea real
                      label: Text(
                        tendencia,
                        style: TextStyle(color: textColor, fontSize: 13),
                      ),
                      avatar: Icon(
                        Icons.search,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      backgroundColor: colorScheme.primaryContainer.withOpacity(0.5),
                      surfaceTintColor: Colors.transparent,
                      elevation: 0,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onPressed: () {
                        _searchController.text = tendencia;
                        _submitSearch(tendencia);
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Materias Disponibles',
                  style: TextStyle(
                    fontSize: 16, // Mismo tamaño que Tendencias
                    fontWeight: FontWeight.w500, // Grosor medio
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    mainAxisExtent: 70, // Alto fijo en píxeles. ¡Ya no crecerán a lo alto si acuestas el teléfono!
                  ),
                  itemCount: _materias.length,
                  itemBuilder: (context, index) {
                    final mat = _materias[index];
                    return _buildMateriaCard(
                      title: mat['title'],
                      icon: mat['icon'],
                      iconColor: mat['color'],
                      textColor: textColor,
                      colorScheme: colorScheme,
                      onTap: () {
                        _searchController.text = 'Dime sobre ${mat['title']}';
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
      },
    );
  }

  Widget _buildMateriaCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color textColor,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsView(Color textColor, ColorScheme colorScheme) {
    return Consumer<SearchProvider>(
      builder: (context, provider, child) {
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
              if (provider.isLoading)
                Center(
                  child: CircularProgressIndicator(color: colorScheme.primary),
                )
              else if (provider.error != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.error.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    'Error: ${provider.error}',
                    style: TextStyle(color: colorScheme.error),
                  ),
                )
              else if (provider.currentResult != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primaryContainer.withOpacity(0.5),
                            colorScheme.tertiaryContainer.withOpacity(0.3),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Respuesta de la IA',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          MarkdownBody(
                            data: provider.currentResult!.summary,
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(
                                color: textColor.withOpacity(0.9),
                                height: 1.5,
                                fontSize: 15,
                              ),
                              listBullet: TextStyle(
                                color: textColor.withOpacity(0.9),
                                fontSize: 15,
                              ),
                              strong: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              h1: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              h2: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              h3: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (provider.currentResult!.links.isNotEmpty &&
                        !provider.currentResult!.summary.toLowerCase().contains(
                          'lo siento',
                        ) &&
                        !provider.currentResult!.summary.toLowerCase().contains(
                          'lamentablemente',
                        ) &&
                        !provider.currentResult!.summary.toLowerCase().contains(
                          'no hay suficiente información',
                        )) ...[
                      Text(
                        'Fuentes (${provider.currentResult!.links.length})',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...provider.currentResult!.links.map(
                        (link) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: InkWell(
                            onTap: () => launchUrl(Uri.parse(link)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest
                                    .withOpacity(0.3),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: colorScheme.outline.withOpacity(0.1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.picture_as_pdf,
                                    color: colorScheme.error,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      link,
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        decoration: TextDecoration.underline,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
