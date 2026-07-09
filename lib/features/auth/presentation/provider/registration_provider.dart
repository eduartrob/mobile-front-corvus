import 'package:flutter/foundation.dart';

class RegistrationProvider extends ChangeNotifier {
  // Step 1: RegisterPage
  String email = '';
  String password = '';
  String role = '';

  // Step 2: StudentUniversityPage
  String fullName = '';
  String matricula = '';
  String universityId = '';
  String universityName = '';
  String periodName = '';
  String periodNumber = '';
  String careerId = '';
  String careerName = '';

  // Step 3: StudentSkillsPage
  List<String> selectedSkills = [];

  void setRegisterData({
    required String email,
    required String password,
    required String role,
  }) {
    this.email = email;
    this.password = password;
    this.role = role;
    notifyListeners();
  }

  void setUniversityData({
    required String fullName,
    required String matricula,
    required String universityId,
    required String universityName,
    required String periodName,
    required String periodNumber,
    required String careerId,
    required String careerName,
  }) {
    this.fullName = fullName;
    this.matricula = matricula;
    this.universityId = universityId;
    this.universityName = universityName;
    this.periodName = periodName;
    this.periodNumber = periodNumber;
    this.careerId = careerId;
    this.careerName = careerName;
    notifyListeners();
  }

  void setSkills(List<String> skills) {
    this.selectedSkills = skills;
    notifyListeners();
  }

  void clearData() {
    email = '';
    password = '';
    role = '';
    fullName = '';
    matricula = '';
    universityId = '';
    universityName = '';
    periodName = '';
    periodNumber = '';
    careerId = '';
    careerName = '';
    selectedSkills = [];
    notifyListeners();
  }
}
