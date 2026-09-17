import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

void main() {
  const channel = MethodChannel('flutter_web_auth_2');
  var expectedPreferAuthTabs = true;

  setUp(() {
    expectedPreferAuthTabs = true;
    TestWidgetsFlutterBinding.ensureInitialized();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async {
      expect(methodCall.method, 'authenticate');

      expect(
        methodCall.arguments['url'] as String,
        'https://example.com/login',
      );
      expect(methodCall.arguments['callbackUrlScheme'] as String, 'foobar');
      expect(
        methodCall.arguments['options']['preferAuthTabs'] as bool,
        expectedPreferAuthTabs,
      );

      return 'https://example.com/success';
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('authenticate', () async {
    expect(
      await FlutterWebAuth2.authenticate(
        url: 'https://example.com/login',
        callbackUrlScheme: 'foobar',
      ),
      'https://example.com/success',
    );
  });

  test('can force a regular Custom Tab on Android', () async {
    expectedPreferAuthTabs = false;

    expect(
      await FlutterWebAuth2.authenticate(
        url: 'https://example.com/login',
        callbackUrlScheme: 'foobar',
        options: const FlutterWebAuth2Options(preferAuthTabs: false),
      ),
      'https://example.com/success',
    );
  });

  test('invalid scheme', () async {
    await expectLater(
      FlutterWebAuth2.authenticate(
        url: 'https://example.com/login',
        callbackUrlScheme: 'foobar://test',
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}
