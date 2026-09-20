// Copyright (c) Tailscale Inc & AUTHORS
// SPDX-License-Identifier: BSD-3-Clause

package com.tailscale.ipn.ui.view

import org.junit.Assert.assertEquals
import org.junit.Assert.fail
import org.junit.Test

class DNSSettingsViewPolicyTest {
  @Test
  fun localEnableRequiresSelectedSourceButConfiguredStateCanBeDisabled() {
    val cases =
        listOf(
            Case(editable = true, configured = false, followAndroid = false, manual = "", false),
            Case(editable = true, configured = false, followAndroid = false, manual = "   ", false),
            Case(
                editable = true,
                configured = false,
                followAndroid = false,
                manual = "https://resolver.example/dns-query",
                expected = true,
            ),
            Case(editable = true, configured = false, followAndroid = true, manual = "", true),
            Case(editable = true, configured = true, followAndroid = false, manual = "", true),
            Case(editable = false, configured = true, followAndroid = true, manual = "", false),
        )

    for (case in cases) {
      assertEquals(case.toString(), case.expected, invokePolicy(case))
    }
  }

  private fun invokePolicy(case: Case): Boolean {
    return try {
      val method =
          Class.forName("com.tailscale.ipn.ui.view.LocalDNSSourcePolicyKt")
              .getDeclaredMethod(
                  "isLocalDNSToggleEnabled",
                  Boolean::class.javaPrimitiveType,
                  Boolean::class.javaPrimitiveType,
                  Boolean::class.javaPrimitiveType,
                  String::class.java,
              )
      method.invoke(
          null,
          case.editable,
          case.configured,
          case.followAndroid,
          case.manual,
      ) as Boolean
    } catch (error: ReflectiveOperationException) {
      fail("source-first local DNS policy is missing: $error")
      false
    }
  }

  private data class Case(
      val editable: Boolean,
      val configured: Boolean,
      val followAndroid: Boolean,
      val manual: String,
      val expected: Boolean,
  )
}

fun main() {
  DNSSettingsViewPolicyTest().localEnableRequiresSelectedSourceButConfiguredStateCanBeDisabled()
}
