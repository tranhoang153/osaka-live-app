import 'dart:convert';

const listenRouterChange = """
        // Listen for pushState and replaceState events in SPA, guard to avoid duplicate observers.
        (function() {
          if (window.__flutterRouteObserverInstalled) {
            return;
          }
          window.__flutterRouteObserverInstalled = true;

          let lastUrl = location.href;
          new MutationObserver(() => {
            const currentUrl = location.href;
            if (currentUrl !== lastUrl) {
              lastUrl = currentUrl;
              window.flutter_inappwebview.callHandler('onRouteChanged', currentUrl);
            }
          }).observe(document, { subtree: true, childList: true });
        })();
      """;

String pushLivePosition({
  required double lat,
  required double lng,
  double? accuracy,
  int? updatedAt,
}) {
  final payload = <String, dynamic>{
    'lat': lat,
    'lng': lng,
    if (accuracy != null) 'accuracy': accuracy,
    'updatedAt': updatedAt ?? DateTime.now().millisecondsSinceEpoch,
  };

  return """
        (function() {
          try {
            window.__osakaLivePosition?.(${jsonEncode(payload)});
      } catch (e) {
      }
    })();
  """;
}

String pushCameraResult({
  required String status,
  String? filePath,
  int? durationMs,
  String? cameraFacing,
  String? mediaType,
  String? errorMessage,
  int? capturedAt,
}) {
  final payload = <String, dynamic>{
    'status': status,
    if (filePath != null) 'filePath': filePath,
    if (durationMs != null) 'durationMs': durationMs,
    if (cameraFacing != null) 'cameraFacing': cameraFacing,
    if (mediaType != null) 'mediaType': mediaType,
    if (errorMessage != null) 'errorMessage': errorMessage,
    'capturedAt': capturedAt ?? DateTime.now().millisecondsSinceEpoch,
  };

  return """
        (function() {
          try {
            var payload = ${jsonEncode(payload)};
            window.__osakaLiveCameraResultLast = payload;
            window.dispatchEvent(new CustomEvent('osaka-live-camera-result', { detail: payload }));
      } catch (e) {
      }
    })();
  """;
}

String pushCameraFileStart({
  required String transferId,
  required String fileName,
  required String mimeType,
  required int totalChunks,
  required int sizeBytes,
  int? durationMs,
  String? cameraFacing,
}) {
  final payload = <String, dynamic>{
    'transferId': transferId,
    'fileName': fileName,
    'mimeType': mimeType,
    'totalChunks': totalChunks,
    'sizeBytes': sizeBytes,
    if (durationMs != null) 'durationMs': durationMs,
    if (cameraFacing != null) 'cameraFacing': cameraFacing,
    'startedAt': DateTime.now().millisecondsSinceEpoch,
  };

  return _dispatchCustomEvent('osaka-live-camera-file-start', payload);
}

String pushCameraFileChunk({
  required String transferId,
  required int chunkIndex,
  required int totalChunks,
  required String chunk,
}) {
  final payload = <String, dynamic>{
    'transferId': transferId,
    'chunkIndex': chunkIndex,
    'totalChunks': totalChunks,
    'chunk': chunk,
  };

  return _dispatchCustomEvent('osaka-live-camera-file-chunk', payload);
}

String pushCameraFileComplete({
  required String transferId,
  required String fileName,
  required String mimeType,
  required int totalChunks,
  required int sizeBytes,
  int? durationMs,
  String? cameraFacing,
}) {
  final payload = <String, dynamic>{
    'transferId': transferId,
    'fileName': fileName,
    'mimeType': mimeType,
    'totalChunks': totalChunks,
    'sizeBytes': sizeBytes,
    if (durationMs != null) 'durationMs': durationMs,
    if (cameraFacing != null) 'cameraFacing': cameraFacing,
    'completedAt': DateTime.now().millisecondsSinceEpoch,
  };

  return _dispatchCustomEvent('osaka-live-camera-file-complete', payload);
}

String _dispatchCustomEvent(String eventName, Map<String, dynamic> payload) {
  return """
        (function() {
          try {
            var payload = ${jsonEncode(payload)};
            window.dispatchEvent(new CustomEvent('$eventName', { detail: payload }));
          } catch (e) {
          }
        })();
      """;
}

String navigate(String path) {
  return """
        (function() {
          try{
              webviewNavigate('$path');
          } catch(e){
              window.location.href = '$path';
          }
        })();
      """;
}

String setContacts(String payload) {
  return """
        (function() {
          setContacts('$payload');
        })();
      """;
}

String handleException(String message) {
  return """
        (function() {
          handleException('$message');
        })();
      """;
}
