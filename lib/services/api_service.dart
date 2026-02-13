import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../models/user.dart';
import 'device_fingerprint.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;
  
  String get baseUrl => '${AppConstants.wordpressBaseUrl}${AppConstants.apiBasePath}';

  /// Login with email and password
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Get device fingerprint
      final deviceId = await DeviceFingerprintService().generateFingerprint();
      final deviceName = await DeviceFingerprintService().getDeviceName();

      final response = await http.post(
        Uri.parse('$baseUrl${AppConstants.loginEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'device_id': deviceId,
          'device_name': deviceName,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          _authToken = data['token'];
          
          // Save to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(AppConstants.keyAuthToken, _authToken!);
          await prefs.setInt(AppConstants.keyUserId, data['user_id']);
          await prefs.setString(AppConstants.keyUserEmail, email);
          await prefs.setString(AppConstants.keyDeviceId, deviceId);
          
          return {'success': true, 'user': User.fromJson(data['subscription'])};
        }
      }

      return {'success': false, 'error': 'Invalid credentials'};
    } catch (e) {
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }

  /// Check subscription status
  Future<User?> checkSubscription(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${AppConstants.checkSubscriptionEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return User.fromJson(data['subscription']);
        }
      }
    } catch (e) {
      print('Error checking subscription: $e');
    }
    
    return null;
  }

  /// Get candles for a symbol
  Future<Map<String, dynamic>> getCandles(String symbol, String timeframe) async {
    try {
      final response = await http.get(
        Uri.parse('https://server168.liquidityprint.com/wp-json/liquidity/v1/candles?symbol=$symbol&tf=$timeframe'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'error': 'Failed to load candles'};
      }
    } catch (e) {
      print('Error fetching candles: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Notify WordPress about the active symbol being viewed (so EA knows to stream it)
  Future<void> setActiveSymbol(String symbol, String timeframe) async {
    try {
      await http.post(
        Uri.parse('https://server168.liquidityprint.com/wp-json/liquidity/v1/active-symbols'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'symbols': [symbol], // Array of symbols currently being viewed
          'timeframe': timeframe,
        }),
      );
    } catch (e) {
      print('Error setting active symbol: $e');
    }
  }

  /// Get Delta indicator data
  Future<Map<String, dynamic>?> getDelta(int userId, String symbol, String timeframe) async {
    return _getIndicator(AppConstants.deltaEndpoint, userId, symbol, timeframe);
  }

  /// Get Liquidity Scale indicator data
  Future<Map<String, dynamic>?> getScale(int userId, String symbol, String timeframe) async {
    return _getIndicator(AppConstants.scaleEndpoint, userId, symbol, timeframe);
  }

  /// Get Algo LOC indicator data
  Future<Map<String, dynamic>?> getAlgoLoc(int userId, String symbol, String timeframe) async {
    return _getIndicator(AppConstants.algoLocEndpoint, userId, symbol, timeframe);
  }

  /// Get Iceberg indicator data
  Future<Map<String, dynamic>?> getIceberg(int userId, String symbol, String timeframe) async {
    return _getIndicator(AppConstants.icebergEndpoint, userId, symbol, timeframe);
  }

  /// Generic indicator fetcher
  Future<Map<String, dynamic>?> _getIndicator(
    String endpoint,
    int userId,
    String symbol,
    String timeframe,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode({
          'user_id': userId,
          'symbol': symbol,
          'timeframe': timeframe,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error fetching indicator: $e');
    }
    
    return null;
  }

  /// Load saved auth token
  Future<void> loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(AppConstants.keyAuthToken);
  }

  /// Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _authToken = null;
  }
}
