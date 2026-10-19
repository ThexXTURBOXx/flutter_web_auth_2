import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:flutter_web_auth_2_desktop_webview/src/webview.dart';

export 'src/webview.dart';

/// Serves `useWebview: true` on Linux and Windows.
///
/// Depending on this package is what links WebKitGTK and WebView2; without it
/// `flutter_web_auth_2` authenticates through the browser instead.
class FlutterWebAuth2DesktopWebview {
  /// Hands the webview implementation to the Linux and Windows plugin.
  static void registerWith() {
    DesktopWebview.implementation = FlutterWebAuth2WebViewPlugin();
  }
}
