// Adapted from https://gist.github.com/rydmike/1771fe24c050ebfe792fa309371154d8

// ignore: avoid_web_libraries_in_flutter
import 'package:web/web.dart';

// NOTE:
// Never import this library directly in the application. The PlatformIs
// class and library uses conditional imports to only import this file on
// Web platform builds.

final Navigator _nav = window.navigator;

/// UniversalPlatform for Flutter WEB build.
///
/// We can use dart:html Navigator to get the current platform.
///
/// This function is borrowed, with minor modifications, from GetX utils library
/// with MIT license.
/// Credits for it belong to its author Jonny Borges https://github.com/jonataslaw
/// https://github.com/jonataslaw/getx/blob/master/lib/get_utils/src/platform/platform_web.dart
///
class UniversalPlatform {
  UniversalPlatform._();

  /// Is Web?
  static bool get web => true;

  /// Is macOS?
  static bool get macOS => _nav.appVersion.contains('Mac OS') && !iOS;

  /// Is Windows?
  static bool get windows => _nav.appVersion.contains('Win');

  /// Is Linux?
  static bool get linux =>
      (_nav.appVersion.contains('Linux') || _nav.appVersion.contains('x11')) &&
      !android;

  /// Is Android?
  /// Source: https://developer.chrome.com/multidevice/user-agent
  static bool get android => _nav.appVersion.contains('Android ');

  /// Is iOS?
  /// maxTouchPoints is needed to separate iPad iOS13 vs new MacOS
  static bool get iOS =>
      _hasMatch(_nav.platform, '/iPad|iPhone|iPod/') ||
      (_nav.platform == 'MacIntel' && _nav.maxTouchPoints > 1);

  /// Is Fuchsia?
  /// Theoretically we could be in a Web browser on Fuchsia too, but
  /// we have no info on how to get that info yet, so we return false.
  static bool get fuchsia => false;
}

bool _hasMatch(String? value, String pattern) =>
    // ignore: avoid_bool_literals_in_conditional_expressions
    (value == null) ? false : RegExp(pattern).hasMatch(value);
