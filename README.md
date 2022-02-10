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

## Submodules

Added the Bicep ALZ as a submodule in this repo to always have the latest modules available.
