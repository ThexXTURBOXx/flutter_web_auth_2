import 'dart:async';

import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:flutter_web_auth_2_platform_interface/flutter_web_auth_2_platform_interface.dart';
import 'package:path_provider/path_provider.dart';

/// Implements the plugin interface using the Webview interface (currently used
/// by Windows and Linux).
class FlutterWebAuth2WebViewPlugin extends FlutterWebAuth2Platform {
  bool _authenticated = false;
  Webview? _webview;

  @override
  Future<String> authenticate({
    required String url,
    required String callbackUrlScheme,
    required Map<String, dynamic> options,
  }) async {
    if (!await WebviewWindow.isWebviewAvailable()) {
      // Microsoft's WebView2 must be installed for this to work
      throw StateError('Webview is not available');
    }

    final parsedOptions = FlutterWebAuth2Options.fromJson(options);

    // Reset
    _authenticated = false;
    _webview?.close();

    final c = Completer<String>();
    _webview = await WebviewWindow.create(
      configuration: CreateConfiguration(
        windowHeight: 720,
        windowWidth: 1280,
        title: 'Authenticate',
        titleBarTopPadding: 0,
        userDataFolderWindows: (await getTemporaryDirectory()).path,
      ),
    );
    _webview!.setOnUrlRequestCallback((url) {
      final uri = Uri.parse(url);
      if (uri.scheme != callbackUrlScheme ||
          (parsedOptions.httpsHost != null &&
              uri.host != parsedOptions.httpsHost) ||
          (parsedOptions.httpsPath != null &&
              uri.path != parsedOptions.httpsPath)) {
        return true;
      }
      _authenticated = true;
      _webview?.close();
      /**
       * Not setting the webview to null will cause a crash if the
       * application tries to open another webview
       */
      _webview = null;
      c.complete(url);
      return true;
    });
    unawaited(
      _webview!.onClose.whenComplete(
        () {
          /**
           * Not setting the webview to null will cause a crash if the
           * application tries to open another webview
           */
          _webview = null;
          if (!_authenticated) {
            c.completeError(
              PlatformException(code: 'CANCELED', message: 'User canceled'),
            );
          }
        },
      ),
    );
    _webview!.launch(url);
    return c.future;
  }

  @override
  Future<void> clearAllDanglingCalls() async {}
}
