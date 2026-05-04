# IBM Z Support Agent

## Overview
The IBM Z Support Agent enables users to execute Ansible playbooks through the Watson Assistant for Z chat interface.

## Agent capabilities

| Agent capability         |            Description                  |
|------------------------------|-----------------------------------|
| Take z/OS dump        | Collect dump on a z/OS address space    |
| Send z/OS dump | Transfer the dump collected on z/OS address space |
| Retrieve job status | Retrieve the launched ansible job status and logs |



## Prerequisites
Ensure the following:

- [watsonx Assistant for Z](https://www.ibm.com/docs/watsonx/waz/3.2.0?topic=install-premises-watsonx-orchestrate-watsonx-assistant-z) is installed
- Ansible Automation Platform instance and its credentials



## Install the IBM Z Support Agent

### Create Shared Variables

Certain variables are common across all agents. To configure these shared variables, refer to [Create shared variables](https://github.com/IBM/z-ai-agents/blob/main/README.md#1-global-settings) (link to the global GitHub page).
However, if any of these shared variables are also defined in your agent-specific [values.yaml](https://github.com/IBM/z-ai-agents/blob/main/wxa4z-agent-suite/values.yaml) file, the values specified in the values.yaml file will override the shared ones.

### Configure the values.yaml file

To enable the IBM Z Support Agent, you need to configure agent-specific values in the [values.yaml](https://github.com/IBM/z-ai-agents/blob/main/wxa4z-agent-suite/values.yaml) file.

In the values.yaml file, scroll down to the Support Agent section and update the keys as outlined in the following table.

| Key       |            Description                  |
|------------------------------|-----------------------------------|
**Environment variables**                                                        |
WATSONX_MODEL_ID | LLM Model Used by the Agent. For example, "meta-llama/llama-3-70b-instruct".
TAKE_DUMP_JOB_TEMPLATE | Template name of take dump ansible job 
SEND_DUMP_JOB_TEMPLATE | Template name of send dump anisble job
**Secrets**
AAP_ENDPOINT | Base URL of your AAP instance for the tls-agent
AAP_USERNAME | Username credential for accessing the AAP API
AAP_PASSWORD | Password credential for accessing the AAP API
SEND_DUMP_TRANSFER_ID | Transfer ID for required send dump job
SEND_DUMP_TRANSFER_PASSWORD | Transfer password required for send dump job
AGENT_AUTH_TOKEN | Authentication token for the agent.



### Install or upgrade the wxa4z-agent-suite

> **Note**:- If you're installing multiple agents, you can configure the [values.yaml](https://github.com/IBM/z-ai-agents/blob/main/wxa4z-agent-suite/values.yaml) file for all the agents you wish to install. Once the file is updated, run the command below to install them all at once.


Use the following command to install or upgrade the wxa4z_agent_suite:

```yaml
helm upgrade --install wxa4z-agent-suite \
  ./wxa4z-agent-suite \
  -n <wxa4z-namespace> \
  -f <path_to>/values.yaml --wait
```

## Set up Ansible Automation Platform (AAP)

> **Note**:- Before setting up AAP it is advised that you have the playbooks in Git or another support source control type.

### Inventory Configuration
1. Create a new inventory
2. Give it a name, organization, and a description if desired
3. In the variables section enter the following:
```
environment_vars:
  _BPXK_AUTOCVT: 'ON'
  ZOAU_HOME: '{{ ZOAU }}'
  PYTHONPATH: ''
  PYTHONSTDINENCODING: cp1047
  LIBPATH: '{{ ZOAU }}/lib:{{ PYZ }}/lib:/lib:/usr/lib:.'
  PATH: '{{ ZOAU }}/bin:{{ PYZ }}/bin:/bin:/var/bin'
  _CEE_RUNOPTS: FILETAG(AUTOCVT,AUTOTAG) POSIX(ON)
  _TAG_REDIR_ERR: txt
  _TAG_REDIR_IN: txt
  _TAG_REDIR_OUT: txt
  LANG: C
```
4. Save the newly created inventory

### Host Confiuration
A host is where you configure system specific information.
1. Create a new host
2. Give it a name, assign it to the newly created inventory, and add a description if desired
3. In the variables section enter the following:
```
ansible_host: IP Address of the LPAR (xx.xx.xx.xx)
ansible_user: user that will perform the actions on the LPAR
ansible_python_interpreter: /path/to/your/pyz/bin/python
PYZ: /path/to/your/pyz
PYZ_VERSION: '3.xx'
ZOAU: /path/to/your/zoau/folder
ZOAU_PYTHON_LIBRARY_PATH: ''
```

### Creating Credentials
Credentials allow AAP to reach the LPAR and GitHub. We will need to make two.

#### Credential for GitHub
1. Create a new credential
2. Give it a name and description
3. For Credential type choose **Source Control**
4. Paste the contents of the SSH Private key into the proper field, along with any other relevant information
    - Ensure the public key is entered in GitHub
5. Save the newly created credential

#### Credential for LPAR
1. Create a new credential
2. Give it a name and description
3. For Credential type choose **Machine**
4. Paste the contents of an SSH Private key that has its public pair added to the LPAR into the proper field, along with any other relevant information
5. Save the newly created credential

### Creating a project
1. Create a new project
2. Give it a name and description
3. Choose an execution environment
4. For Source Control, choose **Git** if your playbooks are stored there
5. Enter the URL of your repository and branch if necessary
6. Choose the newly created credential
7. Save the newly created project

### Creating job templates
Job templates are used to run the playbooks
1. Create a new job template
2. Give it a name and description
3. Choose the inventory that was created earlier
4. Choose the project that was created earlier
5. Select one of the playbooks from the list in the **Playbook** dropdown
6. Save the newly create job template
7. Repeat steps 1-6 for the other playbook

### Testing the job templates
The newly created job templates can use survey questions to get input information
1. Click on a job template
2. Go to the **Survey** tab
3. Enter create new survey questions with the following based on which playbook job template you are editing:
    - For the template to collect a dump:
    ```
    Question: Please enter the title of the dump
    Answer variable name: dump_title
    Answer Type: Text

    Question: Please enter the jobname(s) to be include in the dump
    Answer variable name: jobname
    Answer Type: Text

    Question: Please enter the SDATA parameters
    Answer variable name: sdata
    Answer Type: Text
    Default answer: (ALLNUC,CSA,GRSQ,LPA,LSQA,PSA,RGN,SQA,SUM,SWA,TRT)

    Question: Please enter the name of the dataset to copy the dump into
    Answer variable name: copy_ds_name
    Answer Type: Text
    ```
    - For the template to upload documentation:
    ```
    Question: Please enter your transfer ID
    Answer variable name: transfer_id
    Answer Type: Text

    Question: Please enter your transfer password
    Answer variable name: transfer_pw
    Answer Type: Password

    Question: Please enter the dataset to send
    Answer variable name: ds_to_send
    Answer Type: Text

    Question: Please enter the case number to submit the dataset to
    Answer variable name: case_num
    Answer Type: Text
    ```
4. After entering the questions enable the survey on the Survey tab
5. You can now run the templates and you will be prompted with the quesstions

## Deploy the agent

1. Log in to watsonx Orchestrate.
2. From the main menu, navigate to **Build** > **Agent Builder**.
3. Select the **IBM Z Support Agent** tile.
4. In the AI Assistant window, enter a query to confirm that the response aligns with your expectations.
5. Click **Deploy** to activate the agent and make it available in the live environment.


## Test the agent

After deployment, the agent becomes active and is available for selection in the live environment.

1. From the main menu, click **Chat**.
2. Choose your agent from the list.
3. Enter your queries using the AI Assistant.
   For example:
   
      - Can you take dump of z/os?

    Responses are displayed either in a tabular format or as a sentence, depending on the context.

4. Verify that the responses returned by the AI Assistant are accurate.


## Troubleshooting installation errors

If you run into any errors during installation, see [wxa4z-agent-suite installation guide](https://github.ibm.com/wxa4z/agent-deployment-charts/tree/support_agent-readme-update/agent-helm-charts/support-agent) for troubleshooting steps.

## Uninstalling the agent
For uninstallation instructions, see [wxa4z-agent-suite installation guide](https://github.ibm.com/wxa4z/agent-deployment-charts/tree/support_agent-readme-update/agent-helm-charts/support-agent)

------------------------------------------------------------