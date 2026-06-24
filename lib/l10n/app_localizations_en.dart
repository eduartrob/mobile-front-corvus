// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get loginSubtitle => 'Log in with your university account to access.';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get exclusiveAccessInfo =>
      'Exclusive access for students with an active institutional domain.';

  @override
  String get terms => 'Terms';

  @override
  String get privacy => 'Privacy';

  @override
  String get help => 'Help';

  @override
  String get appTitle => 'Corvus';

  @override
  String get navInspiration => 'Inspiration';

  @override
  String get navMyProject => 'My Project';

  @override
  String get navTeams => 'Teams';

  @override
  String get navProfile => 'Profile';

  @override
  String get welcomeToCorvus => 'Welcome to Corvus';

  @override
  String get welcomeCorvusDesc =>
      'Corvus analyzes and groups academic repositories to reveal unexplored research areas. Discover unique opportunities for your next big project.';

  @override
  String get unexploredProjects => 'Unexplored Projects';

  @override
  String get unexploredProjectsDesc =>
      'Based on the analysis of +10,000 recent theses.';

  @override
  String get highPotential => 'High Potential';

  @override
  String get explore => 'Explore';

  @override
  String get generateIdeas => 'Generate Ideas';

  @override
  String get lookingForSomethingDifferent => 'Looking for something different?';

  @override
  String get lookingForSomethingDifferentDesc =>
      'Write your topics of interest and our Artificial Intelligence will create unique and tailored research proposals.';

  @override
  String get searchPlaceholder => 'Ex: Energy + Sociology...';
}
