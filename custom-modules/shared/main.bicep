param parTopLevelManagementGroupPrefix string = 'alz'
param parLocation string = 'westeurope'

var varResourceGroupAffix = 'rg'
var varAutomationAccountAffix = 'aa'
var varVirtualNetworkAffix = 'vn'
var varLocationLookupTable = {
  'westeurope': 'we'
  'West Europe': 'we'
  'northeurope': 'ne'
  'North Europe': 'ne'
  'norwayeast': 'noe'
  'Norway East': 'noe'
  'norwaywest': 'now'
  'Norway West': 'now'
}

var varResourceGroupNameForHubNetworking = contains(varLocationLookupTable, parLocation) ? '${parTopLevelManagementGroupPrefix}-hub-${varLocationLookupTable[parLocation]}-networking-${varResourceGroupAffix}' : ''
var varResourceGroupNameForSpokeNetworking = contains(varLocationLookupTable, parLocation) ? '${parTopLevelManagementGroupPrefix}-spoke-${varLocationLookupTable[parLocation]}-networking-${varResourceGroupAffix}' : ''
var varResourceGroupNameForLogging = contains(varLocationLookupTable, parLocation) ? '${parTopLevelManagementGroupPrefix}-hub-${varLocationLookupTable[parLocation]}-logging-${varResourceGroupAffix}' : ''

var varResourceNameForAutomationAccount = contains(varLocationLookupTable, parLocation) ? '${parTopLevelManagementGroupPrefix}-hub-${varLocationLookupTable[parLocation]}-automation-${varAutomationAccountAffix}' : ''
var varResourceNameForHubVirtualNetwork = contains(varLocationLookupTable, parLocation) ? '${parTopLevelManagementGroupPrefix}-hub-${varLocationLookupTable[parLocation]}-vnet-${varVirtualNetworkAffix}' : ''

output outResourceGroupNameForHubNetworking string = varResourceGroupNameForHubNetworking
output outResourceGroupNameForSpokeNetworking string = varResourceGroupNameForSpokeNetworking
output outResourceGroupNameForLogging string = varResourceGroupNameForLogging

output outResourceNameForHubVirtualNetwork string = varResourceNameForHubVirtualNetwork
output outResourceNameForAutomationAccount string = varResourceNameForAutomationAccount
