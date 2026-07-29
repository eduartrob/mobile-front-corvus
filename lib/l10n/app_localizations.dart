import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore for file type lint

/// callers can lookup localized strings with an instance of applocalizations
/// returned by applocalizations of context 
///
/// applications need to include applocalizations delegate in their app s
/// localizationdelegates list and the locales they support in the app s
/// supportedlocales list for example 
///
/// dart
/// import l10n app localizations dart 
///
/// return materialapp 
/// localizationsdelegates applocalizations localizationsdelegates 
/// supportedlocales applocalizations supportedlocales 
/// home myapplicationhome 
/// 
/// 
///
/// update pubspec yaml
///
/// please make sure to update your pubspec yaml to include the following
/// packages 
///
/// yaml
/// dependencies 
/// internationalization support 
/// flutter localizations 
/// sdk flutter
/// intl any use the pinned version from flutter localizations
///
/// rest of dependencies
/// 
///
/// ios applications
///
/// ios applications define key application metadata including supported
/// locales in an info plist file that is built into the application bundle 
/// to configure the locales supported by your app you ll need to edit this
/// file 
///
/// first open your project s ios runner xcworkspace xcode workspace file 
/// then in the project navigator open the info plist file under the runner
/// project s runner folder 
///
/// next select the information property list item select add item from the
/// editor menu then select localizations from the pop up menu 
///
/// select and expand the newly created localizations item then for each
/// locale your application supports add a new item and select the locale
/// you wish to add from the pop up menu in the value field this list should
/// be consistent with the languages listed in the applocalizations supportedlocales
/// property 
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// a list of this localizations delegate along with the default localizations
  /// delegates 
  ///
  /// returns a list of localizations delegates containing this delegate along with
  /// globalmateriallocalizations delegate globalcupertinolocalizations delegate 
  /// and globalwidgetslocalizations delegate 
  ///
  /// additional delegates can be added by appending to this list in
  /// materialapp this list does not have to be used at all if a custom list
  /// of delegates is preferred or required 
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// a list of this localizations delegate s supported locales 
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// no description provided for welcomeback 
  ///
  /// in es this message translates to 
  /// bienvenido de nuevo 
  String get welcomeBack;

  /// no description provided for loginsubtitle 
  ///
  /// in es this message translates to 
  /// inicia sesión con tu cuenta universitaria para acceder 
  String get loginSubtitle;

  /// no description provided for continuewithgoogle 
  ///
  /// in es this message translates to 
  /// continuar con google 
  String get continueWithGoogle;

  /// no description provided for signingin 
  ///
  /// in es this message translates to 
  /// iniciando sesión 
  String get signingIn;

  /// no description provided for login 
  ///
  /// in es this message translates to 
  /// iniciar sesión 
  String get login;

  /// no description provided for register 
  ///
  /// in es this message translates to 
  /// registrarse 
  String get register;

  /// no description provided for email 
  ///
  /// in es this message translates to 
  /// correo electrónico 
  String get email;

  /// no description provided for password 
  ///
  /// in es this message translates to 
  /// contraseña 
  String get password;

  /// no description provided for confirmpassword 
  ///
  /// in es this message translates to 
  /// confirmar contraseña 
  String get confirmPassword;

  /// no description provided for forgotpassword 
  ///
  /// in es this message translates to 
  /// olvidaste tu contraseña 
  String get forgotPassword;

  /// no description provided for noaccount 
  ///
  /// in es this message translates to 
  /// no tienes una cuenta 
  String get noAccount;

  /// no description provided for haveaccount 
  ///
  /// in es this message translates to 
  /// ya tienes una cuenta 
  String get haveAccount;

  /// no description provided for loginwithemail 
  ///
  /// in es this message translates to 
  /// iniciar sesión con correo 
  String get loginWithEmail;

  /// no description provided for registerwithemail 
  ///
  /// in es this message translates to 
  /// registrarse con correo 
  String get registerWithEmail;

  /// no description provided for orcontinuewith 
  ///
  /// in es this message translates to 
  /// o continuar con 
  String get orContinueWith;

  /// no description provided for orregisterwith 
  ///
  /// in es this message translates to 
  /// o registrarse con 
  String get orRegisterWith;

  /// no description provided for student 
  ///
  /// in es this message translates to 
  /// alumno 
  String get student;

  /// no description provided for teacher 
  ///
  /// in es this message translates to 
  /// docente 
  String get teacher;

  /// no description provided for selectrole 
  ///
  /// in es this message translates to 
  /// selecciona tu rol 
  String get selectRole;

  /// no description provided for roleselectionsubtitle 
  ///
  /// in es this message translates to 
  /// elige cómo quieres acceder a corvus hoy 
  String get roleSelectionSubtitle;

  /// no description provided for loginasstudent 
  ///
  /// in es this message translates to 
  /// iniciar sesión como alumno 
  String get loginAsStudent;

  /// no description provided for loginasteacher 
  ///
  /// in es this message translates to 
  /// iniciar sesión como docente 
  String get loginAsTeacher;

  /// no description provided for registerasstudent 
  ///
  /// in es this message translates to 
  /// registrarse como alumno 
  String get registerAsStudent;

  /// no description provided for registerasteacher 
  ///
  /// in es this message translates to 
  /// registrarse como docente 
  String get registerAsTeacher;

  /// no description provided for welcometo 
  ///
  /// in es this message translates to 
  /// bienvenido a 
  String get welcomeTo;

  /// no description provided for universityemailhint 
  ///
  /// in es this message translates to 
  /// se recomienda correo institucional 
  String get universityEmailHint;

  /// no description provided for swipetochange 
  ///
  /// in es this message translates to 
  /// desliza para cambiar de rol 
  String get swipeToChange;

  /// no description provided for invalidemail 
  ///
  /// in es this message translates to 
  /// por favor ingresa un correo válido 
  String get invalidEmail;

  /// no description provided for invalidpassword 
  ///
  /// in es this message translates to 
  /// la contraseña debe tener al menos 6 caracteres 
  String get invalidPassword;

  /// no description provided for passwordmismatch 
  ///
  /// in es this message translates to 
  /// las contraseñas no coinciden 
  String get passwordMismatch;

  /// no description provided for requiredfield 
  ///
  /// in es this message translates to 
  /// este campo es obligatorio 
  String get requiredField;

  /// no description provided for termsofuse 
  ///
  /// in es this message translates to 
  /// al continuar aceptas nuestros 
  String get termsOfUse;

  /// no description provided for unknownerror 
  ///
  /// in es this message translates to 
  /// ocurrió un error desconocido 
  String get unknownError;

  /// no description provided for exclusiveaccessinfo 
  ///
  /// in es this message translates to 
  /// acceso exclusivo para alumnos con dominio institucional activo 
  String get exclusiveAccessInfo;

  /// no description provided for terms 
  ///
  /// in es this message translates to 
  /// términos 
  String get terms;

  /// no description provided for privacy 
  ///
  /// in es this message translates to 
  /// privacidad 
  String get privacy;

  /// no description provided for help 
  ///
  /// in es this message translates to 
  /// ayuda 
  String get help;

  /// no description provided for apptitle 
  ///
  /// in es this message translates to 
  /// corvus 
  String get appTitle;

  /// no description provided for and 
  ///
  /// in es this message translates to 
  /// y 
  String get and;

  /// no description provided for privacypolicy 
  ///
  /// in es this message translates to 
  /// política de privacidad 
  String get privacyPolicy;

  /// no description provided for termsofservice 
  ///
  /// in es this message translates to 
  /// términos de servicio 
  String get termsOfService;

  /// no description provided for navinspiration 
  ///
  /// in es this message translates to 
  /// inspiración 
  String get navInspiration;

  /// no description provided for navmyproject 
  ///
  /// in es this message translates to 
  /// mi proyecto 
  String get navMyProject;

  /// no description provided for navteams 
  ///
  /// in es this message translates to 
  /// equipos 
  String get navTeams;

  /// no description provided for navprofile 
  ///
  /// in es this message translates to 
  /// perfil 
  String get navProfile;

  /// no description provided for navsearch 
  ///
  /// in es this message translates to 
  /// buscar 
  String get navSearch;

  /// no description provided for navprojects 
  ///
  /// in es this message translates to 
  /// proyectos 
  String get navProjects;

  /// no description provided for welcometocorvus 
  ///
  /// in es this message translates to 
  /// bienvenido a corvus 
  String get welcomeToCorvus;

  /// no description provided for welcomecorvusdesc 
  ///
  /// in es this message translates to 
  /// corvus analiza y agrupa repositorios académicos para revelar áreas de investigación inexploradas descubre oportunidades únicas para tu próximo gran proyecto 
  String get welcomeCorvusDesc;

  /// no description provided for unexploredprojects 
  ///
  /// in es this message translates to 
  /// proyectos inexplorados 
  String get unexploredProjects;

  /// no description provided for unexploredprojectsdesc 
  ///
  /// in es this message translates to 
  /// basado en el análisis de 10 000 tesis recientes 
  String get unexploredProjectsDesc;

  /// no description provided for highpotential 
  ///
  /// in es this message translates to 
  /// alto potencial 
  String get highPotential;

  /// no description provided for explore 
  ///
  /// in es this message translates to 
  /// explorar 
  String get explore;

  /// no description provided for generateideas 
  ///
  /// in es this message translates to 
  /// generar ideas 
  String get generateIdeas;

  /// no description provided for lookingforsomethingdifferent 
  ///
  /// in es this message translates to 
  /// buscas algo diferente 
  String get lookingForSomethingDifferent;

  /// no description provided for lookingforsomethingdifferentdesc 
  ///
  /// in es this message translates to 
  /// escribe tus temas de interés y nuestra inteligencia artificial creará propuestas de investigación únicas y a tu medida 
  String get lookingForSomethingDifferentDesc;

  /// no description provided for searchplaceholder 
  ///
  /// in es this message translates to 
  /// ej energía sociología 
  String get searchPlaceholder;

  /// no description provided for profnavdash 
  ///
  /// in es this message translates to 
  /// tablero 
  String get profNavDash;

  /// no description provided for profnavreviews 
  ///
  /// in es this message translates to 
  /// revisiones 
  String get profNavReviews;

  /// no description provided for profnavrules 
  ///
  /// in es this message translates to 
  /// reglas 
  String get profNavRules;

  /// no description provided for profnavhistory 
  ///
  /// in es this message translates to 
  /// historial 
  String get profNavHistory;

  /// no description provided for featureupcoming 
  ///
  /// in es this message translates to 
  /// función disponible en el próximo release académico 
  String get featureUpcoming;

  /// no description provided for manage 
  ///
  /// in es this message translates to 
  /// gestionar 
  String get manage;

  /// no description provided for generateworkplan 
  ///
  /// in es this message translates to 
  /// generar plan de trabajo 
  String get generateWorkPlan;

  /// no description provided for leaveteam 
  ///
  /// in es this message translates to 
  /// salir del equipo 
  String get leaveTeam;

  /// no description provided for teammanagementtitle 
  ///
  /// in es this message translates to 
  /// gestión de equipo 
  String get teamManagementTitle;

  /// no description provided for teammanagementdesc 
  ///
  /// in es this message translates to 
  /// proyecto final implementación de rag para análisis documental administra los miembros de tu grupo de investigación 
  String get teamManagementDesc;

  /// no description provided for teamfull 
  ///
  /// in es this message translates to 
  /// equipo completo 
  String get teamFull;

  /// no description provided for members 
  ///
  /// in es this message translates to 
  /// integrantes 
  String get members;

  /// no description provided for pendinginvitations 
  ///
  /// in es this message translates to 
  /// invitaciones pendientes 
  String get pendingInvitations;

  /// no description provided for twodaysago 
  ///
  /// in es this message translates to 
  /// hace 2 días 
  String get twoDaysAgo;

  /// no description provided for teamfullinvitenotice 
  ///
  /// in es this message translates to 
  /// el equipo está lleno cancela una invitación para invitar a alguien más 
  String get teamFullInviteNotice;

  /// no description provided for aiassistantteamsuggestionspan1 
  ///
  /// in es this message translates to 
  /// basado en los perfiles de tu equipo tienen una 
  String get aiAssistantTeamSuggestionSpan1;

  /// no description provided for aiassistantteamsuggestionspan2 
  ///
  /// in es this message translates to 
  /// fuerte cobertura 
  String get aiAssistantTeamSuggestionSpan2;

  /// no description provided for aiassistantteamsuggestionspan3 
  ///
  /// in es this message translates to 
  /// en backend y frontend se sugiere asignar tareas de 
  String get aiAssistantTeamSuggestionSpan3;

  /// no description provided for aiassistantteamsuggestionspan4 
  ///
  /// in es this message translates to 
  /// documentación y pruebas unitarias 
  String get aiAssistantTeamSuggestionSpan4;

  /// no description provided for aiassistantteamsuggestionspan5 
  ///
  /// in es this message translates to 
  /// equitativamente para el próximo sprint 
  String get aiAssistantTeamSuggestionSpan5;

  /// no description provided for youleader 
  ///
  /// in es this message translates to 
  /// tú líder 
  String get youLeader;

  /// no description provided for registerrule 
  ///
  /// in es this message translates to 
  /// registrar regla 
  String get registerRule;

  /// no description provided for viewreports 
  ///
  /// in es this message translates to 
  /// ver todos los reportes 
  String get viewReports;

  /// no description provided for citeteam 
  ///
  /// in es this message translates to 
  /// citar equipo 
  String get citeTeam;

  /// no description provided for approve 
  ///
  /// in es this message translates to 
  /// aprobar 
  String get approve;

  /// no description provided for reject 
  ///
  /// in es this message translates to 
  /// rechazar 
  String get reject;

  /// no description provided for accept 
  ///
  /// in es this message translates to 
  /// aceptar 
  String get accept;

  /// no description provided for delete 
  ///
  /// in es this message translates to 
  /// eliminar 
  String get delete;

  /// no description provided for cancel 
  ///
  /// in es this message translates to 
  /// cancelar 
  String get cancel;

  /// no description provided for retry 
  ///
  /// in es this message translates to 
  /// reintentar 
  String get retry;

  /// no description provided for savechanges 
  ///
  /// in es this message translates to 
  /// guardar cambios 
  String get saveChanges;

  /// no description provided for gpa 
  ///
  /// in es this message translates to 
  /// promedio 
  String get gpa;

  /// no description provided for projects 
  ///
  /// in es this message translates to 
  /// proyectos 
  String get projects;

  /// no description provided for technicalskills 
  ///
  /// in es this message translates to 
  /// habilidades técnicas 
  String get technicalSkills;

  /// no description provided for recentactivity 
  ///
  /// in es this message translates to 
  /// actividad reciente 
  String get recentActivity;

  /// no description provided for ragengineupdate 
  ///
  /// in es this message translates to 
  /// actualización en rag core engine 
  String get ragEngineUpdate;

  /// no description provided for timetwohoursago 
  ///
  /// in es this message translates to 
  /// hace 2h 
  String get timeTwoHoursAgo;

  /// no description provided for readingcompleted 
  ///
  /// in es this message translates to 
  /// lectura completada narquitecturas transformer 
  String get readingCompleted;

  /// no description provided for timeyesterday 
  ///
  /// in es this message translates to 
  /// ayer 
  String get timeYesterday;

  /// no description provided for appearance 
  ///
  /// in es this message translates to 
  /// apariencia 
  String get appearance;

  /// no description provided for themesystem 
  ///
  /// in es this message translates to 
  /// sistema 
  String get themeSystem;

  /// no description provided for themelight 
  ///
  /// in es this message translates to 
  /// claro 
  String get themeLight;

  /// no description provided for themedark 
  ///
  /// in es this message translates to 
  /// oscuro 
  String get themeDark;

  /// no description provided for logout 
  ///
  /// in es this message translates to 
  /// cerrar sesión 
  String get logout;

  /// no description provided for errorcredentialsdrivecorvus 
  ///
  /// in es this message translates to 
  /// error no se pudo obtener las credenciales necesarias drive o corvus 
  String get errorCredentialsDriveCorvus;

  /// no description provided for folderalreadylinked 
  ///
  /// in es this message translates to 
  /// carpeta vinculada ya estaba sincronizada previamente en corvus 
  String get folderAlreadyLinked;

  /// no description provided for folderlinkedprocessingstarted 
  ///
  /// in es this message translates to 
  /// carpeta vinculada el procesamiento ha comenzado en segundo plano 
  String get folderLinkedProcessingStarted;

  /// no description provided for removeaccesstitle 
  ///
  /// in es this message translates to 
  /// quitar acceso 
  String get removeAccessTitle;

  /// no description provided for remove 
  ///
  /// in es this message translates to 
  /// quitar 
  String get remove;

  /// no description provided for driveaccessrequired 
  ///
  /// in es this message translates to 
  /// se requiere acceso a drive para sincronizar 
  String get driveAccessRequired;

  /// no description provided for sendforreview 
  ///
  /// in es this message translates to 
  /// enviar para revisión 
  String get sendForReview;

  /// no description provided for browsefiles 
  ///
  /// in es this message translates to 
  /// explorar archivos 
  String get browseFiles;

  /// no description provided for understood 
  ///
  /// in es this message translates to 
  /// entendido 
  String get understood;

  /// no description provided for detailedanalysistitle 
  ///
  /// in es this message translates to 
  /// análisis detallado 
  String get detailedAnalysisTitle;

  /// no description provided for prevalidationtitle 
  ///
  /// in es this message translates to 
  /// pre validación de propuesta 
  String get preValidationTitle;

  /// no description provided for detailedanalysisdesc 
  ///
  /// in es this message translates to 
  /// la ia ha evaluado tu documento revisa las métricas clave y las recomendaciones para elevar la calidad de tu proyecto antes de la entrega final 
  String get detailedAnalysisDesc;

  /// no description provided for prevalidationdesc 
  ///
  /// in es this message translates to 
  /// sube tu documento pdf nuestro motor de ia analizará tu propuesta contra los requerimientos académicos antes de la entrega final 
  String get preValidationDesc;

  /// no description provided for analyzingstructure 
  ///
  /// in es this message translates to 
  /// analizando estructura 
  String get analyzingStructure;

  /// no description provided for deletedraft 
  ///
  /// in es this message translates to 
  /// eliminar borrador 
  String get deleteDraft;

  /// no description provided for uploadanotherproposal 
  ///
  /// in es this message translates to 
  /// cargar otra propuesta 
  String get uploadAnotherProposal;

  /// no description provided for analysisestimatedtime 
  ///
  /// in es this message translates to 
  /// el análisis puede tardar entre 30 y 90 segundos ndependiendo del modelo de ia del servidor 
  String get analysisEstimatedTime;

  /// no description provided for loadingphase1 
  ///
  /// in es this message translates to 
  /// analizando el contenido de tu documento 
  String get loadingPhase1;

  /// no description provided for loadingphase2 
  ///
  /// in es this message translates to 
  /// limpiando y anonimizando el texto 
  String get loadingPhase2;

  /// no description provided for loadingphase3 
  ///
  /// in es this message translates to 
  /// vectorizando el contenido con ia semántica 
  String get loadingPhase3;

  /// no description provided for loadingphase4 
  ///
  /// in es this message translates to 
  /// buscando proyectos similares en el repositorio histórico 
  String get loadingPhase4;

  /// no description provided for loadingphase5 
  ///
  /// in es this message translates to 
  /// calculando el riesgo de colisión semántica 
  String get loadingPhase5;

  /// no description provided for loadingphase6 
  ///
  /// in es this message translates to 
  /// el comité académico está redactando el dictamen 
  String get loadingPhase6;

  /// no description provided for loadingphase7 
  ///
  /// in es this message translates to 
  /// generando recomendaciones técnicas personalizadas 
  String get loadingPhase7;

  /// no description provided for loadingphase8 
  ///
  /// in es this message translates to 
  /// afinando el veredicto final casi listo 
  String get loadingPhase8;

  /// no description provided for uploadzonetitle 
  ///
  /// in es this message translates to 
  /// arrastra tu propuesta pdf aquí 
  String get uploadZoneTitle;

  /// no description provided for uploadzonesubtitle 
  ///
  /// in es this message translates to 
  /// tamaño máximo 10mb formatos pdf 
  String get uploadZoneSubtitle;

  /// no description provided for uploadedtoday 
  ///
  /// in es this message translates to 
  /// subido hoy 
  String get uploadedToday;

  /// no description provided for servererrorcontactsupport 
  ///
  /// in es this message translates to 
  /// ocurrió un inconveniente temporal en el servidor por favor reintenta en un momento o contacta a soporte supportemail 
  String serverErrorContactSupport(String supportEmail);

  /// no description provided for loginerrornotallowedemail 
  ///
  /// in es this message translates to 
  /// fallo al iniciar sesión el correo no está permitido solo se aceptan correos institucionales de la universidad 
  String get loginErrorNotAllowedEmail;

  /// no description provided for invaliddocumenttitle 
  ///
  /// in es this message translates to 
  /// documento no válido 
  String get invalidDocumentTitle;

  /// no description provided for invaliddocumentdesc 
  ///
  /// in es this message translates to 
  /// el archivo que subiste no parece ser una propuesta de proyecto integrador asegúrate de subir tu propuesta con secciones como objetivo metodología y tecnologías 
  String get invalidDocumentDesc;

  /// no description provided for invaliddocumentaction 
  ///
  /// in es this message translates to 
  /// cargar otro documento 
  String get invalidDocumentAction;

  /// no description provided for blueoceangenericcategory 
  ///
  /// in es this message translates to 
  /// innovación académica 
  String get blueOceanGenericCategory;

  /// no description provided for blueoceangenerictag 
  ///
  /// in es this message translates to 
  /// océano azul real 
  String get blueOceanGenericTag;

  /// no description provided for blueoceangenericdesc 
  ///
  /// in es this message translates to 
  /// este proyecto ha sido clasificado como una anomalía semántica de alta varianza indicando un enfoque único e inexplorado respecto a todos los demás trabajos en la base de datos 
  String get blueOceanGenericDesc;

  /// no description provided for notifuploadtitle 
  ///
  /// in es this message translates to 
  /// subiendo propuesta 
  String get notifUploadTitle;

  /// no description provided for notifuploadbody 
  ///
  /// in es this message translates to 
  /// analizando estructura rag rápida 
  String get notifUploadBody;

  /// no description provided for notifprevalidreadytitle 
  ///
  /// in es this message translates to 
  /// pre validación lista 
  String get notifPreValidReadyTitle;

  /// no description provided for notifprevalidreadybody 
  ///
  /// in es this message translates to 
  /// puedes revisar las heurísticas iniciales 
  String get notifPreValidReadyBody;

  /// no description provided for notiferrortitle 
  ///
  /// in es this message translates to 
  /// error 
  String get notifErrorTitle;

  /// no description provided for notifprevalidfailed 
  ///
  /// in es this message translates to 
  /// falló la pre validación 
  String get notifPreValidFailed;

  /// no description provided for notifanalysisstarttitle 
  ///
  /// in es this message translates to 
  /// análisis detallado 
  String get notifAnalysisStartTitle;

  /// no description provided for notifanalysisstartbody 
  ///
  /// in es this message translates to 
  /// la ia está evaluando rigurosidad y originalidad 
  String get notifAnalysisStartBody;

  /// no description provided for notifanalysiserrortitle 
  ///
  /// in es this message translates to 
  /// error al iniciar análisis 
  String get notifAnalysisErrorTitle;

  /// no description provided for notifanalysisprogresstitle 
  ///
  /// in es this message translates to 
  /// corvus ia 
  String get notifAnalysisProgressTitle;

  /// no description provided for notifanalysisprogressbody 
  ///
  /// in es this message translates to 
  /// analizando tu propuesta de proyecto 
  String get notifAnalysisProgressBody;

  /// no description provided for notifanalysiscompletetitle 
  ///
  /// in es this message translates to 
  /// análisis completado 
  String get notifAnalysisCompleteTitle;

  /// no description provided for notifanalysiscompletebody 
  ///
  /// in es this message translates to 
  /// tu dictamen técnico está listo abre la app para revisarlo 
  String get notifAnalysisCompleteBody;

  /// no description provided for notifanalysisfailedtitle 
  ///
  /// in es this message translates to 
  /// análisis no completado 
  String get notifAnalysisFailedTitle;

  /// no description provided for notifanalysisfailedbody 
  ///
  /// in es this message translates to 
  /// el servidor encontró un error 
  String get notifAnalysisFailedBody;

  /// no description provided for searchplaceholderresult 
  ///
  /// in es this message translates to 
  /// resultados para query n pronto conectado a la ia 
  String searchPlaceholderResult(String query);

  /// no description provided for searchfieldlabelhint 
  ///
  /// in es this message translates to 
  /// buscar proyectos o temas 
  String get searchFieldLabelHint;

  /// no description provided for searchemptystate 
  ///
  /// in es this message translates to 
  /// escribe un tema de investigación 
  String get searchEmptyState;

  /// no description provided for searchsuggestion 
  ///
  /// in es this message translates to 
  /// buscar query en todos los repositorios 
  String searchSuggestion(String query);

  /// no description provided for manageteamtitle 
  ///
  /// in es this message translates to 
  /// gestionar equipo 
  String get manageTeamTitle;

  /// no description provided for teamnamelabel 
  ///
  /// in es this message translates to 
  /// nombre del equipo 
  String get teamNameLabel;

  /// no description provided for teamnamehint 
  ///
  /// in es this message translates to 
  /// escribe el nombre del equipo 
  String get teamNameHint;

  /// no description provided for teamnamerequired 
  ///
  /// in es this message translates to 
  /// el nombre del equipo es obligatorio 
  String get teamNameRequired;

  /// no description provided for teamdescriptionlabel 
  ///
  /// in es this message translates to 
  /// descripción del equipo opcional 
  String get teamDescriptionLabel;

  /// no description provided for teamdescriptionhint 
  ///
  /// in es this message translates to 
  /// añade una descripción amigable 
  String get teamDescriptionHint;

  /// no description provided for sociallinkstitle 
  ///
  /// in es this message translates to 
  /// enlaces a grupos de redes sociales 
  String get socialLinksTitle;

  /// no description provided for sociallinksdesc 
  ///
  /// in es this message translates to 
  /// agrega enlaces para que los integrantes se unan a tus canales oficiales 
  String get socialLinksDesc;

  /// no description provided for socialplatformhint 
  ///
  /// in es this message translates to 
  /// red ej discord 
  String get socialPlatformHint;

  /// no description provided for sociallinkrequired 
  ///
  /// in es this message translates to 
  /// por favor ingresa el nombre de la red social y la url 
  String get socialLinkRequired;

  /// no description provided for socialurlinvalid 
  ///
  /// in es this message translates to 
  /// la url debe comenzar con http o https 
  String get socialUrlInvalid;

  /// no description provided for teamsettingssaved 
  ///
  /// in es this message translates to 
  /// configuración del equipo guardada con éxito 
  String get teamSettingsSaved;

  /// no description provided for teamsettingserror 
  ///
  /// in es this message translates to 
  /// error al guardar cambios error 
  String teamSettingsError(String error);

  /// no description provided for myteam 
  ///
  /// in es this message translates to 
  /// mi equipo 
  String get myTeam;

  /// no description provided for virtualteamdesc 
  ///
  /// in es this message translates to 
  /// crea tu equipo personalizando el nombre en el botón gestionar de la derecha y busca integrantes en la pestaña sugerencias 
  String get virtualTeamDesc;

  /// no description provided for studentdefaultname 
  ///
  /// in es this message translates to 
  /// estudiante 
  String get studentDefaultName;

  /// no description provided for yourteambadge 
  ///
  /// in es this message translates to 
  /// tu equipo 
  String get yourTeamBadge;

  /// no description provided for teammemberscount 
  ///
  /// in es this message translates to 
  /// count max miembros 
  String teamMembersCount(String count, String max);

  /// no description provided for missingonemember 
  ///
  /// in es this message translates to 
  /// te falta 1 integrante 
  String get missingOneMember;

  /// no description provided for missingmembers 
  ///
  /// in es this message translates to 
  /// te faltan count integrantes 
  String missingMembers(String count);

  /// no description provided for searchmembers 
  ///
  /// in es this message translates to 
  /// buscar integrantes 
  String get searchMembers;

  /// no description provided for proposalsent 
  ///
  /// in es this message translates to 
  /// propuesta enviada 
  String get proposalSent;

  /// no description provided for proposalapproved 
  ///
  /// in es this message translates to 
  /// propuesta aprobada 
  String get proposalApproved;

  /// no description provided for proposalrejected 
  ///
  /// in es this message translates to 
  /// propuesta rechazada 
  String get proposalRejected;

  /// no description provided for summonedforreview 
  ///
  /// in es this message translates to 
  /// citados a revisión 
  String get summonedForReview;

  /// no description provided for proposalstatusunknown 
  ///
  /// in es this message translates to 
  /// estado de propuesta desconocido 
  String get proposalStatusUnknown;

  /// no description provided for proposalpendingdesc 
  ///
  /// in es this message translates to 
  /// el profesorado revisará pronto tu proyecto 
  String get proposalPendingDesc;

  /// no description provided for proposalapproveddesc 
  ///
  /// in es this message translates to 
  /// felicidades pueden continuar con el proyecto 
  String get proposalApprovedDesc;

  /// no description provided for proposalrejecteddesc 
  ///
  /// in es this message translates to 
  /// la propuesta no cumple con los criterios académicos 
  String get proposalRejectedDesc;

  /// no description provided for appointmentdate 
  ///
  /// in es this message translates to 
  /// fecha date 
  String appointmentDate(String date);

  /// no description provided for appointmentlocation 
  ///
  /// in es this message translates to 
  /// lugar enlace location 
  String appointmentLocation(String location);

  /// no description provided for searchresults 
  ///
  /// in es this message translates to 
  /// resultados de búsqueda 
  String get searchResults;

  /// no description provided for recommendedforyou 
  ///
  /// in es this message translates to 
  /// recomendados para ti 
  String get recommendedForYou;

  /// no description provided for errorloadingsuggestions 
  ///
  /// in es this message translates to 
  /// error al cargar sugerencias n error 
  String errorLoadingSuggestions(String error);

  /// no description provided for nosuggestionsfound 
  ///
  /// in es this message translates to 
  /// no hay sugerencias encontradas 
  String get noSuggestionsFound;

  /// no description provided for invitationsent 
  ///
  /// in es this message translates to 
  /// invitación enviada a name 
  String invitationSent(String name);

  /// no description provided for errorsendinginvitation 
  ///
  /// in es this message translates to 
  /// error al enviar invitación error 
  String errorSendingInvitation(String error);

  /// no description provided for received 
  ///
  /// in es this message translates to 
  /// recibidas 
  String get received;

  /// no description provided for sent 
  ///
  /// in es this message translates to 
  /// enviadas 
  String get sent;

  /// no description provided for norequests 
  ///
  /// in es this message translates to 
  /// no hay solicitudes en esta sección 
  String get noRequests;

  /// no description provided for requestcancelled 
  ///
  /// in es this message translates to 
  /// solicitud cancelada rechazada 
  String get requestCancelled;

  /// no description provided for invitationaccepted 
  ///
  /// in es this message translates to 
  /// invitación aceptada te has unido al equipo 
  String get invitationAccepted;

  /// no description provided for wantstojoingroup 
  ///
  /// in es this message translates to 
  /// quiere unirse a tu grupo 
  String get wantsToJoinGroup;

  /// no description provided for invitedtogroup 
  ///
  /// in es this message translates to 
  /// te invitó a formar parte de su grupo 
  String get invitedToGroup;

  /// no description provided for teamsformed 
  ///
  /// in es this message translates to 
  /// equipos formados 
  String get teamsFormed;

  /// no description provided for proposalsready 
  ///
  /// in es this message translates to 
  /// propuestas listas 
  String get proposalsReady;

  /// no description provided for proposalsreadydetail 
  ///
  /// in es this message translates to 
  /// ready de total equipos 
  String proposalsReadyDetail(String ready, String total);

  /// no description provided for attentionrequired 
  ///
  /// in es this message translates to 
  /// atención requerida 
  String get attentionRequired;

  /// no description provided for alluptodate 
  ///
  /// in es this message translates to 
  /// todo al día no hay elementos que requieran atención inmediata 
  String get allUpToDate;

  /// no description provided for quickmetrics 
  ///
  /// in es this message translates to 
  /// métricas rápidas 
  String get quickMetrics;

  /// no description provided for studentswithteam 
  ///
  /// in es this message translates to 
  /// count alumnos con equipo 
  String studentsWithTeam(String count);

  /// no description provided for studentswithoutteam 
  ///
  /// in es this message translates to 
  /// count alumnos rezagados sin equipo 
  String studentsWithoutTeam(String count);

  /// no description provided for viewlaggingstudentsdirectory 
  ///
  /// in es this message translates to 
  /// ver directorio de alumnos rezagados 
  String get viewLaggingStudentsDirectory;

  /// no description provided for sessionexpired 
  ///
  /// in es this message translates to 
  /// tu sesión ha expirado por favor inicia sesión de nuevo 
  String get sessionExpired;

  /// no description provided for doubletaptoexit 
  ///
  /// in es this message translates to 
  /// toca volver de nuevo para salir 
  String get doubleTapToExit;

  /// no description provided for chatunderconstruction 
  ///
  /// in es this message translates to 
  /// chat grupal con ia en construcción 
  String get chatUnderConstruction;

  /// no description provided for maxskillsselected 
  ///
  /// in es this message translates to 
  /// puedes seleccionar un máximo de 10 habilidades 
  String get maxSkillsSelected;

  /// no description provided for selectatleastoneskill 
  ///
  /// in es this message translates to 
  /// selecciona al menos una habilidad 
  String get selectAtLeastOneSkill;

  /// no description provided for selectyourskills 
  ///
  /// in es this message translates to 
  /// selecciona tus habilidades 
  String get selectYourSkills;

  /// no description provided for chooseskillssubtitle 
  ///
  /// in es this message translates to 
  /// elige hasta 10 habilidades que deseas obtener o mejorar en tu carrera selected max 
  String chooseSkillsSubtitle(String selected, String max);

  /// no description provided for saving 
  ///
  /// in es this message translates to 
  /// guardando 
  String get saving;

  /// no description provided for finish 
  ///
  /// in es this message translates to 
  /// finalizar 
  String get finish;

  /// no description provided for completeallrequiredfields 
  ///
  /// in es this message translates to 
  /// por favor completa todos los campos requeridos 
  String get completeAllRequiredFields;

  /// no description provided for selectvaliduniversity 
  ///
  /// in es this message translates to 
  /// por favor selecciona una universidad válida de la lista 
  String get selectValidUniversity;

  /// no description provided for statuspending 
  ///
  /// in es this message translates to 
  /// pendiente 
  String get statusPending;

  /// no description provided for statusapproved 
  ///
  /// in es this message translates to 
  /// aprobada 
  String get statusApproved;

  /// no description provided for statusrejected 
  ///
  /// in es this message translates to 
  /// rechazada 
  String get statusRejected;

  /// no description provided for statussummoned 
  ///
  /// in es this message translates to 
  /// citada 
  String get statusSummoned;

  /// no description provided for noproposalstoreview 
  ///
  /// in es this message translates to 
  /// no hay propuestas para revisión 
  String get noProposalsToReview;

  /// no description provided for teamlabel 
  ///
  /// in es this message translates to 
  /// equipo name 
  String teamLabel(String name);

  /// no description provided for memberslabel 
  ///
  /// in es this message translates to 
  /// integrantes members 
  String membersLabel(String members);

  /// no description provided for untitledproposal 
  ///
  /// in es this message translates to 
  /// propuesta sin título 
  String get untitledProposal;

  /// no description provided for projectproposal 
  ///
  /// in es this message translates to 
  /// propuesta de proyecto 
  String get projectProposal;

  /// no description provided for unnamedteam 
  ///
  /// in es this message translates to 
  /// equipo sin nombre 
  String get unnamedTeam;

  /// no description provided for namerequired 
  ///
  /// in es this message translates to 
  /// el nombre es requerido 
  String get nameRequired;

  /// no description provided for errorcreating 
  ///
  /// in es this message translates to 
  /// error al crear 
  String get errorCreating;

  /// no description provided for projectcreated 
  ///
  /// in es this message translates to 
  /// proyecto creado 
  String get projectCreated;

  /// no description provided for sharecodemessage 
  ///
  /// in es this message translates to 
  /// comparte este código de acceso con tus alumnos para que puedan unirse y formar equipos 
  String get shareCodeMessage;

  /// no description provided for codecopied 
  ///
  /// in es this message translates to 
  /// código copiado al portapapeles 
  String get codeCopied;

  /// no description provided for copy 
  ///
  /// in es this message translates to 
  /// copiar 
  String get copy;

  /// no description provided for newproject 
  ///
  /// in es this message translates to 
  /// nuevo proyecto 
  String get newProject;

  /// no description provided for newprojectdesc 
  ///
  /// in es this message translates to 
  /// al crear un proyecto se generará un código para que tus alumnos se unan 
  String get newProjectDesc;

  /// no description provided for projectnamelabel 
  ///
  /// in es this message translates to 
  /// nombre del proyecto 
  String get projectNameLabel;

  /// no description provided for projectnamehint 
  ///
  /// in es this message translates to 
  /// ej proyecto final integradora 
  String get projectNameHint;

  /// no description provided for descriptionoptional 
  ///
  /// in es this message translates to 
  /// descripción opcional 
  String get descriptionOptional;

  /// no description provided for descriptionhint 
  ///
  /// in es this message translates to 
  /// detalles del proyecto 
  String get descriptionHint;

  /// no description provided for maxteamsize 
  ///
  /// in es this message translates to 
  /// tamaño máximo del equipo 
  String get maxTeamSize;

  /// no description provided for creating 
  ///
  /// in es this message translates to 
  /// creando 
  String get creating;

  /// no description provided for createproject 
  ///
  /// in es this message translates to 
  /// crear proyecto 
  String get createProject;

  /// no description provided for join 
  ///
  /// in es this message translates to 
  /// unirse 
  String get join;

  /// no description provided for noclassesyet 
  ///
  /// in es this message translates to 
  /// aún no tienes clases 
  String get noClassesYet;

  /// no description provided for noclassesdesc 
  ///
  /// in es this message translates to 
  /// únete a una clase ingresando el código que te proporcionó tu profesor para comenzar tu proyecto 
  String get noClassesDesc;

  /// no description provided for joinclass 
  ///
  /// in es this message translates to 
  /// unirse a una clase 
  String get joinClass;

  /// no description provided for defaultprojectname 
  ///
  /// in es this message translates to 
  /// proyecto 
  String get defaultProjectName;

  /// no description provided for noprojectyet 
  ///
  /// in es this message translates to 
  /// aún no perteneces a ningún proyecto 
  String get noProjectYet;

  /// no description provided for noprojectdesc 
  ///
  /// in es this message translates to 
  /// para poder formar un equipo y subir tu propuesta primero debes unirte a la clase de tu profesor usando su código de acceso 
  String get noProjectDesc;

  /// no description provided for joinproject 
  ///
  /// in es this message translates to 
  /// unirse a un proyecto 
  String get joinProject;

  /// no description provided for noteam 
  ///
  /// in es this message translates to 
  /// no tienes un equipo 
  String get noTeam;

  /// no description provided for noteamdesc 
  ///
  /// in es this message translates to 
  /// debes unirte o crear un equipo en la pestaña de equipos para poder enviar una propuesta 
  String get noTeamDesc;

  /// no description provided for navprojectslabel 
  ///
  /// in es this message translates to 
  /// proyectos 
  String get navProjectsLabel;

  /// no description provided for networkerror 
  ///
  /// in es this message translates to 
  /// problema de conexión a internet verifica tu red e inténtalo de nuevo 
  String get networkError;

  /// no description provided for filetoolarge 
  ///
  /// in es this message translates to 
  /// el archivo excede el tamaño máximo permitido 
  String get fileTooLarge;

  /// no description provided for unsupportedfiletype 
  ///
  /// in es this message translates to 
  /// tipo de archivo no soportado 
  String get unsupportedFileType;

  /// no description provided for requesttimeout 
  ///
  /// in es this message translates to 
  /// la petición tardó demasiado verifica tu conexión e inténtalo de nuevo 
  String get requestTimeout;

  /// no description provided for unexpectederror 
  ///
  /// in es this message translates to 
  /// ocurrió un error inesperado por favor reintenta en un momento 
  String get unexpectedError;

  /// no description provided for forbiddenaction 
  ///
  /// in es this message translates to 
  /// no tienes permiso para realizar esta acción 
  String get forbiddenAction;

  /// no description provided for resourcenotfound 
  ///
  /// in es this message translates to 
  /// el recurso solicitado no fue encontrado 
  String get resourceNotFound;

  /// no description provided for toomanyrequests 
  ///
  /// in es this message translates to 
  /// demasiadas solicitudes espera un momento e intenta de nuevo 
  String get tooManyRequests;

  /// no description provided for securityalert 
  ///
  /// in es this message translates to 
  /// alerta de seguridad se detectó una conexión insegura por tu seguridad la operación fue bloqueada 
  String get securityAlert;

  /// no description provided for securityconnectionerror 
  ///
  /// in es this message translates to 
  /// error de seguridad en la conexión contacta a soporte si persiste 
  String get securityConnectionError;

  /// no description provided for aigeneratinganalysis 
  ///
  /// in es this message translates to 
  /// la ia está generando el análisis detallado vuelve en un momento 
  String get aiGeneratingAnalysis;

  /// no description provided for errorloadingdetails 
  ///
  /// in es this message translates to 
  /// error al cargar los detalles intenta de nuevo 
  String get errorLoadingDetails;

  /// no description provided for studentspressedhere 
  ///
  /// in es this message translates to 
  /// count estudiantes han presionado aquí 
  String studentsPressedHere(String count);

  /// no description provided for recommended 
  ///
  /// in es this message translates to 
  /// recomendado 
  String get recommended;

  /// no description provided for trendingviews 
  ///
  /// in es this message translates to 
  /// trending count vistas 
  String trendingViews(String count);

  /// no description provided for supportemail 
  ///
  /// in es this message translates to 
  /// digitalengineers01 soporte gmail com 
  String get supportEmail;

  /// no description provided for pleaseenterfullname 
  ///
  /// in es this message translates to 
  /// por favor ingresa tu nombre completo 
  String get pleaseEnterFullName;

  /// no description provided for pleaseselectatleastonecareer 
  ///
  /// in es this message translates to 
  /// por favor selecciona al menos una carrera 
  String get pleaseSelectAtLeastOneCareer;

  /// no description provided for accountalreadyexists 
  ///
  /// in es this message translates to 
  /// esta cuenta ya existe por favor retrocede e inicia sesión 
  String get accountAlreadyExists;

  /// no description provided for validationerror 
  ///
  /// in es this message translates to 
  /// error de validación message 
  String validationError(String message);

  /// no description provided for servererrorregistering 
  ///
  /// in es this message translates to 
  /// error del servidor al registrar 
  String get serverErrorRegistering;

  /// no description provided for autologinerror 
  ///
  /// in es this message translates to 
  /// error al iniciar sesión automáticamente 
  String get autoLoginError;

  /// no description provided for notokenreceived 
  ///
  /// in es this message translates to 
  /// error no se recibió token en el login 
  String get noTokenReceived;

  /// no description provided for yourdata 
  ///
  /// in es this message translates to 
  /// tus datos 
  String get yourData;

  /// no description provided for teacherprofilesubtitle 
  ///
  /// in es this message translates to 
  /// comencemos a personalizar tu perfil docente en corvus 
  String get teacherProfileSubtitle;

  /// no description provided for universityvalidated 
  ///
  /// in es this message translates to 
  /// universidad validada 
  String get universityValidated;

  /// no description provided for fullname 
  ///
  /// in es this message translates to 
  /// nombre completo 
  String get fullName;

  /// no description provided for fullnamehint 
  ///
  /// in es this message translates to 
  /// ej juan pérez garcía 
  String get fullNameHint;

  /// no description provided for careersyouteach 
  ///
  /// in es this message translates to 
  /// carreras que impartes 
  String get careersYouTeach;

  /// no description provided for finishregistration 
  ///
  /// in es this message translates to 
  /// finalizar registro 
  String get finishRegistration;
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
  // lookup logic when only language code is specified 
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
