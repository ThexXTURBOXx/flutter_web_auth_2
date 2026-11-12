# flutter_web_auth_2_desktop_webview

The in-app webview that
[`flutter_web_auth_2`](https://pub.dev/packages/flutter_web_auth_2) uses for
`useWebview: true` on Linux and Windows. It links WebKitGTK on Linux and
WebView2 on Windows.

`flutter_web_auth_2` already depends on this package, so you don't need to add
it.

If you only use `useWebview: false`, you can replace this package with a stub so
that no webview is linked. See
[Without the webview](https://pub.dev/packages/flutter_web_auth_2#without-the-webview)
in the `flutter_web_auth_2` README.
