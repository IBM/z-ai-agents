# IBM Z Upgrade agent

## Overview
The IBM Z Upgrade agent enables system programmers to perform z/OS upgrades through the Watson Assistant for Z chat interface. It provides precise responses by leveraging z/OSMF APIs and client-specific documentation stored in ZRAG.

## Agent capabilities

| Agent capability         |            Description                  |
|------------------------------|-----------------------------------|
| Lists software products        | Provides a comprehensive list of software products for a given system    |
Lists software instance details | Shows detailed metadata of a given software instance such as its Name, Description, Global Zone, Target Zone, and so on.
Retrieves missing FIXCATs by software instance | Identifies missing FXCAT Updates for specific software instances and systems.
Retrieves missing FIXCATs by software product | Identifies missing FIXCAT updates for software instances associated with the specified products and systems.
Acquires missing FIXCAT updates | Retrieves the required PTFs for the specified RESOLVERS or FIXCAT names.
Monitors PTF acquisition job status| Tracks the progress and current status of background jobs initiated to acquire PTFs.
Installs the acquired PTFs | Begins the installation or update process for the requested PTFs.
Retrieves the installation or update status | Retrieves the status of installation or update processes using either the process ID or the names of the software instance and system.
Displays HOLD data | Shows HOLD data related to any unresolved HOLDS.
Resumes installation or update process | Continues the installation or update process if the user agrees to resolve all unresolved HOLDS.
Cancels the installation or update process | Cancels the installation or update process only upon user request.
Copies installation output | Copies the installation or update output, along with the process ID, to the user-specified UNIX path (e.g., /AQFT/tmp/smpe/).
Check hardware-compatibility for upgrade | Performs a check if the given system's hardware is compatible for an upgrade to a specified version
Retrieve Content from agent documentation stored in ZRAG |  Answers the upgrade workflow-related queries using the ingested docs for the agent.


## Prerequisites
Ensure the following:

- [watsonx Assistant for Z]( https://www.ibm.com/docs/watsonx/waz/3.0.0?topic=install-premises-watsonx-orchestrate-watsonx-assistant-z) is installed
- The minimum version of z/OSMF is 3.1

## Install the IBM Z Upgrade Agent



### Retrieve the entitlement key

During the installation process of watsonx Assistant for Z, you would have acquired the entitlement key. However, if you need to retrieve it again, follow these steps:

1. Click the ink to sign in to [My IBM](https://myibm.ibm.com/dashboard/).
2. Scroll down and locate the Container Software & Entitlement Keys tile, then click View Library.
3. Find your hidden key and click the Copy button next to it.
4. Set the global entitlement key using the watsonx Assistant for Z entitlement key:

```yaml
global:
  registry:
    name: wxa4z-image-pull-secret
    createSecret: true
    server: icr.io
    username: iamapikey
    entitlementKey: "<WATSONX_ASSISTANT_FOR_Z_ENTITLEMENT_KEY>"
```

### Create Shared Variables

Certain variables are common across all agents. To configure these shared variables, refer to [Create shared variables](https://github.com/IBM/z-ai-agents?tab=readme-ov-file#1-global-settings) (link to the global GitHub page).
However, if any of these shared variables are also defined in your agent-specific [values.yaml](/agent-helm-charts/upgrade-agent/values.yaml) file, the values specified in the suite [values.yaml](/wxa4z-agent-suite/values.yaml) file will override the shared ones.

### Configure the values.yaml file

To enable the IBM Z Upgrade Agent, you need to configure agent-specific values in the [values.yaml](/wxa4z-agent-suite/values.yaml) file.

In the values.yaml file, scroll down to the Upgrade Agent section and update the keys as outlined in the following table.

| Key       |            Description                  |
|------------------------------|-----------------------------------|
**Environment variables**                                                        |
WATSONX_MODEL_ID | LLM Model Used by the Agent. For example, "meta-llama/llama-3-70b-instruct".
WRAPPER_URL | Endpoint for OpenSearch.
HOST_NAME | Cluster endpoint where the image is deployed.
PDS_NAME | Partitioned Dataset Name for storing the REXX script. It should follow the naming convention {USERNAME}.REXX.
INGESTION_URL | URL of the service endpoint where documents or data are uploaded for ingestion.
**PTF Job Configurations**
SMPNTS | Path for SMP/E target zone datasets
SMPWDIR_PATH | SMP/E working directory path
SMPJHOME | Used in UNIX System Services (USS) or JCL scripts to specify the root directory of the SMP/E Java-based interface.
SMPCPATH | Path for SMP/E CSI datasets
ORDER_SERVER_URL | IBM Shopz server URL.
KEYRING | The name of the RACF keyring where the certificate is stored.
CERT_NAME | Keyring certificate label.
DOWNLOAD_METHOD | Depending on the environment's policy, choose from https, ftp, or sftp.
DOWNLOADKEYRING | The RACF keyring used for securing outbound TLS connections, as required by z/OS.
**Secrets**
ZOSMF_ENDPOINT | The endpoint URL for the z/OS Management Facility (z/OSMF), provided by IBM for managing and interacting with z/OS systems.
ZOSMF_USERNAME | User name for connecting to the z/OSMF endpoint.
ZOSMF_PASSWORD | Password for connecting to the z/OSMF endpoint.
AGENT_AUTH_TOKEN | Authentication token for the agent.
WRAPPER_USERNAME | User name for accessing the WRAPPER_URL endpoint.
WRAPPER_PASSWORD | Password for accessing the WRAPPER_URL endpoint.
INGESTION_PASSWORD | User name for accessing the INGESTION_URL endpoint.

 Please refer to this document for information on these varaibles <link to the doc>
### Install or upgrade the wxa4z-agent-suite

> **Note**:- If you're installing multiple agents, you can configure the [values.yaml](/wxa4z-agent-suite/values.yaml) file for all the agents you wish to install. Once the file is updated, run the command below to install them all at once.


Use the following command to install or upgrade the wxa4z_agent_suite:

```yaml
helm upgrade --install wxa4z-agent-suite \
  ./wxa4z-agent-suite \
  -n <wxa4z-namespace> \
  -f <path_to>/values.yaml --wait
```

## Deploy the agent

1. Log in to watsonx Orchestrate.
2. From the main menu, navigate to **Build** > **Agent Builder**.
3. Select the **IBM Z Upgrade Agent** tile.
4. In the AI Assistant window, enter a query to confirm that the response aligns with your expectations.
5. Click **Deploy** to activate the agent and make it available in the live environment.


## Test the agent

After deployment, the agent becomes active and is available for selection in the live environment.

1. From the main menu, click **Chat**.
2. Choose your agent from the list.
3. Enter your queries using the AI Assistant.
   For example:
   
      - Can you show software instance available for system AQFT?

      - Can you retrieve missing fixcat updates for software instance Watsonx-Testing on system S2?

    Responses are displayed either in a tabular format or as a sentence, depending on the context.

4. Verify that the responses returned by the AI Assistant are accurate.

## Troubleshooting installation errors
If you run into any errors during installation, see [Troubleshooting](../../README.md#troubleshooting) for troubleshooting steps.

## Uninstalling the agent
For uninstallation instructions, see [Agent Uninstallation](../../README.md#uninstall-specific-agent)

-------------------------
