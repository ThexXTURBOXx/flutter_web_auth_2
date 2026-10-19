import 'package:flutter_web_auth_2_platform_interface/flutter_web_auth_2_platform_interface.dart';

/// Where the in-app webview for Linux and Windows is registered.
///
/// `flutter_web_auth_2_desktop_webview` fills this in. Without that package it
/// stays null, no webview is linked, and `useWebview: true` throws.
class DesktopWebview {
  /// What `useWebview: true` authenticates in.
  static FlutterWebAuth2Platform? implementation;
}
