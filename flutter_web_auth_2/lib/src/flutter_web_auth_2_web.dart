import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:js';

import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2_platform_interface/flutter_web_auth_2_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

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
          preferEphemeral: false,
          redirectOriginOverride:
              call.arguments['redirectOriginOverride']?.toString(),
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
    required bool preferEphemeral,
    String? redirectOriginOverride,
    List contextArgs = const [],
  }) async {

    context.callMethod('open', <dynamic>[url] + contextArgs);
    
    //new method using local storage as a work-around 
    //for some browsers & oauth implementations

      //remove the old record if it exists
      const storageKey = 'flutter-web-auth-2';
      const timeout = Duration(minutes: 5);
      window.localStorage.remove(storageKey);
      final timeoutTime = DateTime.now().add(timeout);
      Timer? lsTimer;
      StreamSubscription? messageSubscription;
      final completer = Completer<String>();
      try{
        //periodicity check for the callback value in local storage.
        //if it exists, return it.  if not, check the timeout.
        //if the timeout has passed, throw an exception.
        lsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          
          if(window.localStorage.containsKey(storageKey)) {
            final flutterWebAuthMessage = window.localStorage[storageKey];
            if (flutterWebAuthMessage is String) {
              completer.complete(flutterWebAuthMessage);
              window.localStorage.remove(storageKey);
              messageSubscription?.cancel();
              timer.cancel();
            } else {
              throw PlatformException(
                code: 'error',
                message: 'Callback value is not a string',
              );
            }
          } else if(DateTime.now().isAfter(timeoutTime)) {
            throw PlatformException(
              code: 'error',
              message: 'Timeout waiting for callback value',
            );
          }
        });

      

        //Traditional window.opener method of listening for the redirect
        messageSubscription = window.onMessage.listen((MessageEvent messageEvent) {

          if (messageEvent.origin == (redirectOriginOverride ?? Uri.base.origin)) {
            final flutterWebAuthMessage = messageEvent.data['flutter-web-auth-2'];
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
                  completer.complete(appleOrigin.replace(fragment: appleAuthQuery).toString());
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
      } catch(e) {
        lsTimer?.cancel();
        completer.completeError(e);
      }

      return completer.future;
  }
}
