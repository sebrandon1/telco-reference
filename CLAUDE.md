# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains reference configuration Custom Resources (CRs) for OpenShift telco deployments. It defines three deployment models:

- **telco-hub**: Hub cluster configuration for managing spoke clusters (ACM, GitOps, storage operators)
- **telco-core**: Core cluster reference configuration for telco workloads
- **telco-ran**: RAN (Radio Access Network) DU profile configuration for edge deployments

Content is branched per OpenShift y-stream release.

## Build and Validation Commands

### Full CI validation (runs all checks):
```bash
make ci-validate
```

### Check dependencies before running validation:
```bash
make check-deps
```

Required tools: `yamllint`, `kubectl-cluster_compare`, `helm-convert`, `mcmaker`, `go`

### Individual component checks:
```bash
make check-reference-core    # Validates telco-core configuration
make check-reference-ran     # Validates telco-ran configuration
make check-reference-hub     # Validates telco-hub configuration
make lintCheck               # YAML linting (excludes kube-compare templates)
```

### Per-component validation (run from respective directories):

**telco-core/configuration:**
```bash
make check          # Runs compare_crs and missing_crs checks
```

**telco-ran/configuration:**
```bash
make check          # Runs all RAN checks
make checkExtraManifests        # Validates extra-manifests-builder output
make checkSourceCRsAnnotation   # Ensures ztp-deploy-wave annotations present
```

**telco-ran/configuration/kube-compare-reference:**
```bash
make compare        # Compare reference templates against source-crs
make sync           # Sync changes from reference templates to source-crs
```

**telco-ran/configuration/extra-manifests-builder:**
```bash
make check          # Validate generated MachineConfigs match source-crs
make all            # Regenerate extra-manifests (requires mcmaker)
```

### Markdown linting:
```bash
make markdownlint   # Requires container runtime (podman/docker)
```

## Architecture

### Directory Structure Pattern

Each telco-* directory follows a similar structure:
- `configuration/reference-crs/` - Baseline configuration CRs (required/optional subdirs)
- `configuration/reference-crs-kube-compare/` - Templated versions for cluster-compare validation
- `install/` - Installation resources (ABI manifests, mirror registry setup)

### Dual Reference System

The repository maintains two synchronized versions of configuration CRs:
1. **reference-crs**: Plain YAML CRs ready for direct application
2. **reference-crs-kube-compare**: Same CRs with Go templating for use with the kube-compare tool

CI enforces synchronization between these directories. When modifying CRs, update both locations or use `make sync` in kube-compare-reference directories.

### Policy Generation (ACM)

Configuration uses PolicyGenerator CRs (e.g., `core-baseline.yaml`, `core-overlay.yaml`) that:
- Define how reference CRs are grouped into ACM policies
- Use hub-side templating with ConfigMaps from `template-values/`
- Are processed by GitOps/ArgoCD PolicyGenerator plugin

### Extra Manifests Builder (RAN)

`telco-ran/configuration/extra-manifests-builder/` contains scripts that generate MachineConfig CRs using the `mcmaker` tool. Each subdirectory has a `build.sh` that produces master/worker variants.

### ArgoCD Sync Waves (Hub)

Hub resources use sync-wave annotations for ordered deployment:
- -50: Registry/catalog foundation
- -45: Namespaces
- -40: RBAC, ConfigMaps, OperatorGroups, Subscriptions
- -35: ArgoCD resources
- -30: Core operators and storage
- -25: Policies and validation
- -10: Storage-dependent services
- 100: ZTP components

## Key Files

- `Makefile` - Root makefile with ci-validate target
- `.yamllint.yaml` - YAML lint configuration (allows 2000 char lines for base64/templates)
- `telco-*/configuration/Makefile` - Component-specific validation targets
- `telco-ran/configuration/source-crs/` - Source CRs requiring `ztp-deploy-wave` annotations

## Contributing Notes

- CRs in source-crs (except extra-manifest, machine-config, generic, ibu paths) must have `ran.openshift.io/ztp-deploy-wave` annotation
- File paths must not exceed 255 characters (ISO9660 limitation for ZTP)
- Keep reference-crs and reference-crs-kube-compare in sync
