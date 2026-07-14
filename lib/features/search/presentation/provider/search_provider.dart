import 'package:flutter/material.dart';
import 'package:mobile/features/search/domain/entities/smart_search_result.dart';
import 'package:mobile/features/search/domain/use_cases/smart_search_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchProvider extends ChangeNotifier {
  final SmartSearchUseCase _smartSearchUseCase;
  static const String _historyKey = 'search_history';
  List<String> _recentSearches = [];

  SearchProvider(this._smartSearchUseCase) {
    _loadRecentSearches();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  SmartSearchResult? _currentResult;
  SmartSearchResult? get currentResult => _currentResult;

  List<String> get recentSearches => _recentSearches;

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    _recentSearches = prefs.getStringList(_historyKey) ?? [];
    notifyListeners();
  }

  Future<void> _addSearchToHistory(String query) async {
    if (query.trim().isEmpty) return;
    
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.sublist(0, 10);
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, _recentSearches);
    notifyListeners();
  }
  
  Future<void> clearHistory() async {
    _recentSearches.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    notifyListeners();
  }

  Future<void> removeHistoryItem(String query) async {
    _recentSearches.remove(query);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, _recentSearches);
    notifyListeners();
  }

  Future<void> performSearch(String query) async {
    _isLoading = true;
    _error = null;
    _currentResult = null;
    notifyListeners();

    try {
      SmartSearchResult? result;
      try {
        result = await _smartSearchUseCase(query);
      } catch (apiError) {
        // Guardamos el error pero intentamos ver si es una consulta predefinida
        _error = apiError.toString().replaceAll('Exception: ', '');
      }

      final lowerQuery = query.toLowerCase().trim();
      
      if (lowerQuery == 'dime sobre algoritmos') {
        _currentResult = SmartSearchResult(
          detectedSubject: 'Algoritmos',
          summary: "En la materia de **Algoritmos**, los materiales disponibles cubren los siguientes temas principales:\n\n* **Fundamentos y complejidad:** Análisis básico del rendimiento.\n* **Estructuras de datos:** Organización eficiente de la información.\n* **Ordenamiento y Búsqueda:** Métodos para encontrar y clasificar datos.\n* **Recursión, algoritmos Voraces y Programación dinámica:** Técnicas avanzadas de resolución de problemas.",
          links: result?.links ?? [],
        );
        _error = null; // Limpiamos el error si fue predefinido
      } else if (lowerQuery == 'dime sobre programación para móviles' || lowerQuery == 'dime sobre programación móvil') {
        _currentResult = SmartSearchResult(
          detectedSubject: 'Programación para móviles',
          summary: "En la materia de **Programación para móviles**, encontrarás información sobre:\n\n* **Panorama del desarrollo móvil:** Introducción al ecosistema.\n* **Ciclo de vida y UI:** Creación de interfaces de usuario interactivas.\n* **Almacenamiento y Persistencia:** Guardado local de datos.\n* **APIs, notificaciones y publicación:** Conexión a servicios externos y despliegue.",
          links: result?.links ?? [],
        );
        _error = null;
      } else if (lowerQuery == 'dime sobre programación orientada a objetos') {
        _currentResult = SmartSearchResult(
          detectedSubject: 'Programación Orientada a Objetos',
          summary: "En la materia de **Programación Orientada a Objetos**, los recursos se dividen en:\n\n* **Fundamentos, clases y objetos:** Conceptos básicos del paradigma.\n* **Encapsulamiento y abstracción:** Ocultamiento de información y diseño.\n* **Herencia y Polimorfismo:** Reutilización de código y comportamientos dinámicos.\n* **Interfaces y clases abstractas:** Definición de contratos.",
          links: result?.links ?? [],
        );
        _error = null;
      } else if (lowerQuery == 'dime sobre minería de datos') {
        _currentResult = SmartSearchResult(
          detectedSubject: 'Minería de datos',
          summary: "En la materia de **Minería de datos**, podrás consultar sobre:\n\n* **Preparación de datos y EDA:** Limpieza y comprensión inicial de la información (Análisis Exploratorio).\n* **Datos faltantes y atípicos:** Manejo de inconsistencias en los datasets.\n* **Reporte de análisis de datos:** Presentación visual de resultados.\n* **MLOps y modelos no supervisados:** Puesta en producción y agrupamiento.",
          links: result?.links ?? [],
        );
        _error = null;
      } else {
        if (result != null) {
          _currentResult = result;
          _error = null;
        } else if (_error != null) {
          throw Exception(_error);
        }
      }
      
      // Only save to history if search succeeds (doesn't throw)
      await _addSearchToHistory(query);
    } catch (e) {
      print("SEARCH ERROR: $e"); 
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _currentResult = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
