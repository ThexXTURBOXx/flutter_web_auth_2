import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/src/options.dart';
import 'package:flutter_web_auth_2_platform_interface/flutter_web_auth_2_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:url_launcher/url_launcher.dart';

class FlutterWebAuth2WebPlugin extends FlutterWebAuth2Platform {
  static void registerWith(Registrar registrar) {
    final channel = MethodChannel(
      'flutter_web_auth_2',
      const StandardMethodCodec(),
      registrar,
    );
    final instance = FlutterWebAuth2WebPlugin();
    channel.setMethodCallHandler(instance.handleMethodCall);
    FlutterWebAuth2Platform.instance = instance;
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'authenticate':
        final url = call.arguments['url'].toString();
        return authenticate(
          url: url,
          callbackUrlScheme: '',
          options: call.arguments['options'],
        );
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: "The flutter_web_auth_2 plugin for web doesn't implement "
              "the method '${call.method}'",
        );
    }
  }

  @override
  Future<String> authenticate({
    required String url,
    required String callbackUrlScheme,
    required Map<String, dynamic> options,
  }) async {
    final parsedOptions = FlutterWebAuth2Options.fromJson(options);

    if (parsedOptions.silentAuth) {
      final authIframe = IFrameElement()
        ..src = url
        ..style.display = 'none';

      document.body?.append(authIframe);

      final completer = Completer<String>();
      StreamSubscription? messageSubscription;
      Timer? responseTimeoutTimer;

      messageSubscription = window.onMessage.listen((messageEvent) {
        if (messageEvent.origin ==
            (parsedOptions.debugOrigin ?? Uri.base.origin)) {
          final flutterWebAuthMessage = messageEvent.data['flutter-web-auth-2'];
          if (flutterWebAuthMessage is String) {
            authIframe.remove();
            completer.complete(flutterWebAuthMessage);
            responseTimeoutTimer?.cancel();
            messageSubscription?.cancel();
          }
        }
      });

      // Add a timeout for the iframe response
      responseTimeoutTimer =
          Timer(Duration(seconds: parsedOptions.timeout), () {
        authIframe.remove();
        messageSubscription?.cancel();
        completer.completeError(
          PlatformException(
            code: 'timeout',
            message: 'Timeout waiting for the iframe response',
          ),
        );
      });

      return completer.future;
    } else {
      await launchUrl(
        Uri.parse(url),
        webOnlyWindowName: parsedOptions.windowName,
      );
    }

    // Remove the old record if it exists
    const storageKey = 'flutter-web-auth-2';
    window.localStorage.remove(storageKey);
    Timer? lsTimer;
    StreamSubscription? messageSubscription;
    final completer = Completer<String>();
    try {
      // Periodically check for the callback value in local storage.
      // If it exists, return it. If not, check the timeout.
      // If the timeout has passed, throw an exception.
      lsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (window.localStorage.containsKey(storageKey)) {
          final flutterWebAuthMessage = window.localStorage[storageKey];
          if (flutterWebAuthMessage is String) {
            completer.complete(flutterWebAuthMessage);
            window.localStorage.remove(storageKey);
            messageSubscription?.cancel();
            timer.cancel();
          } else {
            messageSubscription?.cancel();
            timer.cancel();
            completer.completeError(
              PlatformException(
                code: 'error',
                message: 'Callback value is not a string',
              ),
            );
          }
        } else if (timer.tick >= parsedOptions.timeout) {
          messageSubscription?.cancel();
          timer.cancel();
          completer.completeError(
            PlatformException(
              code: 'error',
              message: 'Timeout waiting for callback value',
            ),
          );
        }
      });

      // Traditional window.opener method of listening for the redirect
      messageSubscription = window.onMessage.listen(
        (messageEvent) {
          if (messageEvent.origin ==
              (parsedOptions.debugOrigin ?? Uri.base.origin)) {
            final flutterWebAuthMessage =
                messageEvent.data['flutter-web-auth-2'];
            if (flutterWebAuthMessage is String) {
              lsTimer?.cancel();
              messageSubscription?.cancel();
              completer.complete(flutterWebAuthMessage);
            }
          }

          final appleOrigin = Uri(scheme: 'https', host: 'appleid.apple.com');
          if (messageEvent.origin == appleOrigin.toString()) {
            try {
              final data = jsonDecode(messageEvent.data.toString());
              if (data['method'] == 'oauthDone') {
                final appleAuth =
                    data['data']['authorization'] as Map<String, dynamic>?;
                if (appleAuth != null) {
                  final appleAuthQuery = Uri(queryParameters: appleAuth).query;
                  lsTimer?.cancel();
                  messageSubscription?.cancel();
                  completer.complete(
                    appleOrigin.replace(fragment: appleAuthQuery).toString(),
                  );
                }
              }
            } on FormatException {
              // ignore exception
            }
          }
        },
        onError: (error) {
          lsTimer?.cancel();
          messageSubscription?.cancel();
          throw error;
        },
      );
    } catch (e) {
      lsTimer?.cancel();
      completer.completeError(e);
    }

    return completer.future;
  }
}
