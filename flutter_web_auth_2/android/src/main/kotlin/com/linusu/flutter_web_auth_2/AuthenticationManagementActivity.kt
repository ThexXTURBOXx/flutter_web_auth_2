package com.linusu.flutter_web_auth_2

import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResultLauncher
import androidx.browser.auth.AuthTabIntent
import androidx.browser.auth.AuthTabIntent.AuthResult
import androidx.browser.customtabs.CustomTabsIntent

@SuppressLint("UnsafeOptInUsageError", "UnsafeOptInUsageWarning")
class AuthenticationManagementActivity : ComponentActivity() {
    companion object {
        const val KEY_AUTH_STARTED: String = "authStarted"
        const val KEY_AUTH_URI: String = "authUri"
        const val KEY_AUTH_OPTION_INTENT_FLAGS: String = "authOptionsIntentFlags"
        const val KEY_AUTH_OPTION_TARGET_PACKAGE: String = "authOptionsTargetPackage"
        const val KEY_AUTH_OPTION_PREFER_EPHEMERAL: String = "authOptionsPreferEphemeral"
        const val KEY_AUTH_CALLBACK_SCHEME: String = "authCallbackScheme"
        const val KEY_AUTH_CALLBACK_HOST: String = "authCallbackHost"
        const val KEY_AUTH_CALLBACK_PATH: String = "authCallbackPath"

        fun createResponseHandlingIntent(context: Context): Intent {
            val intent = Intent(context, AuthenticationManagementActivity::class.java)
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            return intent
        }
    }

    private var authStarted: Boolean = false
    private lateinit var authenticationUri: Uri
    private var intentFlags: Int = 0
    private var targetPackage: String? = null
    private var preferEphemeral: Boolean = false
    private lateinit var callbackScheme: String
    private var callbackHost: String? = null
    private var callbackPath: String? = null

    private lateinit var authLauncher: ActivityResultLauncher<Intent>

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Register the activity result launcher
        authLauncher = AuthTabIntent.registerActivityResultLauncher(this, this::handleAuthResult)

        if (savedInstanceState == null) {
            extractState(intent.extras)
        } else {
            extractState(savedInstanceState)
        }
    }

    private fun handleAuthResult(result: AuthResult) {
        val callback = FlutterWebAuth2Plugin.callbacks[callbackScheme]
        if (callback == null) {
            finish()
            return
        }

        when (result.resultCode) {
            AuthTabIntent.RESULT_OK -> {
                callback.success(result.resultUri!!.toString())
            }

            AuthTabIntent.RESULT_CANCELED -> {
                callback.error("CANCELED", "User canceled authentication", null)
            }

            else -> {
                callback.error("FAILED", "Authentication failed with code: ${result.resultCode}", null)
            }
        }

        FlutterWebAuth2Plugin.callbacks.remove(callbackScheme)
        finish()
    }

    override fun onResume() {
        super.onResume()

        if (!authStarted) {

            val intentBuilder = if (shouldUseAuthTabs()) {
                Log.d(LOG_TAG, "Using AuthTabIntent")
                AuthTabBuilderWrapper(AuthTabIntent.Builder())
            } else {
                Log.d(LOG_TAG, "Using CustomTabsIntent")
                CtBuilderWrapper(CustomTabsIntent.Builder())
            }

            // Set ephemeral browsing if requested and supported
            if (preferEphemeral) {
                try {
                    intentBuilder.setEphemeralBrowsingEnabled(true)
                    Log.d(LOG_TAG, "Ephemeral browsing enabled")
                } catch (e: Exception) {
                    Log.w(LOG_TAG, "Failed to enable ephemeral browsing: ${e.message}")
                }
            }

            val intent = intentBuilder.build()

            intent.intent.addFlags(intentFlags)
            if (targetPackage != null) {
                intent.intent.setPackage(targetPackage)
            }

            try {
                if (callbackScheme == "https" && callbackHost != null && callbackPath != null) {
                    Log.d(LOG_TAG, "Using https host and path: $callbackHost, $callbackPath")
                    intent.launch(this, authLauncher, authenticationUri, callbackHost!!, callbackPath!!)
                } else {
                    Log.d(LOG_TAG, "Using custom scheme: $callbackScheme")
                    intent.launch(this, authLauncher, authenticationUri, callbackScheme)
                }
            } catch (e: android.content.ActivityNotFoundException){
                Log.e(LOG_TAG, "Failed to start authentication. No browser available (Activity not found)")
                val callback = FlutterWebAuth2Plugin.callbacks[callbackScheme]
                callback?.error("NO_BROWSER", "No valid browser available for authentication.", e.message)
                FlutterWebAuth2Plugin.callbacks.remove(callbackScheme)
                finish()
            }

            authStarted = true
            return
        }
        /* If the authentication was already started and we've returned here, the user either
         * completed or cancelled authentication.
         * Either way we want to return to our original flutter activity, so just finish here
         */
        finish()
    }

    fun shouldUseAuthTabs(): Boolean {

        if (!preferEphemeral || targetPackage == null) return true
        val packageMajorVersion = getInstalledVersion(targetPackage!!)?.substringBefore(".")?.toIntOrNull() ?: 0
        Log.d(LOG_TAG, "Chosen package: $targetPackage with version: $packageMajorVersion")

        val chromePackages = setOf(
            PackageNames.CHROME_STABLE,
            PackageNames.CHROME_BETA,
            PackageNames.CHROME_DEV,
        )

        if (chromePackages.contains(targetPackage)) {
            return packageMajorVersion >= 141
        } else if (targetPackage == PackageNames.MICROSOFT_EDGE) {
            return packageMajorVersion >= 141
        } else if (targetPackage == PackageNames.SAMSUNG_INTERNET) {
            return packageMajorVersion >= 28
        } else if (targetPackage == PackageNames.FIREFOX) {
            return packageMajorVersion >= 143
        }

        return true
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        outState.putBoolean(KEY_AUTH_STARTED, authStarted)
        outState.putParcelable(KEY_AUTH_URI, authenticationUri)
        outState.putInt(KEY_AUTH_OPTION_INTENT_FLAGS, intentFlags)
        outState.putString(KEY_AUTH_OPTION_TARGET_PACKAGE, targetPackage)
        outState.putBoolean(KEY_AUTH_OPTION_PREFER_EPHEMERAL, preferEphemeral)
        outState.putString(KEY_AUTH_CALLBACK_SCHEME, callbackScheme)
        outState.putString(KEY_AUTH_CALLBACK_HOST, callbackHost)
        outState.putString(KEY_AUTH_CALLBACK_PATH, callbackPath)
    }

    private fun extractState(state: Bundle?) {
        if (state == null) {
            finish()
            return
        }
        authStarted = state.getBoolean(KEY_AUTH_STARTED, false)
        authenticationUri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            state.getParcelable(KEY_AUTH_URI, Uri::class.java)
        } else {
            @Suppress("deprecation")
            state.getParcelable(KEY_AUTH_URI)
        } ?: throw IllegalStateException("Authentication URI is null")
        intentFlags = state.getInt(KEY_AUTH_OPTION_INTENT_FLAGS, 0)
        targetPackage = state.getString(KEY_AUTH_OPTION_TARGET_PACKAGE)
        preferEphemeral = state.getBoolean(KEY_AUTH_OPTION_PREFER_EPHEMERAL, false)
        callbackScheme = state.getString(KEY_AUTH_CALLBACK_SCHEME)!!
        callbackHost = state.getString(KEY_AUTH_CALLBACK_HOST)
        callbackPath = state.getString(KEY_AUTH_CALLBACK_PATH)
    }
}
