/// Environment configuration.
/// Use --dart-define for build-time overrides.
abstract final class EnvConfig {
  EnvConfig._();

  static const String env = String.fromEnvironment(
    'ENV',
    defaultValue: 'dev',
  );

  static bool get isDev => env == 'dev';
  static bool get isProd => env == 'prod';
  static bool get isStaging => env == 'staging';
}
