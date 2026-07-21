import 'package:dio/dio.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'env_config.dart';

class AppHttp {
  // Private constructor to prevent instantiation
  AppHttp._();

  // Static Dio instance (singleton)
  static Dio? _dio;

  // Store the current access token
  static String? _accessToken;

  // Getter for the Dio instance with lazy initialization
  static Dio get dio {
    if (_dio == null) {
      final env = EnvConfig.instance;
      _dio = Dio(
        BaseOptions(
          baseUrl: env.baseUrl,
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json',
          },
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      // Add interceptor to automatically include auth token
      _dio!.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            // Add Authorization header if token exists
            if (_accessToken != null) {
              options.headers['Authorization'] = 'Bearer $_accessToken';
            }
            return handler.next(options);
          },
          onError: (error, handler) {
            // Handle 401 unauthorized errors if needed
            if (error.response?.statusCode == 401) {
              // Token might be expired, clear it
              _accessToken = null;
            }
            return handler.next(error);
          },
        ),
      );
    }
    return _dio!;
  }

  /// Set access token from cookie for authenticated requests
  ///
  /// This method should be called after user login to automatically
  /// include the access token in all subsequent HTTP requests
  ///
  /// Parameters:
  /// - [cookie]: The cookie object containing the access token
  static void setAccessToken(Cookie cookie) {
    _accessToken = cookie.value;
    // Update the header in BaseOptions if dio is already initialized
    if (_dio != null) {
      _dio!.options.headers['Authorization'] = 'Bearer ${cookie.value}';
    }
  }

  /// Set access token from string value
  ///
  /// Parameters:
  /// - [token]: The access token string
  static void setAccessTokenFromString(String token) {
    _accessToken = token;
    // Update the header in BaseOptions if dio is already initialized
    if (_dio != null) {
      _dio!.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  /// Clear the access token (e.g., on logout)
  static void clearAccessToken() {
    _accessToken = null;
    if (_dio != null) {
      _dio!.options.headers.remove('Authorization');
    }
  }

  /// Get the current access token
  static String? get accessToken => _accessToken;

  static Map<String, String> header = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<Response> get(
    String apiName, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await dio.get(
      apiName,
      queryParameters: queryParameters,
    );
    return response;
  }

  static Future<Response> post(dynamic params, String apiName) async {
    final response = await dio.post(apiName, data: params);
    return response;
  }

  static Future<Response> put(dynamic params, String apiName) async {
    final response = await dio.put(apiName, data: params);
    return response;
  }

  static Future<Response> delete(
    String apiName, {
    dynamic params,
  }) async {
    final response = await dio.delete(apiName, data: params);
    return response;
  }
}
