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

  /// No description provided for @navProjects.
  ///
  /// In es, this message translates to:
  /// **'Proyectos'**
  String get navProjects;

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

  /// No description provided for @accept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get accept;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @saveChanges.
  ///
  /// In es, this message translates to:
  /// **'Guardar Cambios'**
  String get saveChanges;

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

  /// No description provided for @manageTeamTitle.
  ///
  /// In es, this message translates to:
  /// **'Gestionar Equipo'**
  String get manageTeamTitle;

  /// No description provided for @teamNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del Equipo'**
  String get teamNameLabel;

  /// No description provided for @teamNameHint.
  ///
  /// In es, this message translates to:
  /// **'Escribe el nombre del equipo'**
  String get teamNameHint;

  /// No description provided for @teamNameRequired.
  ///
  /// In es, this message translates to:
  /// **'El nombre del equipo es obligatorio'**
  String get teamNameRequired;

  /// No description provided for @teamDescriptionLabel.
  ///
  /// In es, this message translates to:
  /// **'Descripción del Equipo (Opcional)'**
  String get teamDescriptionLabel;

  /// No description provided for @teamDescriptionHint.
  ///
  /// In es, this message translates to:
  /// **'Añade una descripción amigable...'**
  String get teamDescriptionHint;

  /// No description provided for @socialLinksTitle.
  ///
  /// In es, this message translates to:
  /// **'Enlaces a Grupos de Redes Sociales'**
  String get socialLinksTitle;

  /// No description provided for @socialLinksDesc.
  ///
  /// In es, this message translates to:
  /// **'Agrega enlaces para que los integrantes se unan a tus canales oficiales.'**
  String get socialLinksDesc;

  /// No description provided for @socialPlatformHint.
  ///
  /// In es, this message translates to:
  /// **'Red (ej. Discord)'**
  String get socialPlatformHint;

  /// No description provided for @socialLinkRequired.
  ///
  /// In es, this message translates to:
  /// **'Por favor, ingresa el nombre de la red social y la URL'**
  String get socialLinkRequired;

  /// No description provided for @socialUrlInvalid.
  ///
  /// In es, this message translates to:
  /// **'La URL debe comenzar con http:// o https://'**
  String get socialUrlInvalid;

  /// No description provided for @teamSettingsSaved.
  ///
  /// In es, this message translates to:
  /// **'Configuración del equipo guardada con éxito'**
  String get teamSettingsSaved;

  /// No description provided for @teamSettingsError.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar cambios: {error}'**
  String teamSettingsError(String error);

  /// No description provided for @myTeam.
  ///
  /// In es, this message translates to:
  /// **'Mi Equipo'**
  String get myTeam;

  /// No description provided for @virtualTeamDesc.
  ///
  /// In es, this message translates to:
  /// **'Crea tu equipo personalizando el nombre en el botón \"Gestionar\" de la derecha y busca integrantes en la pestaña \"Sugerencias\".'**
  String get virtualTeamDesc;

  /// No description provided for @studentDefaultName.
  ///
  /// In es, this message translates to:
  /// **'Estudiante'**
  String get studentDefaultName;

  /// No description provided for @yourTeamBadge.
  ///
  /// In es, this message translates to:
  /// **'TU EQUIPO'**
  String get yourTeamBadge;

  /// No description provided for @teamMembersCount.
  ///
  /// In es, this message translates to:
  /// **'{count} / {max} miembros'**
  String teamMembersCount(String count, String max);

  /// No description provided for @missingOneMember.
  ///
  /// In es, this message translates to:
  /// **'Te falta 1 integrante'**
  String get missingOneMember;

  /// No description provided for @missingMembers.
  ///
  /// In es, this message translates to:
  /// **'Te faltan {count} integrantes'**
  String missingMembers(String count);

  /// No description provided for @searchMembers.
  ///
  /// In es, this message translates to:
  /// **'Buscar integrantes'**
  String get searchMembers;

  /// No description provided for @proposalSent.
  ///
  /// In es, this message translates to:
  /// **'Propuesta Enviada'**
  String get proposalSent;

  /// No description provided for @proposalApproved.
  ///
  /// In es, this message translates to:
  /// **'Propuesta Aprobada'**
  String get proposalApproved;

  /// No description provided for @proposalRejected.
  ///
  /// In es, this message translates to:
  /// **'Propuesta Rechazada'**
  String get proposalRejected;

  /// No description provided for @summonedForReview.
  ///
  /// In es, this message translates to:
  /// **'Citados a Revisión'**
  String get summonedForReview;

  /// No description provided for @proposalStatusUnknown.
  ///
  /// In es, this message translates to:
  /// **'Estado de propuesta desconocido'**
  String get proposalStatusUnknown;

  /// No description provided for @proposalPendingDesc.
  ///
  /// In es, this message translates to:
  /// **'El profesorado revisará pronto tu proyecto.'**
  String get proposalPendingDesc;

  /// No description provided for @proposalApprovedDesc.
  ///
  /// In es, this message translates to:
  /// **'¡Felicidades! Pueden continuar con el proyecto.'**
  String get proposalApprovedDesc;

  /// No description provided for @proposalRejectedDesc.
  ///
  /// In es, this message translates to:
  /// **'La propuesta no cumple con los criterios académicos.'**
  String get proposalRejectedDesc;

  /// No description provided for @appointmentDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha: {date}'**
  String appointmentDate(String date);

  /// No description provided for @appointmentLocation.
  ///
  /// In es, this message translates to:
  /// **'Lugar/Enlace: {location}'**
  String appointmentLocation(String location);

  /// No description provided for @searchResults.
  ///
  /// In es, this message translates to:
  /// **'Resultados de búsqueda'**
  String get searchResults;

  /// No description provided for @recommendedForYou.
  ///
  /// In es, this message translates to:
  /// **'Recomendados para ti'**
  String get recommendedForYou;

  /// No description provided for @errorLoadingSuggestions.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar sugerencias:\n{error}'**
  String errorLoadingSuggestions(String error);

  /// No description provided for @noSuggestionsFound.
  ///
  /// In es, this message translates to:
  /// **'No hay sugerencias encontradas'**
  String get noSuggestionsFound;

  /// No description provided for @invitationSent.
  ///
  /// In es, this message translates to:
  /// **'Invitación enviada a {name}'**
  String invitationSent(String name);

  /// No description provided for @errorSendingInvitation.
  ///
  /// In es, this message translates to:
  /// **'Error al enviar invitación: {error}'**
  String errorSendingInvitation(String error);

  /// No description provided for @received.
  ///
  /// In es, this message translates to:
  /// **'Recibidas'**
  String get received;

  /// No description provided for @sent.
  ///
  /// In es, this message translates to:
  /// **'Enviadas'**
  String get sent;

  /// No description provided for @noRequests.
  ///
  /// In es, this message translates to:
  /// **'No hay solicitudes en esta sección'**
  String get noRequests;

  /// No description provided for @requestCancelled.
  ///
  /// In es, this message translates to:
  /// **'Solicitud cancelada / rechazada'**
  String get requestCancelled;

  /// No description provided for @invitationAccepted.
  ///
  /// In es, this message translates to:
  /// **'Invitación aceptada. Te has unido al equipo!'**
  String get invitationAccepted;

  /// No description provided for @wantsToJoinGroup.
  ///
  /// In es, this message translates to:
  /// **'Quiere unirse a tu grupo'**
  String get wantsToJoinGroup;

  /// No description provided for @invitedToGroup.
  ///
  /// In es, this message translates to:
  /// **'Te invitó a formar parte de su grupo'**
  String get invitedToGroup;

  /// No description provided for @teamsFormed.
  ///
  /// In es, this message translates to:
  /// **'EQUIPOS FORMADOS'**
  String get teamsFormed;

  /// No description provided for @proposalsReady.
  ///
  /// In es, this message translates to:
  /// **'PROPUESTAS LISTAS'**
  String get proposalsReady;

  /// No description provided for @proposalsReadyDetail.
  ///
  /// In es, this message translates to:
  /// **'{ready} de {total} equipos'**
  String proposalsReadyDetail(String ready, String total);

  /// No description provided for @attentionRequired.
  ///
  /// In es, this message translates to:
  /// **'Atención Requerida'**
  String get attentionRequired;

  /// No description provided for @allUpToDate.
  ///
  /// In es, this message translates to:
  /// **'Todo al día. No hay elementos que requieran atención inmediata.'**
  String get allUpToDate;

  /// No description provided for @quickMetrics.
  ///
  /// In es, this message translates to:
  /// **'Métricas Rápidas'**
  String get quickMetrics;

  /// No description provided for @studentsWithTeam.
  ///
  /// In es, this message translates to:
  /// **'{count} Alumnos con equipo'**
  String studentsWithTeam(String count);

  /// No description provided for @studentsWithoutTeam.
  ///
  /// In es, this message translates to:
  /// **'{count} Alumnos rezagados (sin equipo)'**
  String studentsWithoutTeam(String count);

  /// No description provided for @viewLaggingStudentsDirectory.
  ///
  /// In es, this message translates to:
  /// **'Ver Directorio de Alumnos Rezagados'**
  String get viewLaggingStudentsDirectory;

  /// No description provided for @sessionExpired.
  ///
  /// In es, this message translates to:
  /// **'Tu sesión ha expirado. Por favor, inicia sesión de nuevo.'**
  String get sessionExpired;

  /// No description provided for @doubleTapToExit.
  ///
  /// In es, this message translates to:
  /// **'Toca \"Volver\" de nuevo para salir'**
  String get doubleTapToExit;

  /// No description provided for @chatUnderConstruction.
  ///
  /// In es, this message translates to:
  /// **'Chat Grupal con IA (En construcción)'**
  String get chatUnderConstruction;

  /// No description provided for @maxSkillsSelected.
  ///
  /// In es, this message translates to:
  /// **'Puedes seleccionar un máximo de 10 habilidades'**
  String get maxSkillsSelected;

  /// No description provided for @selectAtLeastOneSkill.
  ///
  /// In es, this message translates to:
  /// **'Selecciona al menos una habilidad'**
  String get selectAtLeastOneSkill;

  /// No description provided for @selectYourSkills.
  ///
  /// In es, this message translates to:
  /// **'Selecciona tus habilidades'**
  String get selectYourSkills;

  /// No description provided for @chooseSkillsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elige hasta 10 habilidades que deseas obtener o mejorar en tu carrera. ({selected}/{max})'**
  String chooseSkillsSubtitle(String selected, String max);

  /// No description provided for @saving.
  ///
  /// In es, this message translates to:
  /// **'Guardando...'**
  String get saving;

  /// No description provided for @finish.
  ///
  /// In es, this message translates to:
  /// **'Finalizar'**
  String get finish;

  /// No description provided for @completeAllRequiredFields.
  ///
  /// In es, this message translates to:
  /// **'Por favor, completa todos los campos requeridos'**
  String get completeAllRequiredFields;

  /// No description provided for @selectValidUniversity.
  ///
  /// In es, this message translates to:
  /// **'Por favor, selecciona una universidad válida de la lista'**
  String get selectValidUniversity;

  /// No description provided for @statusPending.
  ///
  /// In es, this message translates to:
  /// **'PENDIENTE'**
  String get statusPending;

  /// No description provided for @statusApproved.
  ///
  /// In es, this message translates to:
  /// **'APROBADA'**
  String get statusApproved;

  /// No description provided for @statusRejected.
  ///
  /// In es, this message translates to:
  /// **'RECHAZADA'**
  String get statusRejected;

  /// No description provided for @statusSummoned.
  ///
  /// In es, this message translates to:
  /// **'CITADA'**
  String get statusSummoned;

  /// No description provided for @noProposalsToReview.
  ///
  /// In es, this message translates to:
  /// **'No hay propuestas para revisión.'**
  String get noProposalsToReview;

  /// No description provided for @teamLabel.
  ///
  /// In es, this message translates to:
  /// **'Equipo: {name}'**
  String teamLabel(String name);

  /// No description provided for @membersLabel.
  ///
  /// In es, this message translates to:
  /// **'Integrantes: {members}'**
  String membersLabel(String members);

  /// No description provided for @untitledProposal.
  ///
  /// In es, this message translates to:
  /// **'Propuesta sin título'**
  String get untitledProposal;

  /// No description provided for @projectProposal.
  ///
  /// In es, this message translates to:
  /// **'Propuesta de Proyecto'**
  String get projectProposal;

  /// No description provided for @unnamedTeam.
  ///
  /// In es, this message translates to:
  /// **'Equipo sin nombre'**
  String get unnamedTeam;

  /// No description provided for @nameRequired.
  ///
  /// In es, this message translates to:
  /// **'El nombre es requerido'**
  String get nameRequired;

  /// No description provided for @errorCreating.
  ///
  /// In es, this message translates to:
  /// **'Error al crear'**
  String get errorCreating;

  /// No description provided for @projectCreated.
  ///
  /// In es, this message translates to:
  /// **'¡Proyecto Creado! 🎉'**
  String get projectCreated;

  /// No description provided for @shareCodeMessage.
  ///
  /// In es, this message translates to:
  /// **'Comparte este código de acceso con tus alumnos para que puedan unirse y formar equipos:'**
  String get shareCodeMessage;

  /// No description provided for @codeCopied.
  ///
  /// In es, this message translates to:
  /// **'Código copiado al portapapeles'**
  String get codeCopied;

  /// No description provided for @copy.
  ///
  /// In es, this message translates to:
  /// **'Copiar'**
  String get copy;

  /// No description provided for @newProject.
  ///
  /// In es, this message translates to:
  /// **'Nuevo Proyecto'**
  String get newProject;

  /// No description provided for @newProjectDesc.
  ///
  /// In es, this message translates to:
  /// **'Al crear un proyecto, se generará un código para que tus alumnos se unan.'**
  String get newProjectDesc;

  /// No description provided for @projectNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del Proyecto *'**
  String get projectNameLabel;

  /// No description provided for @projectNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Proyecto Final Integradora'**
  String get projectNameHint;

  /// No description provided for @descriptionOptional.
  ///
  /// In es, this message translates to:
  /// **'Descripción (Opcional)'**
  String get descriptionOptional;

  /// No description provided for @descriptionHint.
  ///
  /// In es, this message translates to:
  /// **'Detalles del proyecto...'**
  String get descriptionHint;

  /// No description provided for @maxTeamSize.
  ///
  /// In es, this message translates to:
  /// **'Tamaño máximo del equipo'**
  String get maxTeamSize;

  /// No description provided for @creating.
  ///
  /// In es, this message translates to:
  /// **'Creando...'**
  String get creating;

  /// No description provided for @createProject.
  ///
  /// In es, this message translates to:
  /// **'Crear Proyecto'**
  String get createProject;

  /// No description provided for @join.
  ///
  /// In es, this message translates to:
  /// **'Unirse'**
  String get join;

  /// No description provided for @noClassesYet.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes clases'**
  String get noClassesYet;

  /// No description provided for @noClassesDesc.
  ///
  /// In es, this message translates to:
  /// **'Únete a una clase ingresando el código que te proporcionó tu profesor para comenzar tu proyecto.'**
  String get noClassesDesc;

  /// No description provided for @joinClass.
  ///
  /// In es, this message translates to:
  /// **'Unirse a una Clase'**
  String get joinClass;

  /// No description provided for @defaultProjectName.
  ///
  /// In es, this message translates to:
  /// **'Proyecto'**
  String get defaultProjectName;

  /// No description provided for @noProjectYet.
  ///
  /// In es, this message translates to:
  /// **'Aún no perteneces a ningún proyecto'**
  String get noProjectYet;

  /// No description provided for @noProjectDesc.
  ///
  /// In es, this message translates to:
  /// **'Para poder formar un equipo y subir tu propuesta, primero debes unirte a la clase de tu profesor usando su Código de Acceso.'**
  String get noProjectDesc;

  /// No description provided for @joinProject.
  ///
  /// In es, this message translates to:
  /// **'Unirse a un Proyecto'**
  String get joinProject;

  /// No description provided for @noTeam.
  ///
  /// In es, this message translates to:
  /// **'No tienes un equipo'**
  String get noTeam;

  /// No description provided for @noTeamDesc.
  ///
  /// In es, this message translates to:
  /// **'Debes unirte o crear un equipo en la pestaña de Equipos para poder enviar una propuesta.'**
  String get noTeamDesc;

  /// No description provided for @navProjectsLabel.
  ///
  /// In es, this message translates to:
  /// **'Proyectos'**
  String get navProjectsLabel;
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
