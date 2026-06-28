# Changelog
All notable changes to this project will be documented in this file.

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
