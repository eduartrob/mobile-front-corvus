import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  String get welcomeBack;

  String get loginSubtitle;

  String get continueWithGoogle;

  String get signingIn;

  String get unknownError;

  String get exclusiveAccessInfo;

  String get terms;

  String get privacy;

  String get help;

  String get appTitle;

  String get navInspiration;

  String get navMyProject;

  String get navTeams;

  String get navProfile;

  String get welcomeToCorvus;

  String get welcomeCorvusDesc;

  String get unexploredProjects;

  String get unexploredProjectsDesc;

  String get highPotential;

  String get explore;

  String get generateIdeas;

  String get lookingForSomethingDifferent;

  String get lookingForSomethingDifferentDesc;

  String get searchPlaceholder;

  String get profNavDash;

  String get profNavReviews;

  String get profNavRules;

  String get profNavHistory;

  String get featureUpcoming;

  String get manage;

  String get generateWorkPlan;

  String get leaveTeam;

  String get teamManagementTitle;

  String get teamManagementDesc;

  String get teamFull;

  String get members;

  String get pendingInvitations;

  String get twoDaysAgo;

  String get teamFullInviteNotice;

  String get aiAssistantTeamSuggestionSpan1;

  String get aiAssistantTeamSuggestionSpan2;

  String get aiAssistantTeamSuggestionSpan3;

  String get aiAssistantTeamSuggestionSpan4;

  String get aiAssistantTeamSuggestionSpan5;

  String get youLeader;

  String get registerRule;

  String get viewReports;

  String get citeTeam;

  String get approve;

  String get reject;

  String get gpa;

  String get projects;

  String get technicalSkills;

  String get recentActivity;

  String get ragEngineUpdate;

  String get timeTwoHoursAgo;

  String get readingCompleted;

  String get timeYesterday;

  String get appearance;

  String get themeSystem;

  String get themeLight;

  String get themeDark;

  String get logout;

  String get errorCredentialsDriveCorvus;

  String get folderAlreadyLinked;

  String get folderLinkedProcessingStarted;

  String get removeAccessTitle;

  String get cancel;

  String get remove;

  String get driveAccessRequired;

  String get sendForReview;

  String get browseFiles;

  String get understood;

  String get detailedAnalysisTitle;

  String get preValidationTitle;

  String get detailedAnalysisDesc;

  String get preValidationDesc;

  String get analyzingStructure;

  String get deleteDraft;

  String get uploadAnotherProposal;

  String get analysisEstimatedTime;

  String get loadingPhase1;

  String get loadingPhase2;

  String get loadingPhase3;

  String get loadingPhase4;

  String get loadingPhase5;

  String get loadingPhase6;

  String get loadingPhase7;

  String get loadingPhase8;

  String get uploadZoneTitle;

  String get uploadZoneSubtitle;

  String get uploadedToday;

  String get serverErrorContactSupport;

  String get loginErrorNotAllowedEmail;

  String get invalidDocumentTitle;

  String get invalidDocumentDesc;

  String get invalidDocumentAction;

  String get blueOceanGenericCategory;

  String get blueOceanGenericTag;

  String get blueOceanGenericDesc;

  String get notifUploadTitle;

  String get notifUploadBody;

  String get notifPreValidReadyTitle;

  String get notifPreValidReadyBody;

  String get notifErrorTitle;

  String get notifPreValidFailed;

  String get notifAnalysisStartTitle;

  String get notifAnalysisStartBody;

  String get notifAnalysisErrorTitle;

  String get notifAnalysisProgressTitle;

  String get notifAnalysisProgressBody;

  String get notifAnalysisCompleteTitle;

  String get notifAnalysisCompleteBody;

  String get notifAnalysisFailedTitle;

  String get notifAnalysisFailedBody;

  String searchPlaceholderResult(String query);

  String get searchFieldLabelHint;

  String get searchEmptyState;

  String searchSuggestion(String query);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
