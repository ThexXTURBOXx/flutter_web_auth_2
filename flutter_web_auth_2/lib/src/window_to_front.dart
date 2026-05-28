import 'package:flutter/services.dart';

class WindowToFront {
  static const MethodChannel _channel = MethodChannel('flutter_web_auth_2');

  static Future<void> activate() async {
    try {
      await _channel.invokeMethod<void>('activate');
    } on MissingPluginException {
      // Best-effort on desktop; ignore if not implemented.
    } on PlatformException {
      // Best-effort on desktop; ignore if activation fails.
    }
  }
}
