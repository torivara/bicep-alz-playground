# Bicep Azure Landing Zones Playground

This will be my playground for playing around with [Bicep ALZ](https://github.com/Azure/ALZ-bicep).

## Workflows

Triggers on Pull Request:

- process-level-1.yml
  - Triggers on changes to `platform/level-1/**.json` in a Pull Request
- process-level-2.yml
  - Triggers on changes to `platform/level-2/**.json` in a Pull Request
- process-level-3.yml
  - Triggers on changes to `platform/level-3/**.json` in a Pull Request

Pull Request triggered actions will run validation with ARM What-If, and add the output to the PR as a comment.

Exception is creation of resource groups, because they need to be there for validation to succeed.

Triggers on Push:

- process-level-1.yml
  - Triggers on changes to `platform/level-1/**.json` when pushed to main with merge or directly
- process-level-2.yml
  - Triggers on changes to `platform/level-2/**.json` when pushed to main with merge or directly
- process-level-3.yml
  - Triggers on changes to `platform/level-3/**.json` when pushed to main with merge or directly

Push triggered actions will run deployment of resources declared in bicep files. Subscriptions will also be moved to correct Management Group.

## Folder structure

- Repository root
  - .github - Workflows and all things required for them.
  - alz-source - The source modules and resources from MS.
  - platform - The parameter files deciding platform structure.
    - level-1 - The foundational management group structure, custom policy definitions and custom RBAC definitions
      - managementGroups
      - custom policy definitions
      - custom role definitions
    - level-2 - Logging/Security, Hub networking, policy assignments, and rbac role assignments
      - logging
      - hubNetworking
      - policyAssignments
      - roleAssignments
    - level-3 - Subscription placement, and spoke networking
      - spoke subscription placement
      - spoke networking
        - Online gets a vnet with no peering
        - Corp gets a vnet with peering to hub network
    - level-4 - Resource deployments
      - Resources to be deployed in hub
      - Resources to be deployed in online spoke
      - Resources to be deployed in corp spoke
  - custom-modules - Contains modules that needs to be updated manually from ALZ-Bicep or just additional modules that can be used.
    - desktopservices - experimental module for adding AVD to one of the spokes
    - hubNetworking - Needed a change for it to be deployable in this scenario
    - logging - Needed a change for it to be deployable in this scenario
    - virtualNetworkPeer - Needed a change for it to be deployable in this scenario
    - spokes - Custom module for creating spokes based on the main orchestration bicep from ALZ-Bicep
  - scripts - Miscellaneous scripts or script notes that may or may not be needed for deployment

### Add submodule

Added the Bicep ALZ as a submodule in this repo to have the possibility of fetching new repo versions. Submodule added at a specific commit, and must be manually pulled for new versions.

```bash
cd `your repo root`
git add submodule 'https://github.com/Azure/ALZ-Bicep.git' alz-source
```

## Features

- Deploys Management Group hierarchy as defined in [parameters](platform/level-1/managementGroups/managementGroups.parameters.json).
- Moves Management Groups if they are in the wrong place
- Deploys Custom Role Definitions in top level Management Group
  - caf-subscription-owner-role
  - caf-application-owner-role
  - caf-network-management-role
  - caf-security-operations-role
- Deploys Custom Azure Policy definitions in top level Management Group
- Deploys default Azure Landing Zones policy definitions, and assigns if this is chosen
- Deploys Hub networking as defined in parameters
  - Azure Firewall
  - Azure VPN
  - Azure Bastion
  - Azure Private Endpoint DNS
  - ++
- Deploys spoke networking
  - Spoke peering is deployed if landing zone is defined as corp
- Deploys logging resources
  - Azure Automation
  - Log Analytics workspace
  - ++
- Deploys custom Azure Policy assignments
- Deploys custom Role Assignments
- Moves subscriptions to declared Management Groups

## Notfeatures

Bicep is a create and update tool, and will not delete resources that are removed from code. This must be performed with other tools, such as AZ Cli or PowerShell.

- Delete Management Groups not in parameters
- Delete any resource not in parameters

## Planned features

- Deploy basic resources from level-4 to spokes
  - Azure Virtual Desktop
  - AKS
  - VMs
  - Web site hosting
  - Application Gateway?
  - ...

More features will be added when I find the time.
