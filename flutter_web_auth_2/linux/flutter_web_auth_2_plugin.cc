#include "include/flutter_web_auth_2/flutter_web_auth_2_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

#include <string.h>

#define FLUTTER_WEB_AUTH_2_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), flutter_web_auth_2_plugin_get_type(), \
                              FlutterWebAuth2Plugin))

struct _FlutterWebAuth2Plugin {
  GObject parent_instance;

  FlPluginRegistrar* registrar;
};

G_DEFINE_TYPE(FlutterWebAuth2Plugin, flutter_web_auth_2_plugin, g_object_get_type())

static void flutter_web_auth_2_plugin_handle_method_call(
    FlutterWebAuth2Plugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "activate") == 0) {
    FlView* view = fl_plugin_registrar_get_view(self->registrar);
    if (view != nullptr) {
      GtkWidget* toplevel = gtk_widget_get_toplevel(GTK_WIDGET(view));
      if (GTK_IS_WINDOW(toplevel)) {
        gtk_window_present(GTK_WINDOW(toplevel));
      }
    }

    response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void flutter_web_auth_2_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(flutter_web_auth_2_plugin_parent_class)->dispose(object);
}

static void flutter_web_auth_2_plugin_class_init(FlutterWebAuth2PluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = flutter_web_auth_2_plugin_dispose;
}

static void flutter_web_auth_2_plugin_init(FlutterWebAuth2Plugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  FlutterWebAuth2Plugin* plugin = FLUTTER_WEB_AUTH_2_PLUGIN(user_data);
  flutter_web_auth_2_plugin_handle_method_call(plugin, method_call);
}

void flutter_web_auth_2_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  FlutterWebAuth2Plugin* plugin = FLUTTER_WEB_AUTH_2_PLUGIN(
      g_object_new(flutter_web_auth_2_plugin_get_type(), nullptr));

  plugin->registrar = FL_PLUGIN_REGISTRAR(g_object_ref(registrar));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "flutter_web_auth_2",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}
