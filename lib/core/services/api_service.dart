/// Singleton API service manager that wraps AlgaeApiService
import 'package:bioalga/core/services/algae_api_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final AlgaeApiService algaeApi;

  /// Initialize the API service and check server health on startup
  static Future<void> initialize() async {
    _instance.algaeApi = AlgaeApiService();
    final isHealthy = await _instance.algaeApi.healthCheck();
  }

  /// Get the algae API service instance
  static AlgaeApiService get algae => _instance.algaeApi;

  /// Dispose and release resources
  static void dispose() {
    _instance.algaeApi.dispose();
  }
}