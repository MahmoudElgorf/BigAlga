import 'package:bioalga/core/services/algae_api_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final AlgaeApiService algaeApi;

  static Future<void> initialize() async {
    _instance.algaeApi = AlgaeApiService();

    // Optional: Check health on startup
    final isHealthy = await _instance.algaeApi.healthCheck();
    print('API Service initialized. Health: $isHealthy');
  }

  static AlgaeApiService get algae => _instance.algaeApi;

  static void dispose() {
    _instance.algaeApi.dispose();
  }
}