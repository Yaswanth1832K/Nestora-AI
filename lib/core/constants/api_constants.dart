/// API endpoint constants for the AI microservice.
abstract final class ApiConstants {
  ApiConstants._();

  /// Base URL for the AI microservice (override via flavor/env).
  static const String baseUrl = String.fromEnvironment(
    'AI_SERVICE_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const String apiVersion = 'v1';
  static const String apiPath = '/api/$apiVersion';

  // Endpoints
  static const String naturalLanguageSearch = '$apiPath/search/natural-language';
  static const String recommendations = '$apiPath/recommendations';
  static const String pricePrediction = '$apiPath/price/predict';
  static const String fraudAnalysis = '$apiPath/fraud/analyze';
}
