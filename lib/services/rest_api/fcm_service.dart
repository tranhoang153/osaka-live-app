import 'package:dio/dio.dart';
import 'package:osaka_app/config/http_config.dart';

/// Service for managing Firebase Cloud Messaging (FCM) tokens
/// Handles saving and deleting device tokens with the backend
class FcmService {
  Future<Response> save(String token) {
    return AppHttp.post(
      {'token': token},
      '/firebase-notification/create-token',
    );
  }

  Future<Response> delete(String token) {
    return AppHttp.delete('/firebase-notification/delete-token/$token');
  }
}
