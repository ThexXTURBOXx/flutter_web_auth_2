#include "include/flutter_web_auth_2/flutter_web_auth_2_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <map>
#include <memory>

namespace {

class FlutterWebAuth2Plugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  explicit FlutterWebAuth2Plugin(flutter::PluginRegistrarWindows* registrar);

  ~FlutterWebAuth2Plugin() override;

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<>> result);

  flutter::PluginRegistrarWindows* registrar_;
};

void FlutterWebAuth2Plugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto channel = std::make_unique<flutter::MethodChannel<>>(
      registrar->messenger(), "flutter_web_auth_2",
      &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<FlutterWebAuth2Plugin>(registrar);

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

FlutterWebAuth2Plugin::FlutterWebAuth2Plugin(
    flutter::PluginRegistrarWindows* registrar)
    : registrar_(registrar) {}

FlutterWebAuth2Plugin::~FlutterWebAuth2Plugin() {}

void FlutterWebAuth2Plugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<>> result) {
  if (method_call.method_name().compare("activate") == 0) {
    // Raise the Flutter window to the foreground.
    HWND window = registrar_->GetView()->GetNativeWindow();
    if (window != nullptr) {
      HWND current_window = ::GetForegroundWindow();
      DWORD current_thread = ::GetWindowThreadProcessId(current_window, nullptr);
      DWORD this_thread = ::GetCurrentThreadId();
      ::AttachThreadInput(current_thread, this_thread, TRUE);
      ::SetWindowPos(window, HWND_TOPMOST, 0, 0, 0, 0,
                     SWP_NOSIZE | SWP_NOMOVE);
      ::SetWindowPos(window, HWND_NOTOPMOST, 0, 0, 0, 0,
                     SWP_SHOWWINDOW | SWP_NOSIZE | SWP_NOMOVE);
      ::SetForegroundWindow(window);
      ::SetFocus(window);
      ::SetActiveWindow(window);
      ::AttachThreadInput(current_thread, this_thread, FALSE);
    }
    result->Success();
  } else {
    result->NotImplemented();
  }
}

}  // namespace

void FlutterWebAuth2PluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  FlutterWebAuth2Plugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
