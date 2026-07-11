class FinalReviewModel {
  final String id;
  final String teamId;
  final String careerId;
  final String universityId;
  final String studentId;
  final Map<String, dynamic> proposalData;
  final String status;
  final DateTime? appointmentDate;
  final String? locationLink;
  final DateTime createdAt;

  const FinalReviewModel({
    required this.id,
    required this.teamId,
    required this.careerId,
    required this.universityId,
    required this.studentId,
    required this.proposalData,
    required this.status,
    this.appointmentDate,
    this.locationLink,
    required this.createdAt,
  });

  factory FinalReviewModel.fromJson(Map<String, dynamic> json) {
    return FinalReviewModel(
      id: json['id'] ?? '',
      teamId: json['team_id'] ?? '',
      careerId: json['career_id'] ?? '',
      universityId: json['university_id'] ?? '',
      studentId: json['student_id'] ?? '',
      proposalData: json['proposal_data'] ?? {},
      status: json['status'] ?? 'PENDING',
      appointmentDate: json['appointment_date'] != null ? DateTime.parse(json['appointment_date']) : null,
      locationLink: json['location_link'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}
