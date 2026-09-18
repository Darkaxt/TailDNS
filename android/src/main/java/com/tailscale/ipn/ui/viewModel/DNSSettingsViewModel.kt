// Copyright (c) Tailscale Inc & AUTHORS
// SPDX-License-Identifier: BSD-3-Clause

package com.tailscale.ipn.ui.viewModel

import android.provider.Settings
import androidx.annotation.StringRes
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.tailscale.ipn.App
import com.tailscale.ipn.R
import com.tailscale.ipn.mdm.MDMSettings
import com.tailscale.ipn.ui.localapi.Client
import com.tailscale.ipn.ui.model.Ipn
import com.tailscale.ipn.ui.model.LocalDNSStatus
import com.tailscale.ipn.ui.model.LocalDNSUpdate
import com.tailscale.ipn.ui.model.Tailcfg
import com.tailscale.ipn.ui.notifier.Notifier
import com.tailscale.ipn.ui.theme.off
import com.tailscale.ipn.ui.theme.success
import com.tailscale.ipn.ui.util.set
import com.tailscale.ipn.util.TSLog
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class DNSSettingsViewModelFactory : ViewModelProvider.Factory {
  @Suppress("UNCHECKED_CAST")
  override fun <T : ViewModel> create(modelClass: Class<T>): T {
    return DNSSettingsViewModel() as T
  }
}

class DNSSettingsViewModel : IpnViewModel() {
  val enablementState: StateFlow<DNSEnablementState> =
      MutableStateFlow(DNSEnablementState.NOT_RUNNING)
  val dnsConfig: StateFlow<Tailcfg.DNSConfig?> = MutableStateFlow(null)
  val localDNS = MutableStateFlow<LocalDNSStatus?>(null)
  val localDNSError = MutableStateFlow(false)
  val savingLocalDNS = MutableStateFlow(false)
  val strictPrivateDNS = MutableStateFlow<Boolean?>(null)
  private var localDNSGeneration = 0L

  init {
    viewModelScope.launch {
      combine(
              Notifier.state,
              Notifier.prefs,
              Notifier.netmap,
              loggedInUser,
              MDMSettings.useTailscaleDNSSettings.flow,
          ) { _, _, _, _, _ ->
            Unit
          }
          .collect { refreshLocalDNS() }
    }
    viewModelScope.launch {
      Notifier.netmap
          .combine(Notifier.prefs) { netmap, prefs -> Pair(netmap, prefs) }
          .stateIn(viewModelScope)
          .collect { (netmap, prefs) ->
            TSLog.d("DNSSettingsViewModel", "prefs: CorpDNS=" + prefs?.CorpDNS.toString())
            prefs?.let {
              if (it.CorpDNS) {
                enablementState.set(DNSEnablementState.ENABLED)
              } else {
                enablementState.set(DNSEnablementState.DISABLED)
              }
            } ?: run { enablementState.set(DNSEnablementState.NOT_RUNNING) }
            netmap?.let { dnsConfig.set(netmap.DNS) }
          }
    }
  }

  fun refreshLocalDNS() {
    strictPrivateDNS.value =
        runCatching {
          when (Settings.Global.getString(App.get().contentResolver, "private_dns_mode")) {
            "hostname" -> true
            "opportunistic",
            "off" -> false
            else -> null
          }
        }
            .getOrNull()
    val generation = ++localDNSGeneration
    Client(viewModelScope).localDNS { result ->
      if (generation != localDNSGeneration) return@localDNS
      localDNS.value = result.getOrNull()
      localDNSError.value = result.isFailure
    }
  }

  fun saveLocalDNS(profileID: String, enabled: Boolean, endpoint: String) {
    if (savingLocalDNS.value) return
    savingLocalDNS.value = true
    ++localDNSGeneration
    Client(viewModelScope).editLocalDNS(LocalDNSUpdate(profileID, enabled, endpoint)) { result ->
      savingLocalDNS.value = false
      localDNSError.value = result.isFailure
      // Re-read current state: a successful edit may have preceded a profile switch.
      if (result.isSuccess) refreshLocalDNS()
    }
  }

  fun toggleCorpDNS(callback: (Result<Ipn.Prefs>) -> Unit) {
    val prefs =
        Notifier.prefs.value
            ?: run {
              callback(Result.failure(Exception("no prefs")))
              return@toggleCorpDNS
            }

    val prefsOut = Ipn.MaskedPrefs()
    prefsOut.CorpDNS = !prefs.CorpDNS
    Client(viewModelScope).editPrefs(prefsOut, callback)
  }
}

enum class DNSEnablementState(
    @param:StringRes val title: Int,
    @param:StringRes val caption: Int,
    val symbolDrawable: Int,
    val tint: @Composable () -> Color,
) {
  NOT_RUNNING(
      R.string.not_running,
      R.string.tailscale_is_not_running_this_device_is_using_the_system_dns_resolver,
      R.drawable.xmark_circle,
      { MaterialTheme.colorScheme.off },
  ),
  ENABLED(
      R.string.using_tailscale_dns,
      R.string.this_device_is_using_tailscale_to_resolve_dns_names,
      R.drawable.check_circle,
      { MaterialTheme.colorScheme.success },
  ),
  DISABLED(
      R.string.not_using_tailscale_dns,
      R.string.this_device_is_using_the_system_dns_resolver,
      R.drawable.xmark_circle,
      { MaterialTheme.colorScheme.error },
  ),
}
