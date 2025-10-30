# IBM CICS Transaction Server agents for Z Helm Chart

## Overview
The IBM CICS Transaction Server agents for Z (CICS agent) can answer questions about CICS topology and assist with problem determination when given transaction error codes. It provides targeted responses to questions, drawing on a variety of data sources to deliver context-aware guidance, best practice recommendations, and actionable next steps.

The CICS agent provides the following agents: 
- CICS topology agent.
- CICS problem determination agent.
- CICS routing agent(installed as part of the watsonx Assistant for Z set up).

For information about CICS TS for z/OS, see https://www.ibm.com/docs/en/cics-ts/6.x

## Agents capabilities

| Agents capability       |            Description                  |
|------------------------------|-----------------------------------|
**CICS topology agent**
Topology Support        | Answers questions about CICS TS by using various data sources, including information from subject matter experts (SMEs) and IBM product documentation. By providing understanding, recommendations, and best practices, it helps users to gain clarity and to make informed configuration and management decisions effectively.
SME interview data |Insights from IBM CICS subject matter experts to enhance accuracy and clarify complex behavior. It embeds best practices into responses to ensure that recommendations are grounded in real-world experience.
Z RAG Capabilities| Answers topology-related queries by using ingested IBM documentation from Z RAG, to provide clear, accurate, and structured insights into the CICS system setup and configuration.
Ranks Documentation | To improve relevance, prioritizes and ranks documents based on how well they match the user's query.
**CICS problem determination agent**
Problem determination Support |  Helps to diagnose issues in the user's CICS system by using various data sources, including live system data and IBM product documentation. It explains error codes (for example, DFHAC messages), identifies likely causes, and recommends next steps that are tailored to the user’s environment.
Z RAG Capabilities| Uses ingested IBM documentation from Z RAG to support problem determination.
Interacts with live CICS systems  | 	Executes read-only commands to retrieve real-time system data that supports analysis.
Tool Integration | Provides visibility into live CICS system behavior through MCP, including information about transaction and programs. This helps to maintain situational awareness and to support informed decision-making during investigations.
Extracts DFHAC message | Parses and interprets DFHAC error messages to support troubleshooting.
Adaptive response strategy | Dynamically responds using live system data when this data is available, or falls back to static documentation when it is not, depending on server availability.
**CICS routing agent**
Question routing | Identifies the theme of the user's query and directs it to the most appropriate agent, ensuring the question is handled by the agent best suited to resolve it.


## Prerequisites
Ensure the following:
- [IBM watsonx Assistant for Z](https://www.ibm.com/docs/en/watsonx/waz/2.0.0?topic=install-watsonx-assistant-z) is installed
- The minimum version of z/OSMF is 3.1
- The agents require a watsonx Project ID.
  - This should be used as WATSONX_PROJECT_ID as an environment variable.

Additionally, the CICS problem determination agent requires:
- CICS Transaction Server for z/OS version 6.3 or later, with APAR PH68212 applied.
- MCP server running in CICS. See Configuring CICS MCP server https://www.ibm.com/docs/en/cics-ts/6.x?topic=configuring-cics-mcp-server

Optionally, to validate container signatures, `skopeo` and `gpg`.

## Optional: Verify container signatures

You will need [skopeo](https://github.com/containers/skopeo>) installed to validate signatures. You will aslo need `gpg` installed.

> The example commands validate the container for the CICS Topology Agent. To check the signatures for other CICS agent containers, change the tag accordingly.

#### Step 1: Importing the Key
This directory contains a file named `pubkey.asc`. To verify the signature, install this GPG Public Key into your local keyring.

First run: `gpg --import ./public_key.asc` to import the public key. You should see something like:

```
gpg: key F884D56B4AA7091A: public key "IBM CICS Transaction Server agents for Z <psirt@us.ibm.com>" imported
gpg: Total number processed: 1
gpg:               imported: 1
```

Now run `export FINGERPRINT=$(gpg --fingerprint --with-colons | grep fpr | tr -d 'fpr:')`
<br>

#### Step 2: Extracting the container

Sign in to skopeo so the container can be pulled with `skopeo login --username <USERNAME> --password <PASSWORD_OR_TOKEN> icr.io`.

Copy the container image to a temporary directory with `skopeo copy docker://icr.io/ibm-cics-ts/cics-ai-agent:topology-1.0.0 dir:./tmp/`.
  
This copies blobs, manifests and signatures from the container into the `tmp` directory. The signature will usually be something like `signature-1`.
<br>

#### Step 3: Validating the signature

You can now verify the signature.. Run `skopeo standalone-verify ./tmp/manifest.json icr.io/ibm-cics-ts/cics-ai-agent:topology-1.0.0 $FINGERPRINT ./tmp/signature-1`

You should see output like this:
```Signature verified using fingerprint B83574F1F039B21CDCC4FD5FF884D56B4AA7091A, digest sha256:f2f11696e64395b79a9f5e31b91bae4f8c802ae1548ffd831067b3eb3ed1f077```

If you see something else, such as an error, check the image was downloaded from a trusted source. An example of an incorrect signature verification would be:

```FATA[0000] Error verifying signature: Signature by B83574F1F039B21CDCC4FD5FF884D56B4AA7091A does not match expected fingerprints [B83574F1F039B21CDCC4FD5FF884D56B4AA7091B]```

You can now repeat this process for the other signature files in the `tmp` folder, and for other container images as part of the IBM CICS Transaction Server agents for Z product. 

> Remember to clear the folder `tmp` with `rm -rf ./tmp` after each image has been verified.

## Install the CICS Agent

### Retrieve the entitlement key

The entitlement key is provided as part of the Bill of Materials during the installation process for CICS Transaction Server for z/OS. However, if you need to retrieve it again, follow these steps:

1. Click the link to sign in to [Shopz](https://www.ibm.com/software/shopzseries/ShopzSeries_public.wss?action=home).
2. In your catalogue, navigate to **CICS Transaction Server for z/OS**.
3. In the program files, open the file called 'Entitlement Key' to find the **entitlement key**.
4. Set the global entitlement key using the CICS product entitlement key:

```yaml
cics-agent:
  enabled: false
  acceptLicense: True  #IBM Terms - https://www.ibm.com/support/customer/csol/terms/?id=L-SSLZ-QYC4LH
  registry:
    name: cics-image-pull-secret
    createSecret: true
    server: icr.io
    username: iamapikey
    entitlementKey: "<CICS_ENTITLEMENT_KEY>"
```

## Topology agent configuration
### Create Shared Variables

Some variables are common across all agents. To configure these shared variables, refer to [Create shared variables](https://github.com/IBM/z-ai-agents/blob/main/README.md#1-global-settings).
However, if any of these shared variables are also defined in your agent-specific [values.yaml](https://github.com/IBM/z-ai-agents/blob/main/wxa4z-agent-suite/values.yaml) file, the values that you specify in the values.yaml file will override the shared ones.

### Configure the values.yaml file

To enable the CICS topology agent, you need to configure agent-specific values in the [values.yaml](https://github.com/IBM/z-ai-agents/blob/main/wxa4z-agent-suite/values.yaml) file.

In the values.yaml file, scroll down to the CICS Agent section and update the keys as outlined in the following table.

| Key       |            Description                  |
|------------------------------|-----------------------------------|
**Environment variables**
WATSONX_MODEL_ID | Default model to use in LLM calls.
MODEL_CATALOG_PATH | File path to the YAML configuration file.
**Secrets**
WATSONX_API_KEY| Your watsonx API key.
WRAPPER_USERNAME| The username for the Z RAG instance in your cluster.
WRAPPER_PASSWORD| The password for the Z RAG instance in your cluster.
WRAPPER_URL| The URL for the Z RAG instance in your cluster.
INGESTION_URL| Endpoint URL for the data ingestion.
INGESTION_PASSWORD| Password that is used to authenticate with the ingestion service.
AGENT_ID| Unique identifier for the Agent instance, used to distinguish it within the watsonx Orchestrate.
AGENT_SECRET | Secret key used to securely authenticate the agent.
WATSONX_PROJECT_URL| Your watsonx URL.
WATSONX_PROJECT_ID| Identifier for your watsonx Project ID.
> DO NOT CHANGE VALUES IN `secrets` SECTION of  `values.yaml`


### Install or upgrade the wxa4z-agent-suite

> <div class="note note"><span class="notetitle">Note:</span> If you're installing multiple agents, you can configure the <a href="https://github.com/IBM/z-ai-agents/blob/main/wxa4z-agent-suite/values.yaml">values.yaml</a> file for all the agents you wish to install. After the file is updated, run the command below to install them all at once.</div>

Use the following command to install or upgrade the wxa4z_agent_suite:

```yaml
helm upgrade --install wxa4z-agent-suite \
  ./wxa4z-agent-suite \
  -n <wxa4z-namespace> \
  -f <path_to>/values.yaml --wait
```

## Deploy the agent

1. Log in to IBM watsonx Orchestrate.
2. From the main menu, navigate to **Build** > **Agent Builder**.
3. Select the **Topology Agent** tile.
4. In the AI Assistant window, enter a query to confirm that the response aligns with your expectations.
5. Click **Deploy** to activate the agent and make it available in the live environment.

## Test your agent

After deployment, the agent becomes active and is available for selection in the live environment.

1. From the main menu, click **Chat**.
2. Choose your agent from the list.
3. Enter your queries using the AI Assistant.
   For example:

    - How do I configure CICS regions for high availability?

    - Should I use a single CICS region for all my applications?

    Responses are displayed either in a tabular format or as a sentence, depending on the context.

4. Verify that the responses returned by the AI Assistant are accurate.

------------------------------------------------------------

## Problem determination agent configuration

### Create Shared Variables

Some variables are common across all agents. To configure these shared variables, refer to [Create shared variables](https://github.com/IBM/z-ai-agents/blob/main/README.md#1-global-settings)(the global GitHub page).
However, if any of these shared variables are also defined in your agent-specific [values.yaml](https://github.com/IBM/z-ai-agents/blob/main/wxa4z-agent-suite/values.yaml) file, the values that you specify in the values.yaml file will override the shared ones.

### Configure the values.yaml file

To enable the CICS problem determination Agent, you need to configure agent-specific values in the [values.yaml](https://github.com/IBM/z-ai-agents/blob/main/wxa4z-agent-suite/values.yaml) file.

In the values.yaml file, scroll down to the CICS Agent section Agent section and update the keys as outlined in the following table.

| Key       |            Description                  |
|------------------------------|-----------------------------------|
**Environment variables**
WATSONX_MODEL_ID | Default model to use in LLM calls.
MODEL_CATALOG_PATH | File path to the YAML configuration file.
MCP_SERVER_URL | URL endpoint for the MCP Server within CICS.
APPLID| The VTAM Generic APPLID for the target CICS system that hosts the MCP Server.
**Secrets**
WATSONX_API_KEY| Your watsonx API key.
WRAPPER_USERNAME| The username for the Z RAG instance in your cluster.
WRAPPER_PASSWORD| The password for the Z RAG instance in your cluster.
WRAPPER_URL| The URL for the Z RAG instance in your cluster.
INGESTION_URL| Endpoint URL for the data ingestion.
INGESTION_PASSWORD| Password that is used to authenticate with the ingestion service.
AGENT_ID| Unique identifier for the Agent instance, used to distinguish it within the watsonx Orchestrate.
AGENT_SECRET| Secret key used to securely authenticate the agent.
WATSONX_PROJECT_URL| Your watsonx URL.
WATSONX_PROJECT_ID| Identifier for your watsonx Project ID.
SERVICE_ENDPOINT | Service endpoint URL for agent registration.
> DO NOT CHANGE VALUES IN `secrets` SECTION of  `values.yaml`


### Install or upgrade the wxa4z-agent-suite

> <div class="note note"><span class="notetitle">Note:</span> If you're installing multiple agents, you can configure the <a href="https://github.com/IBM/z-ai-agents/blob/main/wxa4z-agent-suite/values.yaml">values.yaml</a> file for all the agents you wish to install. After the file is updated, run the command below to install them all at once.</div>

Use the following command to install or upgrade the wxa4z_agent_suite:

```yaml
helm upgrade --install wxa4z-agent-suite \
  ./wxa4z-agent-suite \
  -n <wxa4z-namespace> \
  -f <path_to>/values.yaml --wait
```

## Deploy the agent

1. Log in to IBM watsonx Orchestrate.
2. From the main menu, navigate to **Build** > **Agent Builder**.
3. Select the **Problem determination Agent** tile.
4. In the AI Assistant window, enter a query to confirm that the response aligns with your expectations.
5. Click **Deploy** to activate the agent and make it available in the live environment.

## Test your agent

After deployment, the agent becomes active and is available for selection in the live environment.

1. From the main menu, click **Chat**.
2. Choose your agent from the list.
3. Enter your queries using the AI Assistant.
   For example:

    - Can you guide me through debugging a DFHAC2001 error in CICS? On transaction [_transaction ID_]?

    - I am getting DFHAC2010 on [_transaction ID_] transaction ID?

    Responses are displayed either in a tabular format or as a sentence, depending on the context.

4. Verify that the responses returned by the AI Assistant are accurate.

------------------------------------------------------------
