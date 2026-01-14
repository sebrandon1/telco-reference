# OpenShift KNI Repositories Using Kustomize

Found **13 repositories** in the [openshift-kni organization](https://github.com/openshift-kni) that use kustomize.

## Repositories with Kustomization Files

### 1. cnf-features-deploy
- **URL**: https://github.com/openshift-kni/cnf-features-deploy
- **Description**: Kustomize configs for installing CNF features and e2e functional tests for verifying feature deployment/integration
- **Kustomize Files**: 157+ kustomization.yaml files
- **Status**: ✅ PR #3097 already created
- **Stars**: 63 | **Forks**: 145

### 2. telco-reference
- **URL**: https://github.com/openshift-kni/telco-reference
- **Description**: Telco reference architecture configurations
- **Kustomize Files**: 23 kustomization.yaml files
- **Status**: ✅ PR #433 already created
- **Stars**: 16 | **Forks**: 47

### 3. numaresources-operator
- **URL**: https://github.com/openshift-kni/numaresources-operator
- **Description**: Operator to enable reporting of per-NUMA-zone compute resources
- **Kustomize Files**: Multiple in config/ directory
- **Stars**: 11 | **Forks**: 20

### 4. oran-o2ims
- **URL**: https://github.com/openshift-kni/oran-o2ims
- **Description**: O-RAN O2 IMS implementation
- **Kustomize Files**: Multiple kustomization files
- **Stars**: 11 | **Forks**: 34

### 5. lifecycle-agent
- **URL**: https://github.com/openshift-kni/lifecycle-agent
- **Description**: Local agent for orchestration of SNO Image Based Upgrade
- **Kustomize Files**: Multiple in config/ directory
- **Stars**: 6 | **Forks**: 39

### 6. cluster-group-upgrades-operator
- **URL**: https://github.com/openshift-kni/cluster-group-upgrades-operator
- **Description**: Operator for managing cluster group upgrades
- **Kustomize Files**: Multiple in config/ directory
- **Stars**: 15 | **Forks**: 37

### 7. performance-addon-operators
- **URL**: https://github.com/openshift-kni/performance-addon-operators
- **Description**: Operators related to optimizing OpenShift clusters for applications sensitive to cpu and network latency
- **Kustomize Files**: Multiple kustomization files
- **Stars**: 46 | **Forks**: 61

### 8. eapol-operator
- **URL**: https://github.com/openshift-kni/eapol-operator
- **Description**: An 802.1x authentication operator for Kubernetes
- **Kustomize Files**: Multiple in config/ directory
- **Stars**: N/A

### 9. mixed-cpu-node-plugin
- **URL**: https://github.com/openshift-kni/mixed-cpu-node-plugin
- **Description**: Extends cpu resources management on top of Kubernetes and OpenShift platforms
- **Kustomize Files**: Deployment kustomization files
- **Stars**: N/A

### 10. example-cnf
- **URL**: https://github.com/openshift-kni/example-cnf
- **Description**: Example CNF deployments
- **Kustomize Files**: Multiple for testpmd-operator and trex-operator
- **Stars**: N/A

### 11. oran-hwmgr-plugin
- **URL**: https://github.com/openshift-kni/oran-hwmgr-plugin
- **Description**: O-Cloud Hardware Manager Plugin
- **Kustomize Files**: Multiple in config/ directory
- **Stars**: N/A

### 12. kkube
- **URL**: https://github.com/openshift-kni/kkube
- **Description**: kcli kubernetes operator
- **Kustomize Files**: Multiple in config/ directory
- **Stars**: N/A

### 13. eco-validation (Private)
- **URL**: https://github.com/openshift-kni/eco-validation
- **Description**: ZTP validation and automation
- **Kustomize Files**: Templates for kustomization
- **Status**: ⚠️ Private repository

---

## Quick Clone Commands

### Clone All Public Repos (excluding already done)
```bash
# Repos needing kustomize validation
git clone https://github.com/openshift-kni/numaresources-operator.git
git clone https://github.com/openshift-kni/oran-o2ims.git
git clone https://github.com/openshift-kni/lifecycle-agent.git
git clone https://github.com/openshift-kni/cluster-group-upgrades-operator.git
git clone https://github.com/openshift-kni/performance-addon-operators.git
git clone https://github.com/openshift-kni/eapol-operator.git
git clone https://github.com/openshift-kni/mixed-cpu-node-plugin.git
git clone https://github.com/openshift-kni/example-cnf.git
git clone https://github.com/openshift-kni/oran-hwmgr-plugin.git
git clone https://github.com/openshift-kni/kkube.git
```

### Already Have PRs
```bash
# These already have kustomize validation PRs
git clone https://github.com/openshift-kni/cnf-features-deploy.git  # PR #3097
git clone https://github.com/openshift-kni/telco-reference.git      # PR #433
```

---

## Potential Impact

Adding kustomize validation to these 11 remaining repos could validate **hundreds more** kustomization.yaml files across the openshift-kni organization, catching configuration errors early in PR reviews.

**Generated**: October 30, 2025

