import 'package:mobile/features/teams/data/models/team_model.dart';
import 'package:mobile/features/student_directory/domain/entities/student.dart';

class ProfDirectoryModel {
  final List<TeamModel> teams;
  final List<Student> studentsWithoutTeam;

  ProfDirectoryModel({
    required this.teams,
    required this.studentsWithoutTeam,
  });

  factory ProfDirectoryModel.fromJson(Map<String, dynamic> json) {
    final rawUnassigned = json['studentsWithoutTeam'] ??
        json['students_without_team'] ??
        json['unassigned_students'] ??
        json['unassigned'] ??
        json['rezagados'] ??
        [];

    return ProfDirectoryModel(
      teams: (json['teams'] as List<dynamic>?)
              ?.map((e) => TeamModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      studentsWithoutTeam: (rawUnassigned as List<dynamic>?)
              ?.map((e) => Student.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
