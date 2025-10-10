package com.linusu.flutter_web_auth_2

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build

object PackageNames {
    const val CHROME_STABLE = "com.android.chrome"
    const val CHROME_BETA = "com.chrome.beta"
    const val CHROME_DEV = "com.chrome.dev"
    const val MICROSOFT_EDGE = "com.microsoft.emmx"
    const val FIREFOX = "org.mozilla.firefox"
    const val SAMSUNG_INTERNET = "com.sec.android.app.sbrowser"
}

val Any.LOG_TAG: String
    get() = "flutter_web_auth_2"

fun Context.getInstalledVersion(packageName: String): String? {
    try {
        val packageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.getPackageInfo(packageName, PackageManager.PackageInfoFlags.of(0))
        } else {
            @Suppress("DEPRECATION")
            packageManager.getPackageInfo(packageName, 0)
        }
        return packageInfo.versionName
    } catch (_: Exception) {
        return null
    }
}

fun Context.getPackagesForIntent(intent: Intent): List<String> {
    try {
        val list = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            packageManager.queryIntentActivities(intent, PackageManager.MATCH_ALL)
        } else {
            packageManager.queryIntentActivities(intent, 0)
        }
        return list.map { it.activityInfo.packageName }
    } catch (_: Exception) {
        return emptyList()
    }
}
