// Copyright (c) Tailscale Inc & AUTHORS
// SPDX-License-Identifier: BSD-3-Clause

package com.tailscale.ipn.ui.view

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.Button
import androidx.compose.material3.Icon
import androidx.compose.material3.ListItem
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.compose.LocalLifecycleOwner
import androidx.lifecycle.viewmodel.compose.viewModel
import com.tailscale.ipn.R
import com.tailscale.ipn.mdm.MDMSettings
import com.tailscale.ipn.ui.model.DnsType
import com.tailscale.ipn.ui.notifier.Notifier
import com.tailscale.ipn.ui.util.ClipboardValueView
import com.tailscale.ipn.ui.util.Lists
import com.tailscale.ipn.ui.util.LoadingIndicator
import com.tailscale.ipn.ui.util.itemsWithDividers
import com.tailscale.ipn.ui.util.set
import com.tailscale.ipn.ui.viewModel.DNSEnablementState
import com.tailscale.ipn.ui.viewModel.DNSSettingsViewModel
import com.tailscale.ipn.ui.viewModel.DNSSettingsViewModelFactory

data class ViewableRoute(val name: String, val resolvers: List<DnsType.Resolver>)

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun DNSSettingsView(
    backToSettings: BackNavigation,
    model: DNSSettingsViewModel = viewModel(factory = DNSSettingsViewModelFactory()),
) {
  val state: DNSEnablementState by model.enablementState.collectAsState()
  val resolvers = model.dnsConfig.collectAsState().value?.Resolvers ?: emptyList()
  val domains = model.dnsConfig.collectAsState().value?.Domains ?: emptyList()
  val routes: List<ViewableRoute> =
      model.dnsConfig.collectAsState().value?.Routes?.mapNotNull { entry ->
        entry.value?.let { resolvers -> ViewableRoute(name = entry.key, resolvers) } ?: run { null }
      } ?: emptyList()
  val useCorpDNS = Notifier.prefs.collectAsState().value?.CorpDNS == true
  val dnsSettingsMDMDisposition by MDMSettings.useTailscaleDNSSettings.flow.collectAsState()
  val localDNS by model.localDNS.collectAsState()
  val localDNSError by model.localDNSError.collectAsState()
  val savingLocalDNS by model.savingLocalDNS.collectAsState()
  val strictPrivateDNS by model.strictPrivateDNS.collectAsState()
  val lifecycleOwner = LocalLifecycleOwner.current
  DisposableEffect(lifecycleOwner, model) {
    val observer = LifecycleEventObserver { _, event ->
      if (event == Lifecycle.Event.ON_RESUME) model.refreshLocalDNS()
    }
    lifecycleOwner.lifecycle.addObserver(observer)
    onDispose { lifecycleOwner.lifecycle.removeObserver(observer) }
  }

  Scaffold(topBar = { Header(R.string.dns_settings, onBack = backToSettings) }) { innerPadding ->
    LoadingIndicator.Wrap {
      LazyColumn(Modifier.padding(innerPadding)) {
        item("state") {
          ListItem(
              leadingContent = {
                Icon(
                    painter = painterResource(state.symbolDrawable),
                    contentDescription = null,
                    tint = state.tint(),
                    modifier = Modifier.size(36.dp),
                )
              },
              headlineContent = {
                Text(stringResource(state.title), style = MaterialTheme.typography.titleMedium)
              },
              supportingContent = { Text(stringResource(state.caption)) },
          )

          if (!dnsSettingsMDMDisposition.value.hiddenFromUser) {
            Lists.ItemDivider()
            Setting.Switch(
                R.string.use_ts_dns,
                isOn = useCorpDNS,
                onToggle = {
                  LoadingIndicator.start()
                  model.toggleCorpDNS { LoadingIndicator.stop() }
                },
            )
          }
        }

        item("localDNS") {
          Lists.SectionDivider(stringResource(R.string.local_dns_title))
          Column(Modifier.padding(16.dp)) {
            Text(stringResource(R.string.local_dns_scope))
            if (strictPrivateDNS != false) {
              Text(
                  stringResource(
                      if (strictPrivateDNS == true) R.string.local_dns_strict_conflict
                      else R.string.local_dns_mode_unknown
                  )
              )
            }
            localDNS?.let { saved ->
              var enabled by
                  remember(saved.ProfileID, saved.Configured) { mutableStateOf(saved.Configured) }
              var endpoint by
                  remember(saved.ProfileID, saved.Endpoint) { mutableStateOf(saved.Endpoint) }
              val editable =
                  !dnsSettingsMDMDisposition.value.hiddenFromUser &&
                      saved.ProfileID.isNotEmpty() &&
                      !savingLocalDNS
              Row {
                Text(stringResource(R.string.local_dns_enable), Modifier.weight(1f))
                Switch(checked = enabled, onCheckedChange = { enabled = it }, enabled = editable)
              }
              OutlinedTextField(
                  value = endpoint,
                  onValueChange = { endpoint = it },
                  label = { Text(stringResource(R.string.local_dns_endpoint)) },
                  singleLine = true,
                  enabled = editable,
                  modifier = Modifier.fillMaxWidth(),
              )
              Text(saved.Reason)
              Button(
                  enabled = editable,
                  onClick = { model.saveLocalDNS(saved.ProfileID, enabled, endpoint) },
              ) {
                Text(stringResource(R.string.local_dns_save))
              }
            }
            if (localDNSError)
                Text(
                    stringResource(R.string.local_dns_error),
                    color = MaterialTheme.colorScheme.error,
                )
          }
        }

        if (resolvers.isNotEmpty()) {
          item("resolversHeader") {
            Lists.SectionDivider(
                stringResource(
                    if (localDNS?.Configured == true) R.string.local_dns_tailnet_resolvers
                    else R.string.resolvers
                )
            )
          }

          itemsWithDividers(resolvers) { resolver -> ClipboardValueView(resolver.Addr.orEmpty()) }
        }

        if (domains.isNotEmpty()) {
          item("domainsHeader") { Lists.SectionDivider(stringResource(R.string.search_domains)) }

          itemsWithDividers(domains) { domain -> ClipboardValueView(domain) }
        }

        if (routes.isNotEmpty()) {
          routes.forEach { route ->
            item { Lists.SectionDivider("Route: ${route.name}") }

            itemsWithDividers(route.resolvers) { resolver ->
              ClipboardValueView(resolver.Addr.orEmpty())
            }
          }
        }
      }
    }
  }
}

@Preview
@Composable
fun DNSSettingsViewPreview() {
  val vm = DNSSettingsViewModel()
  vm.enablementState.set(DNSEnablementState.ENABLED)
  DNSSettingsView(backToSettings = {}, vm)
}
