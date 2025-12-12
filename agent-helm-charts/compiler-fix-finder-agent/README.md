# IBM Z Compilers Fix Finder Agent

## Overview
The IBM Z Compilers Fix Finder Agent helps compiler users find any potential fixes for unexpected compiler behavior.

## Agent capabilities

| Agent capability                                 | Description                                                                                                                 |
| ------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------- |
| Investigate error causes              | Provides related documentation for known errors that may be related to the problem described                                            |
| Report known fixes            | Provides a list of known fixes and workarounds for given errors for supported IBM Z compilers      |

## Prerequisites
Ensure the following:

- [watsonx Assistant for Z](https://www.ibm.com/docs/watsonx/waz/3.0.0?topic=install-premises-watsonx-orchestrate-watsonx-assistant-z) is installed

## IBM Z Compilers Fix Finder Agent

### Retrieve the entitlement key

An entitlement key is required to download the IBM Z Compilers Fix Finder Agent container image from the IBM Container Registry. This entitlement key is available at no charge to licensed users of IBM Enterprise COBOL for z/OS.

* To obtain the entitlement key, download the entitlement memo from Agentic AI Tools for IBM Z Compilers website.

Once you have an entitlement key, paste it into the Helm chart under the compiler-fix-finder-agent definitions like so:

```yaml
compiler-fix-finder-agent:
  enabled: true
  registry:
    name: z-compiler-fix-finder-image-pull-secret
    server: icr.io
    username: iamapikey
    entitlementKey: "<IBM_Z_COMPILER_FIX_FINDER_ENTITLEMENT_KEY>"
```

### Create shared variables

Certain variables are common across all agents. To configure these shared variables, refer to [Create shared variables](../../README.md#1-global-settings).
However, if any of these shared variables are also defined in your agent-specific [values.yaml](https://github.com/IBM/z-ai-agents/blob/main/wxa4z-agent-suite/values.yaml) file, the values specified in the values.yaml file will override the shared ones.

### Configure the values.yaml file

To enable the IBM Z Compilers Fix Finder Agent, you need to configure agent-specific values in the [values.yaml](https://github.com/IBM/z-ai-agents/blob/main/wxa4z-agent-suite/values.yaml) file.

In the values.yaml file, scroll down to the automation-insights-agent section and update the keys as outlined in the following table.

| Key       |            Description                  |
|------------------------------|-----------------------------------|
**Environment variables**                                                        |
**For on-prem deployments**
DEPLOYMENT_TYPE | Deployment environment type (`on_prem`)  
WML_URL | URL for the on-premises Watson Machine Learning (WML) service
CPD_VERSION | CPD version for on-prem deployments (e.g., `5.1`)             
CPD_USERNAME | Username for accessing the Cloud Pak for Data (CPD) environment
ONPREM_WML_INSTANCE_ID | Identifier for the Watson Machine Learning instance (always set to `openshift`)
**For cloud deployment**
DEPLOYMENT_TYPE | Deployment environment type (`cloud`)
WML_URL | URL for the cloud [Watson Machine Learning API](https://cloud.ibm.com/apidocs/machine-learning)
**For on-prem and cloud deployments**
DEPLOYMENT_SPACE_ID | Watsonx AI deployment space ID
WATSONX_API_KEY | API key for authenticating with IBM Cloud services or CPD instance
LLM_MODEL | Model ID for the on-premises Large Language Model (LLM) (e.g.,ibm/granite-3-8b-instruct)
**Secrets**
AGENT_AUTH_TOKEN | Authentication token for the agent
> DO NOT CHANGE VALUES IN `secrets` SECTION of  `values.yaml`


### Install or upgrade the wxa4z-agent-suite

> **Note**:- If you're installing multiple agents, you can configure the [values.yaml](https://github.com/IBM/z-ai-agents/blob/main/wxa4z-agent-suite/values.yaml) file for all the agents you wish to install. Once the file is updated, run the command below to install them all at once.

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
3. Select the **IBM Z Compilers Fix Finder Agent** tile.
4. In the AI Assistant window, enter a query to confirm that the response aligns with your expectations.
5. Click **Deploy** to activate the agent and make it available in the live environment.


## Test the agent

After deployment, the agent becomes active and is available for selection in the live environment.

1. From the main menu, select **Chat**.
2. Choose your agent from the list.
3. Enter your queries using the AI Assistant.
   For example:

  - How do I properly update my usermod after installing a PTF that modifies the IGYCDOPT module?
  - My COBOL 6.3 program is crashing when I code a JSON statement. Are there fixes related to this?

4. Verify that the responses returned by the AI Assistant are accurate.


## Troubleshooting installation errors

If you run into any errors during installation, refer to [Troubleshooting](../../README.md#troubleshooting) for troubleshooting steps.


## Uninstalling the agent

For uninstallation instructions, refer to [Uninstall specific agent](../../README.md#uninstall-specific-agent).

------------------------------------------------------------
