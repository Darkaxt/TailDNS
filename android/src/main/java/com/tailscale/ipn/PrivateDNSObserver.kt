// Copyright (c) Tailscale Inc & AUTHORS
// SPDX-License-Identifier: BSD-3-Clause
package com.tailscale.ipn

import android.content.ContentResolver
import android.database.ContentObserver
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

/** Platform settings source only; mapping, profile ownership and selection belong to Go. */
class PrivateDNSObserver(private val resolver: ContentResolver, private val changed: () -> Unit) {
  private val observer =
      object : ContentObserver(Handler(Looper.getMainLooper())) {
        override fun onChange(selfChange: Boolean) {
          changed()
        }
      }
  private var observing = false

  @Serializable private data class Source(val Hostname: String, val Mode: String)

  fun read(): String =
      Json.encodeToString(
          Source(
              Settings.Global.getString(resolver, "private_dns_specifier").orEmpty(),
              Settings.Global.getString(resolver, "private_dns_mode")
                  ?: Settings.Global.getString(resolver, "private_dns_default_mode").orEmpty(),
          )
      )

  @Synchronized
  fun setEnabled(enabled: Boolean) {
    if (enabled == observing) return
    if (!enabled) {
      resolver.unregisterContentObserver(observer)
      observing = false
      return
    }
    try {
      for (key in listOf("private_dns_specifier", "private_dns_mode", "private_dns_default_mode")) {
        resolver.registerContentObserver(Settings.Global.getUriFor(key), false, observer)
      }
      observing = true
    } catch (error: Exception) {
      resolver.unregisterContentObserver(observer)
      throw IllegalStateException("Android DNS settings observation unavailable")
    }
  }
}
