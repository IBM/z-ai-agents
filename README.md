# z-ai-agents - Deployment Guide

Install and operate the [IBM watsonx Assistant for Z – Agent Suite](/wxa4z-agent-suite/) Helm chart on OpenShift. Deploy multiple z/OS agents with one command, using shared configuration and per‑agent overrides.

> This [wxa4z-agent-suite](/wxa4z-agent-suite/) chart deploys a **suite of z/OS agents** with one command. Each agent remains an independent chart (own values, templates, and versioning) while the umbrella coordinates:
>
> - **Single‑command install/upgrade** for all enabled agents
> - **Shared, reusable config & secrets** (optional, via `global.*`)
> - **Per‑environment toggles** (`values-*.yaml`) to enable/disable agents

---

## Table of Contents

1. [Overview](#overview)
2. [Repo Layout](#architecture--repo-layout)
3. [Compatibility & Requirements](#compatibility--requirements)
4. [Preflight Checklist](#preflight-checklist)
5. [Quickstart](#quick-start)
   - [Global settings](#1-global-settings)
   - [Per Agent Configuration](#2-per-agent-configuration)
   - [Install / Upgrade / Uninstall](#3-install--upgrade--uninstall)
6. [Post‑Install Verification](#post-install-verification)
7. [Troubleshooting](#troubleshooting)
8. [FAQ](#faq)
---

## Overview
The **[wxa4z-agent-suite](/wxa4z-agent-suite/)** Helm chart orchestrates the deployment of multiple IBM z/OS‑focused agents. It’s designed for enterprises running on OpenShift who want:

- A **consistent install** story across environments (dev/test/prod)
- **Federated configuration** (shared global values + agent‑specific overrides)
- **Secure secret handling** (no hard‑coding; Kubernetes Secrets only)
- **Idempotent upgrades** (Helm‑native lifecycle)

> **Tip:** Enable/disable individual agents per environment by editing your `values.yaml` (or a `values-<env>.yaml`).

---

## Repo Layout
```
wxa4z-agent-suite/ # <— umbrella chart
├─ Chart.yaml # lists all agent dependencies
├─ values.yaml # toggles & optional shared config/secrets
├─ templates/ # (usually minimal; e.g., optional global secrets)
└─ charts/ # populated by helm dependency update
```
---

## Supported Agents

### IBM watsonx Assistant for Z Foundational Agents

| Name                       | Chart name               | Category      |   Reference   |
| -------------------------- | ------------------------ | ------------- | ------------- |
| IBM Z OMEGAMON Insights Agent | `omegamon-insights-agent` | Foundational | [README](./agent-helm-charts/system-insight-agent-z/README.md)                  |
| IBM Z Upgrade Agent    | `upgrade-agent`          | Foundational |  [README](./agent-helm-charts/upgrade-agent/README.md)                  |
| IBM Z Automation Insights Agent | `automation-insights-agent` | Foundational |[README](/agent-helm-charts/system-automation-netview-agent/README.md)|
| IBM Z Workload Scheduler Insights Agent | `workload-scheduler-agent-z` | Foundational |[README](/agent-helm-charts/workload-scheduler-agent-z/README.md)|
| IBM Z Support Agent              | `support-agent`          | Foundational | [README](./agent-helm-charts/support-agent/README.md)                   |


---

## ⚠️ Attention

> **This site hosts only the Agent Deployment Guide, not the agents themselves. A valid entitlement must be obtained before agents can be properly deployed.**

> For **IBM watsonx Assistant for Z Foundational Agents**, entitlement is automatically granted with the purchase of **IBM watsonx Assistant for Z**. By installing the **IBM watsonx Assistant for Z Foundational Agents** in accordance with the instructions provided herein, you acknowledge and agree to comply with the terms of the **[IBM watsonx Assistant for Z License](https://www.ibm.com/support/customer/csol/terms/?id=L-EZAK-KGTP3H)**. 

> For **Prebuilt IBM Z product agents**, a separate entitlement must be obtained for each corresponding product.

---

## Compatibility & Requirements

- **Helm:** v3.11+ (recommended v3.12+)
- **OpenShift CLI (oc)**:
    - installed and authenticated to the target cluster;
    - version compatible with your OCP (for example, oc 4.12+ for OCP 4.12).
    - Check: `oc whoami && oc version`
- **Network access:**
  - Online mode: pull images from registries (e.g., `icr.io`) or
  - Air‑gapped mode: mirror images into a private registry and configure `global.registry.*`
- **Architectures:** `amd64` and `s390x`

## Preflight Checklist

- **Prerequisite product installed**: IBM watsonx Assistant for Z (foundation). Install steps: IBM Docs → [Install watsonx Assistant for Z”](https://www.ibm.com/docs/watsonx/waz/3.0.0?topic=install-premises-watsonx-orchestrate-watsonx-assistant-z).

- **Entitlement(s) available for all agents being installed**:

    - Foundational Agents → covered by IBM watsonx Assistant for Z entitlement.

    - Prebuilt IBM Z product agents → require separate product entitlements (e.g. Db2 for z/OS, IMS).

### Where do I get the entitlement key?

- For **IBM watsonx Assistant for Z**: During the installation process of watsonx Assistant for Z, you would have acquired the entitlement key. However, if you need to retrieve it again, follow the steps in [Get wxa4z entitlement key](https://www.ibm.com/docs/en/watsonx/waz/3.0.0?topic=z-update-global-pull-secret)

- For **Prebuilt IBM Z product agents**: Refer to agent specific [README](#prebuilt-ibm-z-product-agents)

> **License Acceptance:** Each Prebuilt IBM Z product agent’s [values.yaml](/wxa4z-agent-suite/values.yaml) includes `acceptLicense: false` by default. Set `true` to proceed with installation, indicating acceptance of the associated license terms.

---

## Quick Start

### Clone the repository:

```bash
# HTTPS (public)
git clone https://github.com/IBM/z-ai-agents.git
cd z-ai-agents
# or: SSH
# git clone git@github.com:IBM/z-ai-agents.git
# cd z-ai-agents
```

Fetch chart dependencies for the umbrella chart:
```bash
cd wxa4z-agent-suite
helm dependency update
cd -
```
### 1. Global settings

***Create Shared Variables(Create once, reuse everywhere)***

| Key                           | What it is                                                            | Reference                    |
| ----------------------------- | --------------------------------------------------------------------- | ---------------------------- |
| `WATSONX_DEPLOYMENT_SPACE_ID` | ID of the watsonx.ai **Deployment Space** used for model deployments. | [Watsonx.ai Deployment Spaces](https://www.ibm.com/docs/en/cloud-paks/cp-data/5.2.x?topic=spaces-creating-deployment)|
| `WATSONX_ML_URL`              | Base URL of the **Watson Machine Learning / CPD** instance.           | CPD  Instance url or WML Endpoint(Cloud Only)           |
| `CPD_USERNAME`                | Username for **Cloud Pak for Data** authentication.                   | CPD Username           |
| `WATSONX_API_KEY`             | API key used to access CPD/Watsonx services.            |   [Create WATSONX_API_KEY](https://www.ibm.com/docs/en/cloud-paks/cp-data/5.2.x?topic=tutorials-generating-api-keys)      |
| `WATSONX_PROJECT_ID`          | watsonx.ai **Project** identifier used for assets and jobs.           | [Watsonx.ai Projects](https://www.ibm.com/docs/en/cloud-paks/cp-data/5.2.x?topic=projects-creating-project#create-a-project)    |
| `ORCHESTRATE_ENV_URL`          | Watsonx Orchestrate Service Instance URL           | Log In to watsonx orchestrate. Navigate to `settings`, copy the service instance url from `API Details` tab     |
| `ORCHESTRATE_ENV_TYPE`          | Watsonx Orchestrate Instance Type           | ibm_iam(for cloud), mcsp(AWS saas), cpd (on-prem)     |
| `EXTERNAL_WATSONX_API_KEY`          | External Watsonx API Key(Optional)         | External CPD API Key, required  only when External IFM is configured for WxO with model gateway |

---

**Fill required values in `global.secrets.data`:**

   Update [values.yaml](/wxa4z-agent-suite/values.yaml) to include all mandatory keys (`WATSONX_DEPLOYMENT_SPACE_ID`, `WATSONX_ML_URL`, `CPD_USERNAME`, `WATSONX_API_KEY`, `WATSONX_PROJECT_ID`, `ORCHESTRATE_ENV_URL`, `ORCHESTRATE_ENV_TYPE`) under `global.secrets.data`.

**Configure registry for mirrored images:**

   If using a private or mirrored registry, set `global.registry.server` to your internal registry endpoint and update `global.registry.name` to reference the imagePullSecret containing the registry credentials.
   > In air-gapped mode, authenticate to the private registry instead of using IBM entitlement keys.


   ```yaml
   global:
     # Shared (non-image) secret available to all subcharts. Intended for bootstrapjobs.
     secrets:
       name: wxa4z-watsonx-credentials   # K8s Secret name to be created/used.
       data:
         ORCHESTRATE_ENV_TYPE: cpd                    # Set this to "cpd", "ibm_iam"(for ibm cloud). Non‑sensitive.
         WATSONX_API_KEY: ""                         # Set this to CPD API key (on‑prem Refer https://www.ibm.com/docs/en/cloud-paks/cp-data/5.2.x?topic=tutorials-generating-api-keys) or IBM Cloud IAM API key (cloud).
         ORCHESTRATE_ENV_URL: ""                      # Set this to wxo service instance url.
         CPD_USERNAME: ""                             # Set this to CPD Username for on-prem deployments.
         WATSONX_DEPLOYMENT_SPACE_ID: ""              # Set this to Watsonx deployment space id (Refer https://www.ibm.com/docs/en/cloud-paks/cp-data/5.2.x?topic=spaces-creating-deployment) .
         WATSONX_ML_URL: ""                           # Set this to CPD Instance FQDN for on-prem deployments.
         EXTERNAL_WATSONX_API_KEY: ""                 # Set this to External CPD API Key  only when External IFM is configured for WxO with model gateway.
         WATSONX_PROJECT_ID: ""                       # Set this to Watsonx project id (Refer https://www.ibm.com/docs/en/cloud-paks/cp-data/5.2.x?topic=projects-creating-project#create-a-project).
     # Default image pull secret and registry auth used by many subcharts.
     # Set registry.createSecret to true only when default image pull fails for watsonx assistant for z agents or when using local registry for air-gapped clusters.
     registry:
       name: wxa4z-image-pull-secret    # Default pull secret name (namespace‑scoped).
       createSecret: false               # If true, chart templates will create this secret.
       server: cp.icr.io                   # ICR endpoint (can be region‑specific like us.icr.io).
       username: cp              # Required literal when using entitlement/IAM keys with ICR.
       entitlementKey: ""   # entitlement key/IAM APIkey used solely for image pulls.
   ```


   > The chart may template a namespace‑scoped Secret when `createSecret: true`.

---

### 2. Per Agent Configuration:

Each agent in the suite can be customized individually in [values.yaml](/wxa4z-agent-suite/values.yaml). Settings differ slightly for **Foundational Agents** and **IBM z/OS Product Agents**.

#### Configuration for IBM watsonx Assistant for Z Foundational Agents

- Enabled by default in most environments.
- Only require `enabled: true`.
- Fill additional values (if any) by consulting the [README](#ibm-watsonx-assistant-for-z-foundational-agents) for required fields, backend connectivity, and environment variables.

**Example:**

```yaml
support-agent:
  enabled: true
# ... additional agent-specific config ...
```

#### Configuration for Prebuilt IBM Z product agents

- Entitlement Key: must be provided under registry.entitlementKey.
- Set `enabled: true` and `acceptLicense: true` to proceed with installation. Accepting a chart’s `acceptLicense: true` indicates consent to those terms. See each agent’s license links for details.
- Additional Values: consult the [README](#prebuilt-ibm-z-product-agents) for backend connectivity and required environment variables.

**Example**

```yaml
ims-agent:
  enabled: true
  acceptLicense: true
  registry:
    name: ims-image-pull-secret
    createSecret: true
    server: icr.io
    username: iamapikey
    entitlementKey: "<IMS_PRODUCT_ENTITLEMENT_KEY>"
  # ... additional agent-specific config ...
```

#### Connecting to LLM via AI Gateway (Optional)

> **Note** Use this configuration only if your agents must connect to **LLMs hosted externally** through an AI Gateway.

---

##### 1. Create Model Gateway Connection
- Follow the IBM documentation to create and configure a Model Gateway connection:
  [Managing LLM in Watson Orchestrate](https://developer.watson-orchestrate.ibm.com/llm/managing_llm)

---

##### 2. Configure External API Key in [`values.yaml`](/wxa4z-agent-suite/values.yaml)
- Update your `global.secrets.data` section with the **external CPD API key** or **IBM Cloud API key**.
- Set the `WATSONX_ML_URL` to point to the **external CPD instance**.

```yaml
global:
  secrets:
    name: wxa4z-watsonx-credentials
    data:
      WATSONX_ML_URL: "https://<external-cpd-instance>"
      EXTERNAL_WATSONX_API_KEY: "<external-api-key>"
```
##### 3. Update Agent Configuration

- Navigate to the specific agent subchart:
  -  agent-helm-charts/<agent-name>/config/*_agent.yaml
- Replace the model reference from `watsonx/meta-llama/llama-3-3-70b-instruct` to `virtual-model/watsonx/meta-llama/llama-3-3-70b-instruct`

##### 4. Refresh Helm dependency

- Navigate to [wxa4z-agent-suite](/wxa4z-agent-suite/) and refresh dependencies

```bash
cd wxa4z-agent-suite
helm dependency update
```


---

### 3. Install / Upgrade / Uninstall

#### Install

```bash
helm upgrade --install wxa4z-agent-suite \
  ./wxa4z-agent-suite \
  -n <wxa4z-namespace> \
  -f <path>/values.yaml \
  --wait
```

#### Upgrade

```bash
# Review release notes per agent. Then:
helm upgrade wxa4z-agent-suite \
  ./wxa4z-agent-suite \
  -n <wxa4z-namespace> \
  -f <path>/values.yaml \
  --wait
```

> Avoid `--reuse-values` when switching registries, secrets, or toggling many agents; prefer an explicit values file for clarity and auditability.

#### Uninstall

**wxa4z-agent-suite chart uninstall**
```bash
helm uninstall wxa4z-agent-suite -n <namespace>
```

#### Uninstall specific agent

1.Set the `<agent>.enabled` flag to false.

**Example:**

```yaml
ims-agent:
  enabled: false
```


2.Run helm upgrade

```bash
helm upgrade --install wxa4z-agent-suite \
  ./wxa4z-agent-suite \
  -n <wxa4z-namespace> \
  -f <path>/values.yaml \
  --wait
```

---

## Post Install Verification

```bash
# Check release and pods
helm status wxa4z-agent-suite -n <namespace>
oc get pods -n <namespace>

# Check agent‑specific routes/services (OpenShift)
oc get route -n <namespace>
```

Common health signals:

- All enabled agents are in `Running`/`Ready` state.
- Routes/Ingresses are admitted and resolve over TLS.
- Agents successfully reach required backends (CPD/WML, Orchestrate, z/OS endpoints) per their README checks.

---

## Troubleshooting

- **Image pull back‑off**:
  - Verify the global pull secret
  - Verify the Entitlement keys for Prebuilt IBM Z product agents and that in per‑agent `registry.*` values point to the correct server/secret.
  - In case of airgapped cluster, Verify pull secret in the target namespace and that `global.registry.*` or per‑agent `registry.*` values point to the correct server/secret.
- **License not accepted**: Ensure `acceptLicense: true` for each enabled agent.
- **Connectivity to CPD/Orchestrate**: Recheck URLs, tokens, and firewall rules. Validate with `curl` from a debug pod.
- **Air‑gapped fetch errors**: Ensure images are mirrored with the exact tags/digests referenced by the charts.


### Getting more logs

```bash
# Describe failing pods
oc describe pod/<name> -n <namespace>

# Helm rendering dry‑run
helm upgrade --install wxa4z-agent-suite ./wxa4z-agent-suite -n <namespace> -f values.yaml --dry-run --debug

# OpenShift events
oc get events -n <namespace> --sort-by=.lastTimestamp | tail -n 50
```

---

## FAQ

**Q: Can I enable only a subset of agents?**\
Yes. Set `enabled: true|false` per agent in your values file.

**Q: How do I manage multiple environments?**\
Create separate files like `values.dev.yaml`, `values.qa.yaml`, `values.prod.yaml`. Use `-f` to select.

**Q: Can I use my private registry?**\
Yes. Mirror images and set `global.registry.server` and `<agent>.registry.server` to your registry  . Update `registry.name/username/password` accordingly.

**Q: Which architectures are supported?**\
Most agents target `amd64` and `s390x`. See each agent’s README for specifics.
