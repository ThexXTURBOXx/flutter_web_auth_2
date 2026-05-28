import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:flutter_web_auth_2_platform_interface/flutter_web_auth_2_platform_interface.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_web_auth_2/src/window_to_front.dart';

/// Implements the plugin interface using an internal server (currently used by
/// Windows and Linux).
class FlutterWebAuth2ServerPlugin extends FlutterWebAuth2Platform {
  HttpServer? _server;
  Timer? _authTimeout;

  @override
  Future<String> authenticate({
    required String url,
    required String callbackUrlScheme,
    required Map<String, dynamic> options,
  }) async {
    final parsedOptions = FlutterWebAuth2Options.fromJson(options);

    // Validate callback url
    final callbackUri = Uri.parse(callbackUrlScheme);

    if (callbackUri.scheme != 'http' ||
        (callbackUri.host != 'localhost' && callbackUri.host != '127.0.0.1') ||
        !callbackUri.hasPort) {
      throw ArgumentError(
        'Callback url scheme must start with http://localhost:{port}',
      );
    }

    await _server?.close(force: true);

    _server = await HttpServer.bind('127.0.0.1', callbackUri.port);
    String? result;

    _authTimeout?.cancel();
    _authTimeout = Timer(Duration(seconds: parsedOptions.timeout), () {
      _server?.close();
    });

    await launchUrl(Uri.parse(url));

    await _server!.listen((req) async {
      req.response.headers.add('Content-Type', 'text/html');
      req.response.write(parsedOptions.landingPageHtml);
      await req.response.close();

      result = req.requestedUri.toString();
      await _server?.close();
      _server = null;
    }).asFuture();

    await _server?.close(force: true);
    _authTimeout?.cancel();

    if (result != null) {
      await WindowToFront.activate();
      return result!;
    }
    throw PlatformException(message: 'User canceled login', code: 'CANCELED');
  }

  @override
  Future clearAllDanglingCalls() async {
    await _server?.close(force: true);
  }
}
