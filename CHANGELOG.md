# Changelog
All notable changes to this project will be documented in this file.

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
