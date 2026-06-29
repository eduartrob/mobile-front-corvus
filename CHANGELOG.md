# Changelog
All notable changes to this project will be documented in this file.
## [1.2.7] - 2026-06-29
### Changed
- **Arquitectura — Refactorización UI (Feature-First)**: Se extrajeron los componentes pesados (*God Classes*) de la capa de presentación hacia widgets atómicos `const` independientes para mejorar el rendimiento de renderizado en Flutter y facilitar la escalabilidad del código.
- Se refactorizó `prof_profile_page.dart` (Perfil del Profesor): Extracción de `ProfHeaderInfo`, `ProfStatsCard` y `DriveSyncModal`.
- Se refactorizó `profile_page.dart` (Perfil del Alumno): Extracción de `StudentHeaderInfo`, `StudentStatsCard` y `TechnicalSkillsSection`.
- Se refactorizó `teams_page.dart` (Equipos): Extracción de `TeamMembersList` y `TeamAiAssistantCard`.
- Se refactorizó `detailed_analysis_widget.dart` (Análisis de Proyecto): Extracción de `InnovationCard`, `MetricsCard` y `RiskCard`.
- Se refactorizó `blue_ocean_detail_page.dart` (Océano Azul): Extracción de componentes privados hacia `SugerenciasCard` y `BlueOceanHeader`.
- **Version**: Bumped from `1.2.6+9` to `1.2.7+10`.


## [1.2.6] - 2026-06-29
### Changed
- **UI/UX — Flat Design**: Se migraron las listas de proyectos en `InspirationPage` hacia un diseño de lista plana (Flat List) tipo "feed", eliminando las tarjetas flotantes blancas y reduciendo el ruido visual para priorizar la lectura.
- **UI/UX — Detalles de Proyecto**: Se "aplanaron" las secciones de "Índice de Innovación", "Métricas de Calidad" y "Recomendaciones IA" en `DetailedAnalysisWidget` para integrarse directamente al fondo en lugar de generar un efecto abrumador de "tarjetas anidadas".
- **UI/UX — Tarjeta de Riesgo**: Se corrigió el layout de la tarjeta de validación de riesgo. Ahora el texto descriptivo ocupa el 100% del ancho bajo el encabezado, eliminando los huecos visuales irregulares.
- **UI/UX — Habilidades Técnicas**: Las "chips" o etiquetas de tecnologías (React, Node.js, etc.) en `ProfilePage` perdieron sus bordes de colores en favor de un diseño de pastilla sólida mucho más moderno, y se aplanaron el resto de contenedores de la vista para que el bloque de habilidades técnicas sea el único que resalte de manera jerárquica.
- **Version**: Bumped from `1.2.5+7` to `1.2.6+8`.

## [1.2.5] - 2026-06-28
### Added
- **Resiliencia de Flujo RAG (Backend)**: El archivo `draft` del proyecto ya no se borra prematuramente al finalizar el análisis exhaustivo en el servidor. Ahora persiste hasta que el cliente (la app móvil) descarga exitosamente el resultado final.
- **Recuperación de Fase 9 (Frontend)**: La lógica de inicialización en `MyProjectProvider` ahora intercepta la fase 9 (análisis completado en background) para recuperar el resultado si el usuario cerró la aplicación durante la generación del análisis.

### Changed
- **Version**: Bumped from `1.2.3+5` to `1.2.4+6`.

## [1.2.3] - 2026-06-28
### Added
- **UI UX — Floating Input**: El estado del input flotante de Inteligencia Artificial (minimizado o expandido) ahora se persiste usando `SharedPreferences`, y se hidrata de forma síncrona en el primer frame (usando una bandera `_isInitialized`) para evitar el parpadeo (flicker) visual al iniciar la aplicación.
- **UI UX — Pull to Refresh Nativo**: Integración del motor nativo `RefreshIndicator` en la barra de navegación inferior. Al tocar el ícono de la pestaña "Inspiración" estando ya en ella, la aplicación lanza la flecha de recarga nativa de Android sin destruir la lista de elementos en pantalla.
- **Infraestructura — Límite de Subida**: Aumentado `client_max_body_size` a `50M` en Nginx (`administration-front-corvus`) para permitir la carga de propuestas PDF pesadas con imágenes y diagramas matemáticos sin arrojar el error `413 Request Entity Too Large`.

### Changed
- **Arquitectura de Navegación**: Se refactorizó la lógica asíncrona del widget `ProjectCard`. Ahora captura el `NavigatorState` raíz local antes de realizar llamadas asíncronas para prevenir el fallo del framework de Flutter `Use of unmounted BuildContext` durante las reconstrucciones del SliverList generadas por `notifyListeners()`.
- **Manejo de Estados de Validación**: La lógica de `MyProjectProvider` fue actualizada. Si ocurre un fallo de red o error de servidor durante la sumisión para el análisis exhaustivo, la app retiene el estado `ProjectState.preValidated` en lugar de borrar la vista forzando `ProjectState.error`. Esto evita que el usuario pierda su análisis RAG visual.
- **Version**: Bumped from `1.2.2+4` to `1.2.3+5`.
- **API Gateway Version**: Bumped from `1.0.0` to `1.0.1`.

### Fixed
- Fixed **"Token expirado o inválido"** (401 Unauthorized) del API Gateway que ocurría debido a un error de interpolación de variables en Dart (`\$token` enviaba literalmente el símbolo de dólar en lugar de la firma JWT) dentro de `my_project_remote_data_source.dart`.
- Fixed la visibilidad condicional conflictiva en `my_project_page.dart` que superponía la vista de carga sobre la vista de resultados de pre-validación tras cerrar el cuadro de error.
- Fixed el renderizado redundante del error en JSON dentro del componente `InvalidDocumentWidget`.

## [1.2.2] - 2026-06-28
### Added
- **Real-Time Progress Polling**: Refactored `AnimatedLoadingTextWidget` from a static timer-based widget to a real-time polling component. It now reads from `MyProjectProvider.serverPhase` (updated every 2s via `/analysis-status/{user_id}`) and reflects the exact backend processing stage (phases 1–8).
- **AI Queue System (Backend)**: Implemented an `asyncio.Lock` on the `/analyze-draft-proposal` endpoint. When the AI is busy, subsequent users receive a `"En cola de espera..."` status message and are queued automatically — no request is dropped or rejected.
- **Server Auto-Recovery**: Added `restart: unless-stopped` policy to all Docker Compose services (`db`, `rabbitmq`, `api-gateway`, `auth-service`, `notifications-service`, `clustering-integrator-service`, `llm-service`, `ollama`), enabling automatic recovery after crashes without manual SSH intervention.
- **i18n — Team Management**: Fully internationalized `TeamsPage` (Gestión de Equipo). All hardcoded Spanish strings replaced with `l10n.*` keys available in both `app_es.arb` and `app_en.arb`.
- **i18n — Error Messages**: Replaced all raw exception stack traces visible to users with a single localized `serverErrorContactSupport` key showing a clean, friendly message with the official support email.
- **Widget: `TeamMemberCard`**: Extracted `_buildMemberCard` inline method from `teams_page.dart` into a dedicated `StatelessWidget` at `teams/presentation/widgets/team_member_card.dart` following Feature-First architecture.

### Changed
- **Architecture — Feature-First Enforcement**: 
  - Deleted 10 empty `providers/` (plural) ghost folders duplicating the canonical `provider/` (singular) in every feature.
  - Consolidated `shared/components/` and `core/widgets/` into a single source of truth: `shared/widgets/`. All global widgets renamed with `corvus_` prefix.
  - Updated all imports project-wide to reflect the new paths.
- **UX — Loading Phases**: Loading phases now advance strictly linearly (Phase 1 → 2 → … → 8) driven by the server state, and freeze at Phase 8 until the backend completes. The infinite loop bug causing phases to restart from Phase 1 after completing Phase 8 has been fixed.
- **Version**: Bumped from `1.2.1+3` to `1.2.2+4`.

### Fixed
- Fixed `AnimatedLoadingTextWidget` cycling phases in an infinite loop instead of stopping at the final phase.
- Fixed `TeamsPage` displaying hardcoded Spanish strings when the device language was set to English.
- Fixed raw exception messages (e.g., HTTP error bodies) being shown directly to end users.

## [1.2.0] - 2026-06-27
### Added
- **Compliance**: Added INAI compliance (Derechos ARCO) and Google OAuth Limited Use policy to the Landing Page legal agreements to unblock Google App Verification.
- **UI Metrics**: Implemented dynamic colors and detailed explanations for semantic collision risk alerts (e.g., green UI for "Falsa Alarma") in `DetailedAnalysisWidget`.

### Changed
- **Architecture**: Modularized monolithic pages (specifically `my_project_page.dart`) by extracting massive builder methods into localized feature widgets following Clean Architecture principles (`pages/`, `widgets/`, `providers/`).
- **Security**: Renamed production Keystore alias from `upload` to `corvus` in `key.properties` for production release signing.

## [1.1.1] - 2026-06-24
### Changed
- **UX**: Simulated Google Drive Sync progress bar (`NotificationService`) locally in `prof_profile_page.dart` for the MVP presentation to prevent UI freezes, compensating for the lack of FCM infrastructure in the backend.
- **Drive API**: Fixed 400 Bad Request error handlers and unhandled exceptions when linking empty Google Drive folders.

## [1.1.0] - 2026-06-24
### Added
- **Student UI**: Created complete student layouts including My Projects, Teams, and Profile pages.
- **Professor UI**: Created complete professor layouts including Dashboard, Reviews, Rules, and History pages.
- **Professor Profile**: Added a specialized profile page with course access toggles, metrics, and a "Sincronizar Repositorio de Proyectos" button.
- **Role-Based Routing**: Integrated dynamic routing (`appRouter.dart`) to automatically direct users to `/prof-dash` or `/inspiration` based on the `role` payload from the authentication backend.
- **Incremental Authorization**: Implemented dynamic Google Drive scope requests (`https://www.googleapis.com/auth/drive.readonly`). Permissions are now requested strictly on-demand when a professor attempts to sync projects, preventing intrusive warnings for students.

### Changed
- **UI Components**: Migrated `InspirationTopBar` to a global `CorvusTopBar` to enforce design consistency across all roles.
- **Authentication Persistence**: Upgraded `AuthProvider`, `UserModel`, and `UserEntity` to persist user roles securely using `FlutterSecureStorage`.
- **Error Handling**: Enhanced the login flow to intercept backend `401 Unauthorized` errors and display elegant `SnackBar` alerts containing the exact error reason.

### Fixed
- Fixed the global "Google hasn't verified this app" warning screen issue by removing the Google Drive scope from the initial login payload and isolating it to the `requestDriveScopeUseCase`.

## [1.0.0] - 2026-06-22
### Added
- Initial project structure for mobile application.
- Comprehensive `.gitignore` for mobile development environments (Flutter, React Native, Android, iOS).
