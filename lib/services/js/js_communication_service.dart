import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:osaka_app/helpers/webview_helper.dart';
import 'package:osaka_app/models/web_post_message.dart';
import 'package:osaka_app/provider/webview_provider.dart';
import 'package:osaka_app/repositories/auth_repository.dart';
import 'package:osaka_app/screens/camera/custom_camera_screen.dart';
import 'package:osaka_app/services/permission/permission_service.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

/// Service for handling JavaScript communication with WebView
/// Manages route changes, post messages, and contacts access
class JsCommunicationService {
  /// Define JavaScript handler for SPA route changes
  static void defineRouteChangeFunction({
    required InAppWebViewController controller,
    required BuildContext context,
    required AuthRepository authRepository,
    required CookieManager cookieManager,
    required String webViewUrl,
  }) async {
    controller.addJavaScriptHandler(
      handlerName: "onRouteChanged",
      callback: (args) {
        String currentUrl = args[0];
        print("SPA navigated to: $currentUrl");

        authRepository.checkUserLoginStatus(
          cookieManager: cookieManager,
          url: webViewUrl,
          name: "accessToken",
        );

        context.read<WebViewProvider>().setCurrentUrl(currentUrl);
      },
    );
  }

  /// Handle JavaScript postMessage events from WebView
  static Future<void> handlePostMessage({
    required InAppWebViewController controller,
    required String webViewUrl,
    required Function({
      required String name,
      required String url,
      String? base64Str,
    }) onDownload,
    required BuildContext context,
  }) async {
    print("Setting up WebMessage listener");

    final fToast = FToast();
    fToast.init(context);
    final permissionService = PermissionService();

    Future<void> openCustomCamera() async {
      if (!context.mounted) {
        return;
      }

      final hasPermission =
          await permissionService.requestCameraAndMicrophonePermission();

      if (!hasPermission) {
        if (!context.mounted) {
          return;
        }

        Fluttertoast.showToast(
          msg: 'Camera and microphone permissions are required.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
        );
        return;
      }

      if (!context.mounted) {
        return;
      }

      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => const CustomCameraScreen(),
        ),
      );
    }

    if (defaultTargetPlatform != TargetPlatform.android ||
        await WebViewFeature.isFeatureSupported(
            WebViewFeature.WEB_MESSAGE_LISTENER)) {
      await controller.addWebMessageListener(WebMessageListener(
        jsObjectName: "webviewListener",
        onPostMessage: (message, sourceOrigin, isMainFrame, replyProxy) async {
          print("message: $message");
          if (message != null && message.data != null) {
            final rawMessage = message.data.toString();
            if (rawMessage == 'record_camera') {
              await openCustomCamera();
              return;
            }

            try {
              final decoded = jsonDecode(rawMessage);
              if (decoded is Map<String, dynamic> &&
                  decoded['type'] == 'record_camera') {
                await openCustomCamera();
                return;
              }

              final postedMessage = WebPostMessage.fromJson(
                decoded as Map<String, dynamic>,
              );
              print('message type: ${postedMessage.type}');

              if (postedMessage.type == 'share') {
                final params = ShareParams(
                  title: postedMessage.messageData?.title ?? '',
                  uri: Uri.parse(postedMessage.messageData?.url ?? ''),
                );
                SharePlus.instance.share(
                  params,
                );
              } else if (postedMessage.type == 'copy-fcm-token') {
                await WebViewHelper().handleCopyFCMToken(fToast);
              } else if (postedMessage.type == 'download_file') {
                onDownload(
                    name: postedMessage.messageData?.title ?? '',
                    url: postedMessage.messageData?.url ?? '');
              }
            } catch (e) {
              print('Unsupported webview message: $rawMessage');
            }
          }
        },
      ));
      controller.loadUrl(urlRequest: URLRequest(url: WebUri(webViewUrl)));
    }
  }
}
