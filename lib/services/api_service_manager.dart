import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'config_service.dart';

class ApiServiceManager extends ChangeNotifier {
  late ApiService _apiService;
  final ConfigService _configService;

  ApiServiceManager(this._configService) {
    _apiService = ApiService(baseUrl: _configService.apiUrl);
    _configService.addListener(_onConfigChanged);
  }

  ApiService get apiService => _apiService;

  void _onConfigChanged() {
    // Update the API service with new URL
    _apiService = ApiService(baseUrl: _configService.apiUrl);
    notifyListeners();
  }

  @override
  void dispose() {
    _configService.removeListener(_onConfigChanged);
    super.dispose();
  }
}
