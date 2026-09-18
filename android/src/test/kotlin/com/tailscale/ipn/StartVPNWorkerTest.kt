// Copyright (c) Tailscale Inc & AUTHORS
// SPDX-License-Identifier: BSD-3-Clause

package com.tailscale.ipn

import com.tailscale.ipn.ui.model.Ipn
import kotlin.test.assertFalse
import kotlin.test.assertTrue
import kotlinx.coroutines.async
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.test.runCurrent
import kotlinx.coroutines.test.runTest
import org.junit.Test

class StartVPNWorkerTest {
  @Test
  fun readinessWaitsForInitialBackendState() = runTest {
    val state = MutableStateFlow(Ipn.State.NoState)
    val readiness = async { awaitVPNStartReadiness(state) }

    runCurrent()
    assertFalse(readiness.isCompleted)

    state.value = Ipn.State.Stopped
    assertTrue(readiness.await())
  }

  @Test
  fun readinessRejectsLoggedOutState() = runTest {
    val state = MutableStateFlow(Ipn.State.NoState)
    val readiness = async { awaitVPNStartReadiness(state) }

    state.value = Ipn.State.NeedsLogin
    assertFalse(readiness.await())
  }

  @Test
  fun readinessWaitsForStoppingToFinish() = runTest {
    val state = MutableStateFlow(Ipn.State.Stopping)
    val readiness = async { awaitVPNStartReadiness(state) }

    runCurrent()
    assertFalse(readiness.isCompleted)

    state.value = Ipn.State.Stopped
    assertTrue(readiness.await())
  }
}
