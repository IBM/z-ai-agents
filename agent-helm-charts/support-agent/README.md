# SUPPORT-AGENT

The Support Agent provides capabilitiy to execute Ansible playbooks to:

- Trigger ansible playbooks hosted on Ansible Automation Platform based on user input.
      - Playbooks supported,
         - Take z/OS dump : Collect dump on a z/OS address space
         - TLS: z/OS Send Dump :Collect dump on a z/OS address space and transfer
In addition to this the agent also supports,
     - Retrieving the launched ansible job status and logs

# Prerequisites:
* This agent requires a Ansible Automation Platform instance and its credentials
* This agent requires a watsonx ai deployment space.
  - Please refer [create deployment space](https://www.ibm.com/docs/en/watsonx/w-and-w/2.1.0?topic=spaces-creating-deployment) and to get the `space GUID`, open your deployment space, and click the `Manage` tab.
  - `space GUID` should be used as `deployment_space_id` as environment variable.


## Updating `values.yaml`

Update `values.yaml` to customize the configuration of your agent. 

### Environment Variables
Set the following environment variables in `values.yaml` `env` section.

**For ON-PREM Deployments**

| Environment Variable         | Value                             | Description                                                       |
|------------------------------|-----------------------------------|-------------------------------------------------------------------|
| `DEPLOYMENT_SPACE_ID`        | `<your-deployment-space-id>`      | Identifier of the Watson Machine Learning deployment space  refer [Prerequesites](#prerequisites) for creating deployment space.    |
| `WML_URL`                    | `<your-wml-url>`                  | CPD Instance URL                 |
| `ONPREM_WML_INSTANCE_ID`     | `openshift`   |  on-prem wml instance id (always set to `openshift`)|
| `LLM_MODEL`                  | `meta-llama/llama-3-1-70b-instruct`                | Name  of the large language model to use (`meta-llama/llama-3-1-70b-instruct`) |
| `DEPLOYMENT_TYPE`            | `on-prem`         | Deployment environment type (`on-prem`)            |
| `CPD_VERSION`                | `5.1`              | CPD version for on-prem deployments (e.g., `5.1`)                |


**For Cloud Deployment**
| Environment Variable         | Value                             | Description                                                       |
|------------------------------|-----------------------------------|-------------------------------------------------------------------|
| `DEPLOYMENT_SPACE_ID`        | `<your-deployment-space-id>`      | Identifier of the Watson Machine Learning deployment space  refer [Prerequesites](#prerequisites) for creating deployment space.    |
| `WML_URL`                    | `<your-wml-url>`                  | WML Instance URL  [IBM WML API Reference](https://cloud.ibm.com/apidocs/machine-learning)               |
| `LLM_MODEL`                  | `meta-llama/llama-3-3-70b-instruct`                | Name  of the large language model to use (`meta-llama/llama-3-1-70b-instruct`) |
| `DEPLOYMENT_TYPE`            | `cloud`         | Deployment environment type (`on-prem`)            |

**Common variables**

| Environment Variable         | Value                             | Description                                                       |
|------------------------------|-----------------------------------|-------------------------------------------------------------------|
| `TAKE_DUMP_JOB_TEMPLATE`**   | `<take-dump-job-template-name>`   | Template name of take dump ansible job                            |
| `SEND_DUMP_JOB_TEMPLATE`**   | `<send-dump-job-template-name>`   | Template name of send dump anisble job                            |
| `LANGFUSE_HOST`              | `<langfuse-host-url>`             | Langfuse host url                                                 |
| `LANGFUSE_TRACING_ENABLED`   | `<langfuse-tracing-flag>`         | Enable/Disable langfuse                                           |
| `LANGFUSE_PUBLIC_KEY`        | `<langfuse-public-key>`           | Public key to access langfuse                                     |
| `LANGFUSE_SECRET_KEY`        | `<langfuse-secret-key>`           | Secret key to access langfuse                                     |
| `ENABLE_LANGFUSE_TRACES`     | `<langfuse-traces-flag>`          | Enable/Disable complete langfuse traces                           |

**Steps to fetch playbook template names:
  - Login to AAP
  - Go to Resources -> Templates
  - Look for template names pointing to send or collect tls z/os dump
  - Populate the env vars with exact string from AAP templates (wrap string in double quotes in values.yaml)


### Storage
To use persistent storage, set `pvc.enabled` to true and adjust the `pvc.size`, `pvc.storageClass`, and `pvc.accessModes` settings as needed. 

### Resources
Configure `resources.limits` and `resources.requests` to configure the CPU and memory resources for your deployment. 


### Secrets

**DO NOT CHANGE BELOW VALUES IN `secrets` SECTION of  `values.yaml`**

| Secret Key              | Description                                                 |
|-------------------------|-------------------------------------------------------------|
| `AGENT_NAME`            | Unique name of the IBM Support agent                         |
| `AGENT_DESCRIPTION`     | What the agent does: used for routing user queries |
| `AGENT_AUTH_TYPE`       | Authentication method the agent uses                        |
| `AGENT_SERVICE_PATH`    | Rest path exposed by the agent |
| `ORCHESTRATOR_DESCRIPTION` | Orchestrator Agent Description |
| `ORCHESTRATOR_INSTRUCTION` | Orchestrator Agent Instruction |


**SET VALUES FOR BELOW KEYS IN `secrets` SECTION of `values.yaml`**

| Environment Variable       | Value                         | Description                                                                                         |
|----------------------------|-------------------------------|-----------------------------------------------------------------------------------------------------|
| `AGENT_AUTH_TOKEN`         | `<your-agent-auth-token>`     | Token used by the agent-controller to register this agent with wxo (API_KEY or Bearer)               |
| `CPD_USERNAME`             | `<your-cpd-username>`         | CPD username for on-prem deployments (set to empty for cloud)                                       |
| `ONPREM_API_KEY`           | `<your-onprem-api-key>`       | CPD on-prem  API key (set to empty for cloud)[How to get cpd api key](https://www.ibm.com/docs/en/cloud-paks/cp-data/5.1.x?topic=tutorials-generating-api-keys)                                                    |
| `CLOUD_API_KEY`            | `<your-cloud-apikey>`         | IBM Cloud API key for cloud deployments (set to empty for on-prem)                                  |
| `AAP_ENDPOINT`      | `<your-aap-endpoint>`  | Base URL of your AAP instance for the tls-agent                                              |
| `AAP_USERNAME`      | `<your-aap-username>`  | Username credential for accessing the AAP API                                                    |
| `AAP_PASSWORD`      | `<your-aap-password>`  | Password credential for accessing the AAP API   

## Deploying the agent

### Step 1: Create ICR Pull Secret (First-Time Setup)

Run the following command to create an image pull secret for IBM Cloud Container Registry (ICR):

```bash
oc create secret -n <your-namespace> docker-registry icr-pull-secret \
  --docker-server=icr.io \  #replace this with container registry
  --docker-username=iamapikey \ # replace this with container registry username
  --docker-password=<your-api-key> # replace this with container registry password
```

> Replace `<your-namespace>` and `<your-api-key>` with appropriate values.


---

### Step 2: Update pull secret in `values.yaml`

In your Helm chart's[ `values.yaml`](./support-agent/values.yaml), update the image pull secret:

```yaml
imagePullSecrets:
  - name: icr-pull-secret
```

---

### Step 3: Install Helm Chart

Finally, install the Helm chart:

```bash
helm upgrade --install wxa4z-support-agent . \
  -n <your-namespace> \
  --create-namespace \
  -f values.yaml
```
> **Note** If you want to install agents standalone on a OpenShift cluster without wxa4z-operator, agent registration should be done through UI refer the official guidance [Adding AI assistants from external AI agents](https://www.ibm.com/docs/en/watsonx/watson-orchestrate/current?topic=agent-adding-ai-assistants-ai-chat#external-agents)
---
