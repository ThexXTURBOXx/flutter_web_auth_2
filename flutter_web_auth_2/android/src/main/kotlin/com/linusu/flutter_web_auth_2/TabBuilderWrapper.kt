package com.linusu.flutter_web_auth_2

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Intent
import android.net.Uri
import androidx.activity.result.ActivityResultLauncher
import androidx.browser.auth.AuthTabIntent
import androidx.browser.customtabs.CustomTabsIntent

interface TabBuilderWrapper {
    fun setEphemeralBrowsingEnabled(enabled: Boolean): TabBuilderWrapper
    fun build(): IntentWrapper
}

interface IntentWrapper {
    val intent: Intent
    fun launch(activity: Activity, launcher: ActivityResultLauncher<Intent>, url: Uri, redirectHost: String, redirectPath: String)
    fun launch(activity: Activity, launcher: ActivityResultLauncher<Intent>, url: Uri, redirectScheme: String)
}

@SuppressLint("UnsafeOptInUsageError", "UnsafeOptInUsageWarning")
class CtBuilderWrapper(private val b: CustomTabsIntent.Builder) : TabBuilderWrapper {
    override fun setEphemeralBrowsingEnabled(enabled: Boolean) = apply { b.setEphemeralBrowsingEnabled(enabled) }

    override fun build(): IntentWrapper {
        val intent = b.build()
        return object : IntentWrapper {

            override val intent: Intent
                get() = intent.intent

            override fun launch(activity: Activity, launcher: ActivityResultLauncher<Intent>, url: Uri, redirectHost: String, redirectPath: String) {
                intent.launchUrl(activity, url)
            }

            override fun launch(activity: Activity, launcher: ActivityResultLauncher<Intent>, url: Uri, redirectScheme: String) {
                intent.launchUrl(activity, url)
            }
        }
    }
}

@SuppressLint("UnsafeOptInUsageError", "UnsafeOptInUsageWarning")
class AuthTabBuilderWrapper(private val b: AuthTabIntent.Builder) : TabBuilderWrapper {

    override fun setEphemeralBrowsingEnabled(enabled: Boolean) = apply { b.setEphemeralBrowsingEnabled(enabled) }

    override fun build(): IntentWrapper {
        val intent = b.build()
        return object : IntentWrapper {

            override val intent: Intent
                get() = intent.intent

            override fun launch(activity: Activity, launcher: ActivityResultLauncher<Intent>, url: Uri, redirectHost: String, redirectPath: String) {
                intent.launch(launcher, url, redirectHost, redirectPath)
            }

            override fun launch(activity: Activity, launcher: ActivityResultLauncher<Intent>, url: Uri, redirectScheme: String) {
                intent.launch(launcher, url, redirectScheme)
            }
        }
    }
}
