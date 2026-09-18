// Copyright (c) Tailscale Inc & AUTHORS
// SPDX-License-Identifier: BSD-3-Clause

package com.tailscale.ipn

import android.net.VpnService
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class IPNServiceTest {
  @Test
  fun systemAlwaysOnStartRequiresForegroundServicePromotion() {
    assertTrue(shouldShowForegroundNotification(VpnService.SERVICE_INTERFACE))
    assertTrue(shouldShowForegroundNotification(IPNService.ACTION_START_VPN))
    assertTrue(shouldShowForegroundNotification(IPNService.ACTION_START_FOREGROUND_ONLY))
    assertFalse(shouldShowForegroundNotification(IPNService.ACTION_STOP_VPN))
  }

  @Test
  fun allowedPackagesIncludeTailscale() {
    val packages =
        packagesForVpnBuilder(
            packagesList = listOf("com.termux"),
            allowPackages = true,
            tailscalePackageName = "com.tailscale.ipn",
            builtInDisallowedPackages = emptyList(),
        )

    assertEquals(listOf("com.termux", "com.tailscale.ipn"), packages)
  }

  @Test
  fun excludedPackagesIncludeBuiltInDisallowedPackages() {
    val packages =
        packagesForVpnBuilder(
            packagesList = listOf("com.example.excluded"),
            allowPackages = false,
            tailscalePackageName = "com.tailscale.ipn",
            builtInDisallowedPackages = listOf("com.example.builtin"),
        )

    assertEquals(listOf("com.example.excluded", "com.example.builtin"), packages)
  }

  @Test
  fun emptyAllowedPackagesDoesNotAddTailscale() {
    val packages =
        packagesForVpnBuilder(
            packagesList = emptyList(),
            allowPackages = true,
            tailscalePackageName = "com.tailscale.ipn",
            builtInDisallowedPackages = emptyList(),
        )

    assertEquals(emptyList<String>(), packages)
  }

  @Test
  fun allowedPackagesDeduplicatesTailscale() {
    val packages =
        packagesForVpnBuilder(
            packagesList = listOf("com.termux", "com.tailscale.ipn"),
            allowPackages = true,
            tailscalePackageName = "com.tailscale.ipn",
            builtInDisallowedPackages = emptyList(),
        )

    assertEquals(listOf("com.termux", "com.tailscale.ipn"), packages)
  }
}
