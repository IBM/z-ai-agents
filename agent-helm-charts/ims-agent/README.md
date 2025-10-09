# IBM IMS Agents

## Overview

The IBM IMS Agents software can answer general IMS command-related questions, such as the format or syntax of commands. The agent can also provide real-time insights into the operational state of IMS systems, which can help accelerate troubleshooting by streamlining diagnostics.

## Agent capabilities

| Agent capability  </br>Shows information about the following components    |            Description                  |            Tool Name                  |
|------------------------------|-----------------------------------|-----------------------------------|
| General IMS Q/A        | Answers general IMS related questions.  | ims_documentation_search </br> ims_performance_search |
| IMS commands | Explains syntax for IMS type-1 and type-2 commands. | get_command_syntax |
| IMS system | Displays region and IMS TM information associated with a configured IMS system. | ims_get_system_info |
| OTMA | Displays the current status for IMS Open Transaction Manager Access (OTMA) clients and servers. It also shows how many active TPIPES exist. | ims_get_otma_info |
| Pool | Displays IMS storage pool utilization statistics. | ims_get_pool_info |
| Transaction | Displays information about transactions for example, if the transaction started or stopped. | ims_get_transaction_info |
| IMS delayed response | Displays all nodes that have been waiting for a response for more than five seconds. | ims_get_delayed_response |
| IMS subsystem | Displays information about an external subsystem such as Db2 or MQ showing if subsystem is active or not. | ims_get_subsys_info |
| IMS DB | Displays the status of the specified database. | ims_get_db_info |
| IMS Connect | Displays the current status and activity of IMS Connect. | ims_get_ims_connect_info |
| Shared queues structure | Displays the status of one or more coupling facility list structures used by IMS for shared queues. | ims_get_shared_queues_structure_info |
| CCTL | Shows information about Coordinator Controllers (CCTLs) like CICS connected to IMS. | ims_get_cctl_info |
| Error status |   Display the current error status of a specified IMS resource. | ims_get_resource_error_status |
| Diagnostic SNAP | Shows diagnostic information. | ims_diag_snap |
| Program information | Displays the status of a program. | ims_get_program_info |
| IMS OLDS | Displays system logging status. | ims_get_olds_info |
| User information | Displays all of the user structures and the user IDs that match the parameter or attribute specified. | ims_get_user_info |


## Check prerequisites

Ensure that the following software is installed:

- [IBM watsonx Assistant for Z](https://www.ibm.com/docs/en/watsonx/waz/2.0.0?topic=install-watsonx-assistant-z)
- IMS 15.5 or later
  -  You will need to order IMS 15.6 from Shopz to get the required entitlement key, but you do not need to install 15.6.
  - In the IMS config requirement ensure 'CMDMCS=B, C, R or Y' in the DFSPBxxx member that is used to start IMS. Additionally, these sources about [mcs-console](https://www.ibm.com/docs/en/ims/15.6.0?topic=commands-using-multiple-console-support-mcs-consoles) and [cmdmcs](https://www.ibm.com/docs/en/ims/15.6.0?topic=parameters-cmdmcs-parameter-procedures) can be used to set up IMS properly. 
- z/OSMF is 3.1 or later

> Optional: Verify image signatures

## Verify Image Signatures (Optional)

You can verify the container image signatures by setting a pull policy for your transport method. You must install `skopeo` to follow the provided examples.

You can verify the signatures for the following manifests:

- `icr.io/ibm-ims-ai/ims-agent:1.0.0`
- `icr.io/ibm-ims-ai/ims-mcp-agent:1.0.0`

Under `ims-agent` directory there is a folder named `imagesign` which contains a file named `public.asc`. Place this file in a location of your choice. Then, copy the following Docker container policy `policy.json` file into the`/etc/containers/policy.json` and update the `keyPath` field to reflect the location of your `public.asc`.

```json
{
  "default": [
    {
      "type": "reject"
    }
  ],
  "transports": {
    "docker": {
      "icr.io": [
        {
          "type": "signedBy",
          "keyType": "GPGKeys",
          "keyPath": "/path/to/public.asc"
        }
      ]
    },
    "docker-daemon": {
      "": [
        {
          "type": "reject"
        }
      ]
    }
  }
}
```

1. Login to `skopeo`.

    ```bash
    echo <PASSWORD_OR_TOKEN> | skopeo login --username <USERNAME> --password-stdin icr.io
    ```

2. Use `skopeo` to copy the image. Make sure the transport method matches the transport that is used in the policy. This example uses `docker`:

    ```bash
    mkdir temp1 temp2
    skopeo copy docker://icr.io/ibm-ims-ai/ims-agent:1.0.0 dir:temp1
    skopeo copy docker://icr.io/ibm-ims-ai/ims-mcp-agent:1.0.0 dir:temp2
    ```

If the image signature is valid and verified by `public.asc` then the image pull will be successful. Otherwise it will fail.

1. Import `public.asc` into your local keyring:

    ```bash
    gpg --import /path/to/public.asc
    ```

2. Extract the fingerprint:

    ```bash
    export FINGERPRINT=$(gpg --fingerprint --with-colons | grep fpr | tr -d 'fpr:')
    ```

3. Validate the signatures:

    ```bash
    skopeo standalone-verify ./temp1/manifest.json icr.io/ibm-ims-ai/ims-agent:1.0.0 $FINGERPRINT ./temp1/signature-1
    ```

    ```bash
    skopeo standalone-verify ./temp2/manifest.json icr.io/ibm-ims-ai/ims-mcp-agent:1.0.0 $FINGERPRINT ./temp2/signature-1
    ```

If the validation is successful, you should see the following message:

```bash
Signature verified using fingerprint...
```

This is followed by the public key's fingerprint and the digest sha of the image. If a failure occurs, you might see this error:

```bash
FATA[0000] Error verifying signature: ...
```

## Install the IBM IMS Agents

### Retrieve the entitlement key

When you install watsonx Assistant for Z, you should have acquired the entitlement key. However, if you need to retrieve it again, follow these steps:

1. Sign in to [IBM Shopz](https://www.ibm.com/software/shopzseries/ShopzSeries_public.wss).
2. Place an order for IMS 15.6 in IBM Shopz to obtain the entitlement key, which is in the PDF document.
3. Set the following product `entitlementKey` field by using the IBM IMS Agents entitlement key.

```yaml
ims-agent:
  enabled: false             # Must be set to true to install. 
  acceptLicense: false       # Must be set to true to install. 
  registry:
    name: ims-image-pull-secret
    server: icr.io
    username: iamapikey
    entitlementKey: ""
```

> Ensure that `global.registry.entitlementKey` is set to the watsonx Assistant for Z entitlement key.

### Create shared variables

Certain variables are common across all agents. To configure these shared variables, see [Create shared variables](https://github.com/IBM/z-ai-agents?tab=readme-ov-file#1-global-settings).
However, if any of these shared variables are also defined in your agent-specific [values.yaml](https://github.com/IBM/z-ai-agents/blob/main/wxa4z-agent-suite/values.yaml) file, the values specified in the values.yaml file will override the shared ones.

### Configure the values.yaml file

To enable the IBM IMS Agents, you need to configure agent-specific values in the [values.yaml](https://github.com/IBM/z-ai-agents/blob/main/wxa4z-agent-suite/values.yaml) file.

In the values.yaml file, scroll down to the ims-agent section and update the keys as outlined in the following table.

| Key       |            Description                  |
|------------------------------|-----------------------------------|
| **Environmentvariables** | |
| ZOSMF_CONSOLE_NAME | Name of the z/OS system console used by z/OSMF (z/OS  Management Facility) to interact with IMS. |
| IMS_SUBSYSTEM_ID | IMS subsystem instance ID. |
| IMS_CONNECT_JOBNAME | Specifies the job name of IMS Connect. |
| APPL_ID | Application ID. |

| Key       |            Description                  |
|------------------------------|-----------------------------------|
| **MCP secrets** | |
| ZOSMF_ENDPOINT | The base URL for the z/OS Management Facility (z/OSMF), provided by IBM for managing and interacting with z/OS systems, for example: `https://your.zos.system.com`. |
| SERVICE_ENDPOINT | Defines the URL or network address where z/OSMF services are exposed. This endpoint should match the ZOSMF_ENDPOINT but use a different port where mTLS authentication is set, for example `https://your.zos.system.com:5443`. |
| AGENT_AUTH_TOKEN | Authentication token for the agent. |

Additionally, you can update the `mcpCertSecret` section of the `values.yaml` file before running the helm-install command. For more information, see the section Configuring your z/OSMF certificate for the MCP container image.

| Key       |            Description                  |
|------------------------------|-----------------------------------|
| **Secrets** | |
| AGENT_AUTH_TOKEN | Authentication token for the agent. |
| WRAPPER_USERNAME | User name for accessing the WRAPPER_URL endpoint. |
| WRAPPER_PASSWORD | Password for accessing the WRAPPER_URL endpoint. |
| WRAPPER_URL | The OpenSearch URL. |

> [View information about how to get OpenSearch wrapper](https://www.ibm.com/docs/en/watsonx/waz/2.0.0?topic=cluster-acquiring-zassistantdeploy-endpoint-retrieving-user-credentials)​

### Additional steps for the Q/A container image (ims-agent:1.0.0)

#### Ensure OpenSearch Is Deployed to Your Cluster

The general IMS Q/A agent relies on an instance of an OpenSearch vector database. If OpenSearch is not already deployed to your cluster, [follow instructions on how to deploy an instance.](https://www.ibm.com/docs/en/watsonx/waz/3.0.0?topic=cluster-deploying-zassistantdeploy-your)

#### Configure local embeddings

The general Q/A agent can use local embedding models for specific operations. The image references two available models:

- `ibm-granite/granite-embedding-278m-multilingual`
- `ibm-granite/granite-embedding-107m-multilingual`

You can explicitly select which model to use by adding and setting the `LOCAL_EMBEDDING_MODEL` environment variable to one of the options above. If this variable is not set, the system defaults to `ibm-granite/granite-embedding-278m-multilingual`. While the default, 278 million parameter model may offer enhanced performance, it could result in longer processing times depending on your cluster's allotted resources.

### Additional steps for the MCP container image (ims-mcp-agent:1.0.0)

#### Ensure the Authorization Service is Deployed to Your Cluster

Various MCP tools rely on the authorization service in order to communicate with your z/OS system. If the authorization service has not yet been deployed to your cluster, [follow instructions to deploy it.](https://www.ibm.com/docs/en/watsonx/waz/3.0.0?topic=cluster-deploying-zassistantdeploy-your) Additionally, [follow instructions to enable pass-ticket generation](https://www.ibm.com/docs/en/watsonx/waz/3.0.0?topic=deploying-token-exchange-service-passticket-generation) for a specified APPL ID.

#### Configuring your z/OSMF certificate for the MCP container image

Currently, all MCP tools rely on z/OSMF to communicate with your z/OS system. Please note that z/OSMF console setup is required. A valid certificate is also required for secure, TLS communication.

To setup a z/OS Operator Console, [follow these instructions](https://www.ibm.com/docs/en/zos/latest?topic=consoles-completing-console-setup#zuCNhpOperatorConsolesSettingUp). To allow a specified TSO/E user to issue the CONSOLE commands, [follow these instructions](https://www.ibm.com/docs/en/zos/2.4.0?topic=racf-allowing-tsoe-user-issue-console-command) or run the following command with a given user e.g. `USRT001`:

```jcl
SETROPTS CLASSACT(TSOAUTH)
RDEFINE TSOAUTH CONOPER UACC(NONE)
PERMIT CONOPER CLASS(TSOAUTH) ID(USRT001) ACCESS(ALTER)
SETROPTS RACLIST(TSOAUTH) REFRESH
```

To create a certificate, run the following JCL within a JOB on your system:

```jcl
//SYSTSIN  DD  *                                          
  RACDCERT GENCERT ID(IZUSVR) +                           
    SUBJECTSDN( CN('your.zos.system.com') +          
    O('IBM') OU('IZUDFLT') )+                             
    ALTNAME( DOMAIN('your.zos.system.com') ) +       
    NOTAFTER(DATE(2030-12-31)) +                          
    WITHLABEL('DefaultzOSMFCert.SAN') +                   
    KEYUSAGE(HANDSHAKE DATAENCRYPT CERTSIGN)

  RACDCERT ID(IZUSVR) CONNECT( LABEL('DefaultzOSMFCert.SAN') +   
                                   RING(IZUKeyring.IZUDFLT) DEFAULT ) 
/*
```

The CN and SAN domain (your.zos.system.com in this example) must exactly match the hostname used in your `ZOSMF_ENDPOINT` environment variable.

> The above JCL assumes the APPL ID is `IZUDFLT`. You may need to stop and restart z/OSMF for changes to take effect i.e. `/P IZUSVR1` and `/S IZUSVR1`. Modify as needed.

You can then save the certificate information to a file by using the following commands:

```bash
export SITE="your.zos.system.com"

openssl s_client -connect ${SITE}:443 -servername ${SITE} -showcerts </dev/null \
 | awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/{print $0}' > ${SITE}_full_chain.pem
```

After deployment, an opaque secret named `service-endpoint-cert-secret` (with a placeholder certificate value) is automatically created and mounted to the `ims-mcp-agent` container. You must update the value of this secret to reflect the value of the certificate that you just created. Either update the secret in the `mcpCertSecret` section of the `values.yaml` file before running the helm-install command, or manually update the secret after deployment. 

Important: If you choose to update the `values.yaml` file, remember to never store or commit secrets to git.

To manually update the secret after deployment, you can use a graphical user interface, such as the OpenShift® console, or you can use the OpenShift® CLI patch command after logging in:

```bash
oc patch secret service-endpoint-cert-secret -p '{"data":{"service_endpoint_cert.pem":"'$(cat ${SITE}_full_chain.pem | base64)'"}}'
```

To apply any changes to the secret, remember to restart the pod.

### Install or upgrade the ims-agent using the wxa4z-agent-suite

> **Tip**: If you're installing multiple agents, you can configure the [values.yaml](https://github.com/IBM/z-ai-agents/blob/main/wxa4z-agent-suite/values.yaml) file for all the agents that you want to install. After the file is updated, run the following command to install them all at the same time.

Use the following command to install or upgrade the agent using the wxa4z_agent_suite:

```yaml
helm upgrade --install wxa4z-agent-suite \
  ./wxa4z-agent-suite \
  -n <wxa4z-namespace> \
  -f <path_to>/values.yaml --wait
```

## Deploy the agent

1. Log in to watsonx Orchestrate.
2. From the main menu, navigate to **Build** > **Agent Builder**.
3. Select the **IBM IMS Agents** tile.
4. In the AI Assistant window, enter a query to confirm that the response aligns with your expectations.
5. Click **Deploy** to activate the agent and make it available in the live environment.

## Test your agent

After deployment, the agent becomes active and is available for selection in the live environment.

1. Log in to watsonx Orchestrate.
2. From the main menu, click **Chat**.
3. Choose your agent from the list.
4. Enter queries using the AI Assistant, for example:

    ```text
    What is IMS TM?

    What is the IMS type-1 command to show status of a transaction named xxx?

    Show me the status of my IMS system.
    ```

5. Verify that the responses returned by the AI Assistant are accurate.


## Troubleshooting installation errors

If you run into any errors during installation, see [Troubleshooting](../../README.md#troubleshooting) for troubleshooting steps.


## Uninstalling the agent

For uninstallation instructions, see [Uninstall specific agent](../../README.md#uninstall-specific-agent).


------------------------------------------------------------
