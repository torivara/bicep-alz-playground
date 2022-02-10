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
      - management-groups
      - policy-definitions
      - rbac-definitions
    - level-2 - Logging/Security, Hub networking, rbac role assignments
      - management
      - networking
      - rbac-assignments
    - level-3 - Subscription placement, policy assignments and spoke networking
      - subscriptions
      - policy-assignments
      - spokes

## Prerequisites

Please see the [deployment flow prerequisites](https://github.com/Azure/ALZ-Bicep/wiki/DeploymentFlow#prerequisites) in Bicep-ALZ for requirements in that department.

## Submodules

Added the Bicep ALZ as a submodule in this repo to always have the latest modules available.
