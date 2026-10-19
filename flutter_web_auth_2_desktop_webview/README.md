# flutter_web_auth_2_desktop_webview

Authenticates in an in-app webview on Linux and Windows, for
[`flutter_web_auth_2`](https://pub.dev/packages/flutter_web_auth_2).

`flutter_web_auth_2` authenticates through the system browser and a loopback
server on these platforms. Depending on this package in addition makes
`useWebview: true` work, and is what links WebKitGTK on Linux and WebView2 on
Windows — which is why it is kept separate: an app that does not need the
webview does not have to ship either.

```yaml
dependencies:
  flutter_web_auth_2: ^6.0.0
  flutter_web_auth_2_desktop_webview: ^6.0.0
```

Nothing else is required. The webview registers itself, and
`FlutterWebAuth2.authenticate(..., options: FlutterWebAuth2Options(useWebview: true))`
then opens it.

Note that Google rejects embedded webviews for OAuth with
`disallowed_useragent`, so the browser flow is the only one that works with some
providers.
