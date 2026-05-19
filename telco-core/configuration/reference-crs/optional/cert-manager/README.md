# Cert-Manager Configuration

This directory contains optional configurations for using cert-manager to manage TLS certificates in OpenShift.

## Overview

Cert-manager automates the management and issuance of TLS certificates from various issuing sources. This configuration demonstrates how to:
- Install the cert-manager operator
- Configure an ACME issuer using DNS-01 challenge
- Generate and use custom certificates for API Server and Ingress endpoints

## Files

### Operator Installation
- `certManagerNS.yaml` - Creates the cert-manager-operator namespace
- `certManagerOperatorgroup.yaml` - Creates the OperatorGroup for cert-manager
- `certManagerSubscription.yaml` - Installs the OpenShift cert-manager operator

### Certificate Issuers

Three ClusterIssuer types are available. Choose one based on your environment:

- `certManagerClusterIssuer.yaml` - **ACME issuer** using Let's Encrypt with DNS-01 challenge (requires internet connectivity)
- `certManagerClusterIssuerSelfSigned.yaml` - **Self-signed issuer** for disconnected or air-gapped environments
- `certManagerClusterIssuerCA.yaml` - **CA issuer** using an internal certificate authority (disconnected environments with existing PKI)
- `certManagerRootCACertificate.yaml` - Bootstraps a self-signed root CA for use with the CA issuer

### Certificate Resources
- `apiServerCertificate.yaml` - Creates a certificate for the API Server endpoint
- `ingressCertificate.yaml` - Creates a wildcard certificate for the Ingress/Router

### OpenShift Configuration
- `apiServerConfig.yaml` - Configures OpenShift to use the cert-manager generated API Server certificate
- `ingressControllerConfig.yaml` - Configures OpenShift to use the cert-manager generated Ingress certificate

## Customization Required

Before applying these configurations, you must customize the following:

1. **ClusterIssuer** — choose one of the following issuer configurations:

   **Option A: ACME issuer** (`certManagerClusterIssuer.yaml`) — for connected environments:
   - Update `email` with your contact email
   - Configure the appropriate DNS provider for DNS-01 challenge (example shows Route53)
   - Add necessary credentials for your DNS provider

   **Option B: Self-signed CA** (disconnected environments) — deploy these three files in order:
   1. `certManagerClusterIssuerSelfSigned.yaml` — creates the self-signed bootstrap issuer
   2. `certManagerRootCACertificate.yaml` — creates a root CA certificate (10-year duration)
   3. `certManagerClusterIssuerCA.yaml` — creates the CA issuer using the root CA
   - Update the Certificate `apiServerCertificate.yaml` and `ingressCertificate.yaml` to reference `ca-issuer` instead of `acme-issuer` in the `issuerRef` field

   **Option C: Existing internal CA** (disconnected environments with existing PKI):
   - Create a Secret named `root-ca-secret` in the `cert-manager` namespace containing your CA's `tls.crt` and `tls.key`
   - Deploy only `certManagerClusterIssuerCA.yaml`
   - Update the Certificate resources to reference `ca-issuer` in the `issuerRef` field

2. **Certificates** (`apiServerCertificate.yaml` and `ingressCertificate.yaml`):
   - Update `commonName` and `dnsNames` to match your cluster's domain
   - Example: Replace `api.example.com` with your actual API endpoint
   - Example: Replace `*.apps.example.com` with your actual wildcard domain

3. **APIServer Configuration** (`apiServerConfig.yaml`):
   - Update the `names` field to match your API Server FQDN

## Deployment Order

1. Deploy operator installation files (NS, OperatorGroup, Subscription)
2. Wait for operator to be ready
3. Deploy the ClusterIssuer
4. Deploy the Certificate resources
5. Wait for certificates to be issued and secrets created
6. **(Option B & C only)** Update kubeconfig to trust the new root CA (see "Kubeconfig Trust" section below)
7. Apply the APIServer and IngressController configurations

## Certificate Verification

After applying these configurations, verify that:
- Certificates are issued: `oc get certificate -A`
- Secrets are created: `oc get secret api-server-cert -n openshift-config` and `oc get secret ingress-wildcard-cert -n openshift-ingress`
- API Server is using the certificate: Test HTTPS connection to API endpoint
- Ingress is using the certificate: Test HTTPS connection to any route

## Important: Kubeconfig Trust After API Server Cert Replacement

> **Note:** For Option B (Self-signed CA) and Option C (Existing internal CA), you must complete
> this kubeconfig update *before* applying the APIServer configuration (step 7 in the deployment
> order above). Applying the APIServer configuration first will lock you out.

> **Warning:** When cert-manager replaces the API server certificate with one signed by a custom CA
> (self-signed or internal), existing kubeconfig files become invalid. The embedded
> `certificate-authority-data` still references the original cluster CA and cannot verify the new
> certificate. All `oc` and API client commands will fail with `x509: certificate signed by unknown authority`.

### Updating kubeconfig

1. Extract the new root CA certificate:
   ```bash
   oc get secret root-ca-secret -n cert-manager -o jsonpath='{.data.ca\.crt}' | base64 -d > /tmp/root-ca.crt
   ```

2. Update your kubeconfig to trust the new CA:
   ```bash
   oc config set-cluster $(oc config current-context | cut -d/ -f2) \
     --certificate-authority=/tmp/root-ca.crt --embed-certs
   ```

3. Verify connectivity:
   ```bash
   oc cluster-info
   ```

### Best practice for PKI environments

Generate a root CA once and use it as the root for your PKI (the ACME issuer or CA issuer your clusters will use). Add the root CA PEM to `/etc/pki/ca-trust/source/anchors/` on your workstation and run `update-ca-trust`. All certificates issued from that root CA will then be trusted without per-cluster kubeconfig updates.

## References

- [OpenShift Cert-Manager Operator Documentation](https://docs.openshift.com/container-platform/latest/security/cert_manager_operator/index.html)
- [Cert-Manager Documentation](https://cert-manager.io/docs/)
- [ACME DNS-01 Challenge Configuration](https://cert-manager.io/docs/configuration/acme/dns01/)

