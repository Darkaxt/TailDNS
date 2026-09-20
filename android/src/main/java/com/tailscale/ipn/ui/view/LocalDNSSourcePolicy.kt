// Copyright (c) Tailscale Inc & AUTHORS
// SPDX-License-Identifier: BSD-3-Clause

package com.tailscale.ipn.ui.view

fun isLocalDNSToggleEnabled(
    editable: Boolean,
    configured: Boolean,
    followAndroid: Boolean,
    manualEndpoint: String,
): Boolean {
  return editable && (configured || followAndroid || manualEndpoint.isNotBlank())
}
