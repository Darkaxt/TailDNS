// Copyright (c) Tailscale Inc & AUTHORS
// SPDX-License-Identifier: BSD-3-Clause

package com.tailscale.ipn.ui.model

import kotlinx.serialization.Serializable

@Serializable
data class LocalDNSStatus(
    val ProfileID: String = "",
    val Configured: Boolean = false,
    val Endpoint: String = "",
    val Applied: Boolean = false,
    val Reason: String = "",
    val FollowAndroid: Boolean = false,
    val ManualEndpoint: String = "",
    val SystemMode: String = "",
) {
  override fun toString() = "LocalDNSStatus(configured=$Configured, applied=$Applied)"
}

@Serializable
data class LocalDNSUpdate(
    val ProfileID: String,
    val Enabled: Boolean,
    val Endpoint: String,
    val FollowAndroid: Boolean = false,
) {
  override fun toString() = "LocalDNSUpdate(enabled=$Enabled, endpoint=<redacted>)"
}
