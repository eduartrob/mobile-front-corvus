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
    return ProfDirectoryModel(
      teams: (json['teams'] as List<dynamic>?)
              ?.map((e) => TeamModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      studentsWithoutTeam: (json['studentsWithoutTeam'] as List<dynamic>?)
              ?.map((e) => Student.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
