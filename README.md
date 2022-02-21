# Bicep Azure Landing Zones Playground

This will be my playground for playing around with [Bicep ALZ](https://github.com/Azure/ALZ-bicep).

## Workflows

Triggers on Pull Request:

Triggers on Push:

## Folder structure

- Repository root
  - .github - Workflows and all things required for them.
  - alz-bicep - The source modules and resources from MS.
  - platform - The parameter files deciding platform structure.
    - level-1 - The foundational management group structure, custom policy definitions and custom RBAC definitions
      - managementGroups
      - policyDefinitions
      - roleAssignments
    - level-2 - Logging/Security, Hub networking, rbac role assignments
      - logging
      - hubNetworking
      - roleAssignments
    - level-3 - Subscription placement, policy assignments and spoke networking
      - subscriptionPlacement
      - policyAssignments
      - spokeNetworking
    - level-4 - Resource deployments
      - hub
      - corpSpoke1

## Prerequisites

Please see the [deployment flow prerequisites](https://github.com/Azure/ALZ-Bicep/wiki/DeploymentFlow#prerequisites) in Bicep-ALZ for requirements in that department.

### Add submodule

Added the Bicep ALZ as a submodule in this repo to have the possibility of fetching new repo versions. Submodule added at a specific commit, and must be manually pulled for new versions.

```bash
cd `your repo root`
git add submodule 'https://github.com/Azure/ALZ-Bicep.git' alz-source
```

### Create SPN

TODO: Create least privilege SPN guide and test

```pwsh
az ad sp create-for-rbac --name bicep-spn-owner `
  --role 'Owner' `
  --scope '/'
```

>Be advised that the json output from this command will not directly translate to the AZURE_CREDENTIALS json.
>The Azure Login action apparently needs specific names for the values, and default is not correct.

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

Secret name: AZURE_HUB_SUBSCRIPTION_ID
Value: `your subscription id` # Should be in the format of xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
