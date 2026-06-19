AAP OPA Policies
=======

OPA Policy-as-Code guardrails for Ansible Automation Platform.
> ⚠️ **Note:** This document does not cover the installation or configuration of the underlying OPA server.

Requirements
------------

| Component | Minimum Requirement | Notes / Configuration |
| :--- | :--- | :--- |
| **Open Policy Agent (OPA)** | Version `1.17.1` or higher | Must be running as an accessible endpoint or sidecar. |
| **OPA Directory Structure** | Subdirectory: `<root_policy_directory>/aap/` | Must be created inside the root policy folder to house your Rego files. |
| **Ansible Automation Platform** | `>= 2.6-9` | OPA Integration must enabled under settings. |
| **AAP Authentication** | Service Account / Local User | Requires **Auditor** privileges to read execution data. |


Adjustable Variables
------------
| Variable Name | Default | Notes / Configuration |
| :--- | :--- | :--- |
| max_hosts | 10000 | Max amount of hosts allowed in an individual inventory |
| base_url | "https://REPLACE_WITH_YOUR_AAP_MAIN_URL/api/controller/v2" | AAP url to connect for dynamic queries |
| token | data.secrets.aap_controller_bearer_token | See secrets.json |


Policies
------------

##### main.rego
- Loads your AAP specific policies for checking

##### fqdn.rego
- Ensures a defined max of hosts allowed in an inventory (default 10k)
- Ensures inventory hostname is RFC 1123 and RFC 921 compliant.
- Should be set at the organization level but can be done globally

Installation
------------
> ⚠️ **Note:** This document does not cover troubleshooing of OPA rego files. Validate your content before publishing.

```text
Recommended OPA folder structure
|-- policies/
    |-- secrets.json
    |-- aap/
        |-- main.rego
        |-- fqdn.rego
        |__ foo.rego

```
#### On OPA Server
1. Create your aap folder structure in your OPA policies folder

#### In AAP 
2. Create a service account user in AAP with "Auditor" permissions.
3. Generate a Personal Access token for that service account

#### On OPA Server
##### secrets.json
4. Create your *secrets.json* with the token that was created. Refer to the [example](secrets.json) file provided.
  - File should be only user read/write (chmod 600)  
  - File should be place at the root policy directory <root_policy_dir>/secrets.json   
#### On your local machine
5. Modify the base_url variable in the fqdn.rego file with the your AAP url
6. Modify the max_hosts variable in the fqdn.rego file with the max amount of hosts allowed in a single inventory
7. Publish your modified fqdn.rego file to the `<root_policy_directory>/aap` folder of the OPA server
** 



Configure Policy Enforcement in AAP 
------------
#### Broad Policy Enforcement
In AAP, **Policy enforcement** can be set in various ways. For our use case, we are setting all of our policies (current and future) at the organization level.  Keep this in mind if a policy is set at the org level and contradicts your desired goals.
1. Access Management > Organizations > Select Organization > Edit organization
2. In the `Policy Enforcement` field, enter the following:  
*** EXAMPLE: ***
````
aap.main/evaluate
````
#### Specific Policy Enforcement
If you're looking to do a specfic policy at the Org or lower level, this can be done in a more granular manner.  
1. Access Management > Organizations > Select Organization > Edit organization
2. In the `Policy Enforcement` field, enter the following:  
*** EXAMPLE: ***
````
aap.fqdn/check
````

#### How it works
When an action in AAP is excuted that has a policy associated with it:
1.  The "evaluate" function of the main.rego file is processed. 
2. The evaluate fuction calls all remaining rego files that have a "check" function.    
3. Violations trigger if found and execution of actions are prevented.

*Note: We use "check" as a standard function name with all of our rego files*

License
------------
MIT

Author Information
------------------

Randy Romero  
<binbashroot@gmail.com>
