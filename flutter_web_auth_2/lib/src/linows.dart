import 'dart:async';

import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:flutter_web_auth_2/src/server.dart';
import 'package:flutter_web_auth_2_desktop_webview/flutter_web_auth_2_desktop_webview.dart';
import 'package:flutter_web_auth_2_platform_interface/flutter_web_auth_2_platform_interface.dart';

/// Implements the plugin interface for Linux and Windows (Linows).
class FlutterWebAuth2LinowsPlugin extends FlutterWebAuth2Platform {
  final FlutterWebAuth2Platform _serverImpl = FlutterWebAuth2ServerPlugin();
  final FlutterWebAuth2Platform? _webviewImpl = createDesktopWebview();

  /// Registers the Linows super-implementation.
  static void registerWith() {
    FlutterWebAuth2Platform.instance = FlutterWebAuth2LinowsPlugin();
  }

  @override
  Future<String> authenticate({
    required String url,
    required String callbackUrlScheme,
    required Map<String, dynamic> options,
  }) async {
    final parsedOptions = FlutterWebAuth2Options.fromJson(options);
    if (parsedOptions.useWebview) {
      if (_webviewImpl == null) {
        throw StateError(
          'useWebview: true needs a webview, but '
          'flutter_web_auth_2_desktop_webview is overridden with its stub. '
          'Remove the override, or pass useWebview: false.',
        );
      }
      return _webviewImpl.authenticate(
        url: url,
        callbackUrlScheme: callbackUrlScheme,
        options: options,
      );
    }
    return _serverImpl.authenticate(
      url: url,
      callbackUrlScheme: callbackUrlScheme,
      options: options,
    );
  }

  @override
  Future clearAllDanglingCalls() async {
    await _serverImpl.clearAllDanglingCalls();
    await _webviewImpl?.clearAllDanglingCalls();
  }
}
