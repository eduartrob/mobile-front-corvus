import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @welcomeBack.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido de nuevo'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión con tu cuenta universitaria para acceder.'**
  String get loginSubtitle;

  /// No description provided for @continueWithGoogle.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get continueWithGoogle;

  /// No description provided for @exclusiveAccessInfo.
  ///
  /// In es, this message translates to:
  /// **'Acceso exclusivo para alumnos con dominio institucional activo.'**
  String get exclusiveAccessInfo;

  /// No description provided for @terms.
  ///
  /// In es, this message translates to:
  /// **'Términos'**
  String get terms;

  /// No description provided for @privacy.
  ///
  /// In es, this message translates to:
  /// **'Privacidad'**
  String get privacy;

  /// No description provided for @help.
  ///
  /// In es, this message translates to:
  /// **'Ayuda'**
  String get help;

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'Corvus'**
  String get appTitle;

  /// No description provided for @navInspiration.
  ///
  /// In es, this message translates to:
  /// **'Inspiración'**
  String get navInspiration;

  /// No description provided for @navMyProject.
  ///
  /// In es, this message translates to:
  /// **'Mi Proyecto'**
  String get navMyProject;

  /// No description provided for @navTeams.
  ///
  /// In es, this message translates to:
  /// **'Equipos'**
  String get navTeams;

  /// No description provided for @navProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get navProfile;

  /// No description provided for @welcomeToCorvus.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a Corvus'**
  String get welcomeToCorvus;

  /// No description provided for @welcomeCorvusDesc.
  ///
  /// In es, this message translates to:
  /// **'Corvus analiza y agrupa repositorios académicos para revelar áreas de investigación inexploradas. Descubre oportunidades únicas para tu próximo gran proyecto.'**
  String get welcomeCorvusDesc;

  /// No description provided for @unexploredProjects.
  ///
  /// In es, this message translates to:
  /// **'Proyectos Inexplorados'**
  String get unexploredProjects;

  /// No description provided for @unexploredProjectsDesc.
  ///
  /// In es, this message translates to:
  /// **'Basado en el análisis de +10,000 tesis recientes.'**
  String get unexploredProjectsDesc;

  /// No description provided for @highPotential.
  ///
  /// In es, this message translates to:
  /// **'Alto Potencial'**
  String get highPotential;

  /// No description provided for @explore.
  ///
  /// In es, this message translates to:
  /// **'Explorar'**
  String get explore;

  /// No description provided for @generateIdeas.
  ///
  /// In es, this message translates to:
  /// **'Generar Ideas'**
  String get generateIdeas;

  /// No description provided for @lookingForSomethingDifferent.
  ///
  /// In es, this message translates to:
  /// **'¿Buscas algo diferente?'**
  String get lookingForSomethingDifferent;

  /// No description provided for @lookingForSomethingDifferentDesc.
  ///
  /// In es, this message translates to:
  /// **'Escribe tus temas de interés y nuestra Inteligencia Artificial creará propuestas de investigación únicas y a tu medida.'**
  String get lookingForSomethingDifferentDesc;

  /// No description provided for @searchPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Ej: Energía + Sociología...'**
  String get searchPlaceholder;
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
  // Lookup logic when only language code is specified.
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
