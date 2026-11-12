import 'package:flutter_web_auth_2_desktop_webview/src/webview.dart';
import 'package:flutter_web_auth_2_platform_interface/flutter_web_auth_2_platform_interface.dart';

export 'src/webview.dart';

/// Creates the webview that serves `useWebview: true` on Linux and Windows.
FlutterWebAuth2Platform? createDesktopWebview() =>
    FlutterWebAuth2WebViewPlugin();
