// =============================================================================
// APP CONFIGURATION
// =============================================================================
// Application configuration file, including flags to switch between environments.
//
// USAGE:
// - Set [useFakeRepositories] = true to use Fake Repositories (debug/UI dev)
// - Set [useFakeRepositories] = false to use Firebase Repositories (required for production)
// =============================================================================

/// Application Configuration
class AppConfig {
  AppConfig._();

  // ============================================================================
  // REPOSITORY CONFIGURATION
  // ============================================================================

  /// Toggle between Fake Repository and Firebase Repository
  ///
  /// - `true`: Use FakeRepository (mock data, no Firebase connection needed)
  ///   Suitable for: UI development, testing, demo, offline development
  ///
  /// - `false`: Use FirebaseRepository (real data from Firebase)
  ///   Suitable for: Production, integration testing
  ///   Set to `false` before releasing the app!
  static const bool useFakeRepositories = true; // Set to true for initial UI development

  // ============================================================================
  // ENVIRONMENT CONFIGURATION
  // ============================================================================

  /// Current app environment
  static const AppEnvironment environment = AppEnvironment.development;

  /// Check if it is the development environment
  static bool get isDevelopment => environment == AppEnvironment.development;

  /// Check if it is the staging environment
  static bool get isStaging => environment == AppEnvironment.staging;

  /// Check if it is the production environment
  static bool get isProduction => environment == AppEnvironment.production;

  // ============================================================================
  // DEBUG CONFIGURATION
  // ============================================================================

  /// Enable/disable logging for repository operations
  static const bool enableRepositoryLogging = true;

  /// Enable/disable logging for Firebase operations
  static const bool enableFirebaseLogging = true;

  /// Simulated delay for Fake Repository (milliseconds)
  /// Set to 0 to disable delay
  static const int fakeRepositoryDelayMs = 500;

  // ============================================================================
  // PAGINATION CONFIGURATION
  // ============================================================================

  /// Number of items per page for 1-1 chat list.
  static const int chatPageSize = 20;

  /// Number of items per page for group chat list.
  static const int groupChatPageSize = 20;

  /// Number of users per page for New Message Screen.
  static const int userPageSize = 20;

  /// Number of messages per page for Chat Detail Screen.
  static const int messagePageSize = 40;

  /// Max users to search for in Manage Members Screen.
  static const int maxSearchUsersLimit = 10;

  /// Max tasks per page when searching.
  static const int searchTaskPageSize = 30;

  /// Max projects per page when searching.
  static const int searchProjectPageSize = 14;
}

/// Application Environments
enum AppEnvironment {
  /// Development environment
  development,

  /// Staging environment (test before production)
  staging,

  /// Production environment (release)
  production,
}
