// Copyright (c) Tailscale Inc & AUTHORS
// SPDX-License-Identifier: BSD-3-Clause

package com.tailscale.ipn.ui.model

import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import org.junit.Assert.*
import org.junit.Test

class LocalDNSTest {
  @Test
  fun updatePreservesProfileAndEndpointButDoesNotLogThem() {
    val update = LocalDNSUpdate("profile-a", true, "https://dns.controld.com/private-client")
    val json = Json.encodeToString(update)
    assertEquals(update, Json.decodeFromString<LocalDNSUpdate>(json))
    assertFalse(update.toString().contains("private-client"))
    assertTrue(json.contains("profile-a"))
  }

  @Test
  fun appliedDoesNotImplyReachability() {
    val saved =
        Json.decodeFromString<LocalDNSStatus>(
            """{"ProfileID":"a","Configured":true,"Endpoint":"https://dns.controld.com/private-client","Applied":false,"Reason":"Not applied"}"""
        )
    assertTrue(saved.Configured)
    assertFalse(saved.Applied)
    assertFalse(saved.toString().contains("private-client"))
  }
}
