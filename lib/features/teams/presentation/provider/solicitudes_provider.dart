import 'package:flutter/foundation.dart';
import 'package:mobile/features/student_directory/domain/entities/student.dart';
import 'mock_solicitudes.dart';

enum SolicitudFilter {
  aceptadas,
  enviadas,
}

class SolicitudesProvider extends ChangeNotifier {
  SolicitudFilter _selectedFilter = SolicitudFilter.aceptadas;
  final List<Solicitud> _solicitudes = List.from(mockSolicitudes);

  SolicitudFilter get selectedFilter => _selectedFilter;
  List<Solicitud> get solicitudes => _solicitudes;

  List<Solicitud> get filteredSolicitudes {
    final targetState = _selectedFilter == SolicitudFilter.aceptadas
        ? SolicitudState.aceptada
        : SolicitudState.enviada;
    return _solicitudes.where((s) => s.state == targetState).toList();
  }

  void selectFilter(SolicitudFilter filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      notifyListeners();
    }
  }

  void addSolicitud(Student student) {
    final newId = 'sol_${DateTime.now().millisecondsSinceEpoch}';
    _solicitudes.add(
      Solicitud(
        id: newId,
        student: student,
        state: SolicitudState.enviada,
        date: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void inviteStudent(String id) {
    _solicitudes.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void rejectStudent(String id) {
    _solicitudes.removeWhere((s) => s.id == id);
    notifyListeners();
  }
}
