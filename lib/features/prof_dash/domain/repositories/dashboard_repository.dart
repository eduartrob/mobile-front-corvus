import 'package:mobile/features/prof_dash/domain/entities/dashboard_entity.dart';

/// Contrato de dominio para obtener datos del dashboard del profesor.
abstract class DashboardRepository {
  Future<DashboardEntity> loadDashboardStats({String? projectId, String? token});
}