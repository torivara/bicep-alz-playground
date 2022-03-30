targetScope = 'tenant'

// **Parameters**
// Generic Parameters - Used in multiple modules
@description('The region to deploy all resources into. DEFAULTS TO = westeurope')
param parLocation string = 'westeurope'

@description('An array of objects containing the Subscription IDs & CIDR VNET Address Spaces for Subscriptions to be placed into the Corp Management Group and peered back to the Hub Virtual Network (must already exists)')
@maxLength(36)
param parCorpSubscriptionIds array = []

@description('The Subscription IDs for Subscriptions to be placed into the Online Management Group (must already exists)')
@maxLength(36)
param parOnlineSubscriptionIds array = []

@description('Name of Resource Group to be created to contain hub networking resources like the virtual network and ddos standard plan.  Default: {parTopLevelManagementGroupPrefix}-{parLocation}-hub-networking')
param parResourceGroupNameForHubNetworking string = '${parTopLevelManagementGroupPrefix}-${parLocation}-hub-networking'

@description('Name of Resource Group to be created to contain spoke networking resources like the virtual network.  Default: {parTopLevelManagementGroupPrefix}-{parLocation}-spoke-networking')
param parResourceGroupNameForSpokeNetworking string = '${parTopLevelManagementGroupPrefix}-${parLocation}-spoke-networking'

// Management Group Module Parameters
@description('Prefix for the management group hierarchy. Must already exist!')
@minLength(2)
@maxLength(10)
param parTopLevelManagementGroupPrefix string = 'alz'

@description('Switch which allows Azure Firewall deployment to be disabled. Default: true')
param parAzureFirewallEnabled bool = true

@description('Tags you would like to be applied to all resources in this module. Default: empty array')
param parTags object = {}

@description('Array of DNS Server IP addresses for VNet. Default: Empty Array')
param parDNSServerIPArray array = []

@description('Name of Route table to create for the default route of Hub. Default: rtb-spoke-to-hub')
param parSpoketoHubRouteTableName string = 'rtb-spoke-to-hub'

@description('Set Parameter to true to Opt-out of deployment telemetry')
param parTelemetryOptOut bool = true

param parDDoSPlanResourceID string = ''

param parAzureFirewallPrivateIP string = ''

param parHubVirtualNetworkID string = ''

@description('You can deploy all management subscriptions in one (connectivity,management,identity)')
@maxLength(36)
param parPlatformSubscriptionId string = ''

@description('The Subscription ID for the Connectivity Subscription (must already exists)')
@maxLength(36)
param parConnectivitySubscriptionId string = ''

@description('The Subscription ID for the Management Subscription (must already exists)')
@maxLength(36)
param parManagementSubscriptionId string = ''

@description('The Subscription ID for the Identity Subscription (must already exists)')
@maxLength(36)
param parIdentitySubscriptionId string = ''

param parPlatformManagementMGName string = '${parTopLevelManagementGroupPrefix}-platform-management'
param parPlatformMGName string = '${parTopLevelManagementGroupPrefix}-platform'
param parPlatformConnectivityMGName string = '${parTopLevelManagementGroupPrefix}-platform-connectivity'
param parPlatformIdentityMGName string = '${parTopLevelManagementGroupPrefix}-platform-identity'
param parLandingZonesCorpMGName string = '${parTopLevelManagementGroupPrefix}-landingzones-corp'
param parLandingZonesOnlineMGName string = '${parTopLevelManagementGroupPrefix}-landingzones-online'

// Managment Groups Varaibles - Used For Policy Assignments
var varManagementGroupIDs = {
  intRoot: parTopLevelManagementGroupPrefix
  platform: '${parTopLevelManagementGroupPrefix}-platform'
  platformManagement: '${parTopLevelManagementGroupPrefix}-platform-management'
  platformConnectivity: '${parTopLevelManagementGroupPrefix}-platform-connectivity'
  platformIdentity: '${parTopLevelManagementGroupPrefix}-platform-identity'
  landingZones: '${parTopLevelManagementGroupPrefix}-landingzones'
  landingZonesCorp: '${parTopLevelManagementGroupPrefix}-landingzones-corp'
  landingZonesOnline: '${parTopLevelManagementGroupPrefix}-landingzones-online'
  decommissioned: '${parTopLevelManagementGroupPrefix}-decommissioned'
  sandbox: '${parTopLevelManagementGroupPrefix}-sandbox'
}

// Resource - Resource Group - For Spoke Networking - https://github.com/Azure/bicep/issues/5151
module modResourceGroupForSpokeNetworking '../../alz-source/infra-as-code/bicep/modules/resourceGroup/resourceGroup.bicep' = [for (corpSub, i) in parCorpSubscriptionIds: if (!empty(parCorpSubscriptionIds)) {
  scope: subscription(corpSub.subscriptionId)
  name: 'corpspoke-${i}'
  params: {
    parLocation: parLocation
    parResourceGroupName: parResourceGroupNameForSpokeNetworking
    parTelemetryOptOut: parTelemetryOptOut
  }
}]

// Module - Corp Spoke Virtual Networks
module modSpokeNetworking '../../alz-source/infra-as-code/bicep/modules/spokeNetworking/spokeNetworking.bicep' = [for (corpSub, i) in parCorpSubscriptionIds: if (!empty(parCorpSubscriptionIds)) {
  scope: resourceGroup(corpSub.subscriptionId, parResourceGroupNameForSpokeNetworking)
  name: 'corpspokenetworking-${i}'
  params: {
    parLocation: parLocation
    parSpokeNetworkName: corpSub.vnetName
    parSpokeNetworkAddressPrefix: corpSub.vnetCIDR
    parDdosProtectionPlanId: parDDoSPlanResourceID
    parDNSServerIPArray: parDNSServerIPArray
    parNextHopIPAddress: parAzureFirewallEnabled ? parAzureFirewallPrivateIP : ''
    parSpoketoHubRouteTableName: parSpoketoHubRouteTableName
    parTags: parTags
    parTelemetryOptOut: parTelemetryOptOut
  }
}]

// Module - Corp Spoke Virtual Network Peering - Spoke To Hub
module modSpokePeeringToHub '../virtualNetworkPeer/virtualNetworkPeer.bicep' = [for (corpSub, i) in parCorpSubscriptionIds: if (!empty(parCorpSubscriptionIds)) {
  scope: resourceGroup(corpSub.subscriptionId, parResourceGroupNameForSpokeNetworking)
  name: 'corpspokepeertohub-${i}'
  params: {
    parLocation: parLocation
    parDestinationVirtualNetworkID: parHubVirtualNetworkID
    parDestinationVirtualNetworkName: last(split(parHubVirtualNetworkID, '/'))
    parSourceVirtualNetworkName: corpSub.vnetName
    parAllowForwardedTraffic: true
    parAllowGatewayTransit: true
    parAllowVirtualNetworkAccess: true
    parTelemetryOptOut: parTelemetryOptOut
  }
}]

// Module - Corp Spoke Virtual Network Peering - Hub To Spoke
module modSpokePeeringFromHub '../virtualNetworkPeer/virtualNetworkPeer.bicep' = [for (corpSub, i) in parCorpSubscriptionIds: if (!empty(parCorpSubscriptionIds)) {
  scope: parPlatformSubscriptionId != '' ? resourceGroup(parPlatformSubscriptionId, parResourceGroupNameForHubNetworking) : resourceGroup(parConnectivitySubscriptionId, parResourceGroupNameForHubNetworking)
  name: 'corpspokepeerfromhub-${i}'
  params: {
    parLocation: parLocation
    parDestinationVirtualNetworkID: '/subscriptions/${corpSub.subscriptionId}/resourceGroups/${parResourceGroupNameForSpokeNetworking}/providers/Microsoft.Network/virtualNetworks/${corpSub.vnetName}'
    parDestinationVirtualNetworkName: corpSub.vnetName
    parSourceVirtualNetworkName: last(split(parHubVirtualNetworkID, '/'))
    parAllowForwardedTraffic: true
    parAllowGatewayTransit: true
    parAllowVirtualNetworkAccess: true
    parTelemetryOptOut: parTelemetryOptOut
  }
}]

// Subscription Placements Into Management Group Hierarchy
// Module - Subscription Placement - Management
module modSubscriptionPlacementPlatform '../../alz-source/infra-as-code/bicep/modules/subscriptionPlacement/subscriptionPlacement.bicep' = if(parPlatformSubscriptionId != '') {
  scope: managementGroup(varManagementGroupIDs.platform)
  name: 'sub-placement-platform'
  params: {
    parTargetManagementGroupId: parPlatformMGName
    parSubscriptionIds: [
      parPlatformSubscriptionId
    ]
    parTelemetryOptOut: parTelemetryOptOut
  }
}

module modSubscriptionPlacementManagement '../../alz-source/infra-as-code/bicep/modules/subscriptionPlacement/subscriptionPlacement.bicep' = if(parPlatformSubscriptionId == '') {
  scope: managementGroup(varManagementGroupIDs.platformManagement)
  name: 'sub-placement-management'
  params: {
    parTargetManagementGroupId: parPlatformManagementMGName
    parSubscriptionIds: [
      parManagementSubscriptionId
    ]
    parTelemetryOptOut: parTelemetryOptOut
  }
}

// Module - Subscription Placement - Connectivity
module modSubscriptionPlacementConnectivity '../../alz-source/infra-as-code/bicep/modules/subscriptionPlacement/subscriptionPlacement.bicep' = if(parPlatformSubscriptionId == '') {
  scope: managementGroup(varManagementGroupIDs.platformConnectivity)
  name: 'sub-placement-connectivity'
  params: {
    parTargetManagementGroupId: parPlatformConnectivityMGName
    parSubscriptionIds: [
      parConnectivitySubscriptionId
    ]
    parTelemetryOptOut: parTelemetryOptOut
  }
}

// Module - Subscription Placement - Identity
module modSubscriptionPlacementIdentity '../../alz-source/infra-as-code/bicep/modules/subscriptionPlacement/subscriptionPlacement.bicep' = if(parPlatformSubscriptionId == '') {
  scope: managementGroup(varManagementGroupIDs.platformIdentity)
  name: 'sub-placement-identity'
  params: {
    parTargetManagementGroupId: parPlatformIdentityMGName
    parSubscriptionIds: [
      parIdentitySubscriptionId
    ]
    parTelemetryOptOut: parTelemetryOptOut
  }
}

// Module - Subscription Placement - Corp
module modSubscriptionPlacementCorp '../../alz-source/infra-as-code/bicep/modules/subscriptionPlacement/subscriptionPlacement.bicep' = [for (corpSub, i) in parCorpSubscriptionIds: if (!empty(parCorpSubscriptionIds)) {
  scope: managementGroup(varManagementGroupIDs.landingZonesCorp)
  name: 'sub-placement-lz-corp-${i}'
  params: {
    parTargetManagementGroupId: parLandingZonesCorpMGName
    parSubscriptionIds: [
      corpSub.subscriptionId
    ]
    parTelemetryOptOut: parTelemetryOptOut
  }
}]

// Module - Subscription Placement - Online
module modSubscriptionPlacementOnline '../../alz-source/infra-as-code/bicep/modules/subscriptionPlacement/subscriptionPlacement.bicep' = [for (onlineSub, i) in parOnlineSubscriptionIds: if (!empty(parOnlineSubscriptionIds)) {
  scope: managementGroup(varManagementGroupIDs.landingZonesOnline)
  name: 'sub-placement-lz-online-${i}'
  params: {
    parTargetManagementGroupId: parLandingZonesOnlineMGName
    parSubscriptionIds: [
      onlineSub.subscriptionId
    ]
    parTelemetryOptOut: parTelemetryOptOut
  }
}]

// Module - Online Spoke Virtual Network Resource Group
module modOnlineResourceGroupForSpokeNetworking '../../alz-source/infra-as-code/bicep/modules/resourceGroup/resourceGroup.bicep' = [for (onlineSub, i) in parOnlineSubscriptionIds: if (!empty(parOnlineSubscriptionIds)) {
  scope: subscription(onlineSub.subscriptionId)
  name: 'onlinespoke-rgfornetworking-${i}'
  params: {
    parLocation: parLocation
    parResourceGroupName: parResourceGroupNameForSpokeNetworking
    parTelemetryOptOut: parTelemetryOptOut
  }
}]

// Module - Online Spoke Virtual Networks
module modOnlineSpokeNetworking '../../alz-source/infra-as-code/bicep/modules/spokeNetworking/spokeNetworking.bicep' = [for (onlineSub, i) in parOnlineSubscriptionIds: if (!empty(parOnlineSubscriptionIds)) {
  scope: resourceGroup(onlineSub.subscriptionId, parResourceGroupNameForSpokeNetworking)
  name: 'onlinespokenetworking-${i}'
  params: {
    parLocation: parLocation
    parSpokeNetworkName: onlineSub.vnetName
    parSpokeNetworkAddressPrefix: onlineSub.addressPrefix
    parDdosProtectionPlanId: parDDoSPlanResourceID
    parDNSServerIPArray: parDNSServerIPArray
    parNextHopIPAddress: ''
    parTags: parTags
    parTelemetryOptOut: parTelemetryOptOut
  }
  dependsOn: [
    modOnlineResourceGroupForSpokeNetworking[i]
  ]
}]
