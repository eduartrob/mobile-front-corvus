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

  /// No description provided for @signingIn.
  ///
  /// In es, this message translates to:
  /// **'Iniciando sesión...'**
  String get signingIn;

  /// No description provided for @login.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get login;

  /// No description provided for @register.
  ///
  /// In es, this message translates to:
  /// **'Registrarse'**
  String get register;

  /// No description provided for @email.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get email;

  /// No description provided for @password.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get forgotPassword;

  /// No description provided for @noAccount.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes una cuenta?'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes una cuenta?'**
  String get haveAccount;

  /// No description provided for @loginWithEmail.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión con correo'**
  String get loginWithEmail;

  /// No description provided for @registerWithEmail.
  ///
  /// In es, this message translates to:
  /// **'Registrarse con correo'**
  String get registerWithEmail;

  /// No description provided for @orContinueWith.
  ///
  /// In es, this message translates to:
  /// **'o continuar con'**
  String get orContinueWith;

  /// No description provided for @orRegisterWith.
  ///
  /// In es, this message translates to:
  /// **'o registrarse con'**
  String get orRegisterWith;

  /// No description provided for @student.
  ///
  /// In es, this message translates to:
  /// **'Alumno'**
  String get student;

  /// No description provided for @teacher.
  ///
  /// In es, this message translates to:
  /// **'Docente'**
  String get teacher;

  /// No description provided for @selectRole.
  ///
  /// In es, this message translates to:
  /// **'Selecciona tu rol'**
  String get selectRole;

  /// No description provided for @roleSelectionSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elige cómo quieres acceder a Corvus hoy.'**
  String get roleSelectionSubtitle;

  /// No description provided for @loginAsStudent.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión como Alumno'**
  String get loginAsStudent;

  /// No description provided for @loginAsTeacher.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión como Docente'**
  String get loginAsTeacher;

  /// No description provided for @registerAsStudent.
  ///
  /// In es, this message translates to:
  /// **'Registrarse como Alumno'**
  String get registerAsStudent;

  /// No description provided for @registerAsTeacher.
  ///
  /// In es, this message translates to:
  /// **'Registrarse como Docente'**
  String get registerAsTeacher;

  /// No description provided for @welcomeTo.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a'**
  String get welcomeTo;

  /// No description provided for @universityEmailHint.
  ///
  /// In es, this message translates to:
  /// **'Se recomienda correo institucional'**
  String get universityEmailHint;

  /// No description provided for @swipeToChange.
  ///
  /// In es, this message translates to:
  /// **'Desliza para cambiar de rol'**
  String get swipeToChange;

  /// No description provided for @invalidEmail.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa un correo válido'**
  String get invalidEmail;

  /// No description provided for @invalidPassword.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 6 caracteres'**
  String get invalidPassword;

  /// No description provided for @passwordMismatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get passwordMismatch;

  /// No description provided for @requiredField.
  ///
  /// In es, this message translates to:
  /// **'Este campo es obligatorio'**
  String get requiredField;

  /// No description provided for @termsOfUse.
  ///
  /// In es, this message translates to:
  /// **'Al continuar, aceptas nuestros'**
  String get termsOfUse;

  /// No description provided for @unknownError.
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error desconocido'**
  String get unknownError;

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

  /// No description provided for @and.
  ///
  /// In es, this message translates to:
  /// **'y'**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In es, this message translates to:
  /// **'Política de Privacidad'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In es, this message translates to:
  /// **'Términos de Servicio'**
  String get termsOfService;

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

  /// No description provided for @navSearch.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get navSearch;

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

  /// No description provided for @profNavDash.
  ///
  /// In es, this message translates to:
  /// **'Tablero'**
  String get profNavDash;

  /// No description provided for @profNavReviews.
  ///
  /// In es, this message translates to:
  /// **'Revisiones'**
  String get profNavReviews;

  /// No description provided for @profNavRules.
  ///
  /// In es, this message translates to:
  /// **'Reglas'**
  String get profNavRules;

  /// No description provided for @profNavHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get profNavHistory;

  /// No description provided for @featureUpcoming.
  ///
  /// In es, this message translates to:
  /// **'Función disponible en el próximo release académico.'**
  String get featureUpcoming;

  /// No description provided for @manage.
  ///
  /// In es, this message translates to:
  /// **'Gestionar'**
  String get manage;

  /// No description provided for @generateWorkPlan.
  ///
  /// In es, this message translates to:
  /// **'Generar Plan de Trabajo'**
  String get generateWorkPlan;

  /// No description provided for @leaveTeam.
  ///
  /// In es, this message translates to:
  /// **'Salir del equipo'**
  String get leaveTeam;

  /// No description provided for @teamManagementTitle.
  ///
  /// In es, this message translates to:
  /// **'Gestión de Equipo'**
  String get teamManagementTitle;

  /// No description provided for @teamManagementDesc.
  ///
  /// In es, this message translates to:
  /// **'Proyecto Final: \"Implementación de RAG para Análisis Documental\". Administra los miembros de tu grupo de investigación.'**
  String get teamManagementDesc;

  /// No description provided for @teamFull.
  ///
  /// In es, this message translates to:
  /// **'Equipo Completo'**
  String get teamFull;

  /// No description provided for @members.
  ///
  /// In es, this message translates to:
  /// **'Integrantes'**
  String get members;

  /// No description provided for @pendingInvitations.
  ///
  /// In es, this message translates to:
  /// **'Invitaciones Pendientes'**
  String get pendingInvitations;

  /// No description provided for @twoDaysAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace 2 días'**
  String get twoDaysAgo;

  /// No description provided for @teamFullInviteNotice.
  ///
  /// In es, this message translates to:
  /// **'El equipo está lleno. Cancela una invitación para invitar a alguien más.'**
  String get teamFullInviteNotice;

  /// No description provided for @aiAssistantTeamSuggestionSpan1.
  ///
  /// In es, this message translates to:
  /// **'Basado en los perfiles de tu equipo, tienen una '**
  String get aiAssistantTeamSuggestionSpan1;

  /// No description provided for @aiAssistantTeamSuggestionSpan2.
  ///
  /// In es, this message translates to:
  /// **'fuerte cobertura'**
  String get aiAssistantTeamSuggestionSpan2;

  /// No description provided for @aiAssistantTeamSuggestionSpan3.
  ///
  /// In es, this message translates to:
  /// **' en Backend y Frontend. Se sugiere asignar tareas de '**
  String get aiAssistantTeamSuggestionSpan3;

  /// No description provided for @aiAssistantTeamSuggestionSpan4.
  ///
  /// In es, this message translates to:
  /// **'documentación y pruebas unitarias'**
  String get aiAssistantTeamSuggestionSpan4;

  /// No description provided for @aiAssistantTeamSuggestionSpan5.
  ///
  /// In es, this message translates to:
  /// **' equitativamente para el próximo sprint.'**
  String get aiAssistantTeamSuggestionSpan5;

  /// No description provided for @youLeader.
  ///
  /// In es, this message translates to:
  /// **'TÚ (LÍDER)'**
  String get youLeader;

  /// No description provided for @registerRule.
  ///
  /// In es, this message translates to:
  /// **'Registrar Regla'**
  String get registerRule;

  /// No description provided for @viewReports.
  ///
  /// In es, this message translates to:
  /// **'Ver todos los reportes'**
  String get viewReports;

  /// No description provided for @citeTeam.
  ///
  /// In es, this message translates to:
  /// **'Citar Equipo'**
  String get citeTeam;

  /// No description provided for @approve.
  ///
  /// In es, this message translates to:
  /// **'Aprobar'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In es, this message translates to:
  /// **'Rechazar'**
  String get reject;

  /// No description provided for @gpa.
  ///
  /// In es, this message translates to:
  /// **'PROMEDIO'**
  String get gpa;

  /// No description provided for @projects.
  ///
  /// In es, this message translates to:
  /// **'PROYECTOS'**
  String get projects;

  /// No description provided for @technicalSkills.
  ///
  /// In es, this message translates to:
  /// **'Habilidades Técnicas'**
  String get technicalSkills;

  /// No description provided for @recentActivity.
  ///
  /// In es, this message translates to:
  /// **'Actividad Reciente'**
  String get recentActivity;

  /// No description provided for @ragEngineUpdate.
  ///
  /// In es, this message translates to:
  /// **'Actualización en RAG Core Engine'**
  String get ragEngineUpdate;

  /// No description provided for @timeTwoHoursAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace 2h'**
  String get timeTwoHoursAgo;

  /// No description provided for @readingCompleted.
  ///
  /// In es, this message translates to:
  /// **'Lectura Completada:\nArquitecturas Transformer'**
  String get readingCompleted;

  /// No description provided for @timeYesterday.
  ///
  /// In es, this message translates to:
  /// **'Ayer'**
  String get timeYesterday;

  /// No description provided for @appearance.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get themeDark;

  /// No description provided for @logout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar Sesión'**
  String get logout;

  /// No description provided for @errorCredentialsDriveCorvus.
  ///
  /// In es, this message translates to:
  /// **'Error: No se pudo obtener las credenciales necesarias (Drive o Corvus).'**
  String get errorCredentialsDriveCorvus;

  /// No description provided for @folderAlreadyLinked.
  ///
  /// In es, this message translates to:
  /// **'Carpeta vinculada (Ya estaba sincronizada previamente en Corvus).'**
  String get folderAlreadyLinked;

  /// No description provided for @folderLinkedProcessingStarted.
  ///
  /// In es, this message translates to:
  /// **'¡Carpeta vinculada! El procesamiento ha comenzado en segundo plano.'**
  String get folderLinkedProcessingStarted;

  /// No description provided for @removeAccessTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Quitar acceso?'**
  String get removeAccessTitle;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @remove.
  ///
  /// In es, this message translates to:
  /// **'Quitar'**
  String get remove;

  /// No description provided for @driveAccessRequired.
  ///
  /// In es, this message translates to:
  /// **'Se requiere acceso a Drive para sincronizar.'**
  String get driveAccessRequired;

  /// No description provided for @sendForReview.
  ///
  /// In es, this message translates to:
  /// **'Enviar para Revisión'**
  String get sendForReview;

  /// No description provided for @browseFiles.
  ///
  /// In es, this message translates to:
  /// **'Explorar Archivos'**
  String get browseFiles;

  /// No description provided for @understood.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get understood;

  /// No description provided for @detailedAnalysisTitle.
  ///
  /// In es, this message translates to:
  /// **'Análisis Detallado'**
  String get detailedAnalysisTitle;

  /// No description provided for @preValidationTitle.
  ///
  /// In es, this message translates to:
  /// **'Pre-validación de Propuesta'**
  String get preValidationTitle;

  /// No description provided for @detailedAnalysisDesc.
  ///
  /// In es, this message translates to:
  /// **'La IA ha evaluado tu documento. Revisa las métricas clave y las recomendaciones para elevar la calidad de tu proyecto antes de la entrega final.'**
  String get detailedAnalysisDesc;

  /// No description provided for @preValidationDesc.
  ///
  /// In es, this message translates to:
  /// **'Sube tu documento PDF. Nuestro motor de IA analizará tu propuesta contra los requerimientos académicos antes de la entrega final.'**
  String get preValidationDesc;

  /// No description provided for @analyzingStructure.
  ///
  /// In es, this message translates to:
  /// **'Analizando estructura...'**
  String get analyzingStructure;

  /// No description provided for @deleteDraft.
  ///
  /// In es, this message translates to:
  /// **'Eliminar Borrador'**
  String get deleteDraft;

  /// No description provided for @uploadAnotherProposal.
  ///
  /// In es, this message translates to:
  /// **'Cargar otra propuesta'**
  String get uploadAnotherProposal;

  /// No description provided for @analysisEstimatedTime.
  ///
  /// In es, this message translates to:
  /// **'El análisis puede tardar entre 30 y 90 segundos\ndependiendo del modelo de IA del servidor.'**
  String get analysisEstimatedTime;

  /// No description provided for @loadingPhase1.
  ///
  /// In es, this message translates to:
  /// **'Analizando el contenido de tu documento...'**
  String get loadingPhase1;

  /// No description provided for @loadingPhase2.
  ///
  /// In es, this message translates to:
  /// **'Limpiando y anonimizando el texto...'**
  String get loadingPhase2;

  /// No description provided for @loadingPhase3.
  ///
  /// In es, this message translates to:
  /// **'Vectorizando el contenido con IA semántica...'**
  String get loadingPhase3;

  /// No description provided for @loadingPhase4.
  ///
  /// In es, this message translates to:
  /// **'Buscando proyectos similares en el repositorio histórico...'**
  String get loadingPhase4;

  /// No description provided for @loadingPhase5.
  ///
  /// In es, this message translates to:
  /// **'Calculando el riesgo de colisión semántica...'**
  String get loadingPhase5;

  /// No description provided for @loadingPhase6.
  ///
  /// In es, this message translates to:
  /// **'El comité académico está redactando el dictamen...'**
  String get loadingPhase6;

  /// No description provided for @loadingPhase7.
  ///
  /// In es, this message translates to:
  /// **'Generando recomendaciones técnicas personalizadas...'**
  String get loadingPhase7;

  /// No description provided for @loadingPhase8.
  ///
  /// In es, this message translates to:
  /// **'Afinando el veredicto final, casi listo...'**
  String get loadingPhase8;

  /// No description provided for @uploadZoneTitle.
  ///
  /// In es, this message translates to:
  /// **'Arrastra tu propuesta PDF aquí'**
  String get uploadZoneTitle;

  /// No description provided for @uploadZoneSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tamaño máximo: 10MB. Formatos: PDF.'**
  String get uploadZoneSubtitle;

  /// No description provided for @uploadedToday.
  ///
  /// In es, this message translates to:
  /// **'Subido hoy'**
  String get uploadedToday;

  /// No description provided for @serverErrorContactSupport.
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un inconveniente temporal en el servidor. Por favor reintenta en un momento o contacta a soporte: digitalengineers01+soporte@gmail.com'**
  String get serverErrorContactSupport;

  /// No description provided for @loginErrorNotAllowedEmail.
  ///
  /// In es, this message translates to:
  /// **'Fallo al iniciar sesión: El correo no está permitido. Solo se aceptan correos institucionales de la universidad.'**
  String get loginErrorNotAllowedEmail;

  /// No description provided for @invalidDocumentTitle.
  ///
  /// In es, this message translates to:
  /// **'Documento no válido'**
  String get invalidDocumentTitle;

  /// No description provided for @invalidDocumentDesc.
  ///
  /// In es, this message translates to:
  /// **'El archivo que subiste no parece ser una propuesta de proyecto integrador. Asegúrate de subir tu propuesta con secciones como Objetivo, Metodología y Tecnologías.'**
  String get invalidDocumentDesc;

  /// No description provided for @invalidDocumentAction.
  ///
  /// In es, this message translates to:
  /// **'Cargar otro documento'**
  String get invalidDocumentAction;

  /// No description provided for @blueOceanGenericCategory.
  ///
  /// In es, this message translates to:
  /// **'INNOVACIÓN ACADÉMICA'**
  String get blueOceanGenericCategory;

  /// No description provided for @blueOceanGenericTag.
  ///
  /// In es, this message translates to:
  /// **'Océano Azul Real'**
  String get blueOceanGenericTag;

  /// No description provided for @blueOceanGenericDesc.
  ///
  /// In es, this message translates to:
  /// **'Este proyecto ha sido clasificado como una anomalía semántica de alta varianza, indicando un enfoque único e inexplorado respecto a todos los demás trabajos en la base de datos.'**
  String get blueOceanGenericDesc;

  /// No description provided for @notifUploadTitle.
  ///
  /// In es, this message translates to:
  /// **'Subiendo propuesta'**
  String get notifUploadTitle;

  /// No description provided for @notifUploadBody.
  ///
  /// In es, this message translates to:
  /// **'Analizando estructura RAG rápida...'**
  String get notifUploadBody;

  /// No description provided for @notifPreValidReadyTitle.
  ///
  /// In es, this message translates to:
  /// **'Pre-validación lista'**
  String get notifPreValidReadyTitle;

  /// No description provided for @notifPreValidReadyBody.
  ///
  /// In es, this message translates to:
  /// **'Puedes revisar las heurísticas iniciales.'**
  String get notifPreValidReadyBody;

  /// No description provided for @notifErrorTitle.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get notifErrorTitle;

  /// No description provided for @notifPreValidFailed.
  ///
  /// In es, this message translates to:
  /// **'Falló la pre-validación.'**
  String get notifPreValidFailed;

  /// No description provided for @notifAnalysisStartTitle.
  ///
  /// In es, this message translates to:
  /// **'Análisis Detallado'**
  String get notifAnalysisStartTitle;

  /// No description provided for @notifAnalysisStartBody.
  ///
  /// In es, this message translates to:
  /// **'La IA está evaluando rigurosidad y originalidad...'**
  String get notifAnalysisStartBody;

  /// No description provided for @notifAnalysisErrorTitle.
  ///
  /// In es, this message translates to:
  /// **'Error al iniciar análisis'**
  String get notifAnalysisErrorTitle;

  /// No description provided for @notifAnalysisProgressTitle.
  ///
  /// In es, this message translates to:
  /// **'Corvus IA'**
  String get notifAnalysisProgressTitle;

  /// No description provided for @notifAnalysisProgressBody.
  ///
  /// In es, this message translates to:
  /// **'Analizando tu propuesta de proyecto...'**
  String get notifAnalysisProgressBody;

  /// No description provided for @notifAnalysisCompleteTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Análisis Completado!'**
  String get notifAnalysisCompleteTitle;

  /// No description provided for @notifAnalysisCompleteBody.
  ///
  /// In es, this message translates to:
  /// **'Tu dictamen técnico está listo. Abre la app para revisarlo.'**
  String get notifAnalysisCompleteBody;

  /// No description provided for @notifAnalysisFailedTitle.
  ///
  /// In es, this message translates to:
  /// **'Análisis no completado'**
  String get notifAnalysisFailedTitle;

  /// No description provided for @notifAnalysisFailedBody.
  ///
  /// In es, this message translates to:
  /// **'El servidor encontró un error.'**
  String get notifAnalysisFailedBody;

  /// No description provided for @searchPlaceholderResult.
  ///
  /// In es, this message translates to:
  /// **'Resultados para: {query}\n(Pronto conectado a la IA)'**
  String searchPlaceholderResult(String query);

  /// No description provided for @searchFieldLabelHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar proyectos o temas...'**
  String get searchFieldLabelHint;

  /// No description provided for @searchEmptyState.
  ///
  /// In es, this message translates to:
  /// **'Escribe un tema de investigación'**
  String get searchEmptyState;

  /// No description provided for @searchSuggestion.
  ///
  /// In es, this message translates to:
  /// **'Buscar \"{query}\" en todos los repositorios'**
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
