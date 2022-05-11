# Deployment or Orchestration

>Please note that this is only a proof of concept, and in no way anything you should run directly in production tenants.
>I am using this as a means to understand the ALZ-bicep module, and will most likely stop working on this now that the ALZ-Bicep team is making orchestration from v0.7.1.

## Clone

Clone the repository: `git clone https://github.com/torivara/bicep-alz-playground.git`
Or fork it if that is your preference.

## Add submodule

Added the Bicep ALZ as a submodule in this repo to have the possibility of fetching new repo versions. Submodule added at a specific commit, and must be manually pulled for new versions.
Not sure this needs to be added after cloning, but if there is something wrong, it might be missing.

```bash
cd `your repo root`
git add submodule 'https://github.com/Azure/ALZ-Bicep.git' alz-source
```

## Prerequisites

Please see the [deployment flow prerequisites](https://github.com/Azure/ALZ-Bicep/wiki/DeploymentFlow#prerequisites) in Bicep-ALZ for requirements in that department.

### Create SPN

>This is on no way production ready. SPN with owner role on root management group is a major security risk.

```pwsh
az ad sp create-for-rbac --name bicep-spn-owner `
  --role 'Owner' `
  --scope '/'
  --sdk
```

>Be advised that the json output from this command will not directly translate to the AZURE_CREDENTIALS json.
>The Azure Login action apparently needs specific names for the values, and default is not correct.
>The "--sdk" switch will help, but soon deprecated.

## Add github secrets

Secret name: AZURE_CREDENTIALS

Value:

```json
{
  "clientId": "`app registration id`",
  "displayName": "`app registration display name`",
  "name": "`app registration client name`",
  "clientSecret": "`your client secret`",
  "tenantId": "`your tenant id`"
}
```

Secret name: AZURE_PLATFORM_SUBSCRIPTION_ID
Value: `your platform subscription id` # Should be in the format of xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

## Add groups for SecOps and NetOps

```pwsh
az ad group create --display-name 'netops' `
  --mail-nickname 'netops' `
  --description 'Network Operations Personnel'

az ad group create --display-name 'secops' `
  --mail-nickname 'secops' `
  --description 'Security Operations Personnel'
```

## Workflow

You need to update environment variables in the workflows before running these the first time.

### Level 1

[Workflow file](\.github\workflows\process-level-1.yml)

```yaml
env:
  Location: 'westeurope'
  ManagementGroupPrefix: 'alz'
  TopLevelManagementGroupDisplayName: 'Azure Landing Zones'
```

### Level 2

[Workflow file](\.github\workflows\process-level-2.yml)

```yaml
env:
  Location: 'westeurope'
  ManagementGroupPrefix: 'alz'
  LoggingResourceGroupName: 'alz-hub-we-logging-rg'
  NetworkingResourceGroupName: 'alz-hub-we-networking-rg'
  TopLevelManagementGroupDisplayName: 'Azure Landing Zones'
  DeployAlzDefaultPolicies: 'true'
  LogAnalyticsWorkspaceName: 'alz-hub-we-logging-ws'
  AutomationAccountName: 'alz-hub-we-automation-aa'
  DeallocateFirewall: 'true'
```

### Level 3

[Workflow file](\.github\workflows\process-level-3.yml)

```yaml
env:
  Location: 'westeurope'
  ManagementGroupPrefix: 'alz'
  LoggingResourceGroupName: 'alz-logging-rg'
  NetworkingResourceGroupName: 'alz-networking-rg'
  HubNetworkName: 'alz-hub-WE-vnet'
  TopLevelManagementGroupDisplayName: 'Azure Landing Zones'
  PlatformSubscriptionId: ${{ secrets.AZURE_PLATFORM_SUBSCRIPTION_ID }}
```
