AAP OPA Policies
=======

A repository of OPA Policies to be used within Ansible Automation Platform  

*** This document does not cover the installation or configuration of OPA. ***

Requirements
------------

- An OPA server configured with an "aap" folder for AAP policy checks
- **AAP 2.6-9 or higher*** and configured to use OPA
- Service Account or local user with auditor privileges

Policies
------------

##### main.rego
- Loads your AAP specific policies for checking

##### fqdn.rego
- Ensures < 10000 hosts exist in inventory
- Ensures inventory hostname is RFC 1123 and RFC 921 compliant.
- Should be set at the organization level but can be done globally

Installation
------------
```text
Recommended OPA folder structure
|-- policies/
    |-- secrets.json
    |-- aap/
        |-- main.rego
        |-- fqdn.rego
        |__ foo.rego

```
1. Create your aap folder structure in your OPA policies folder
2. Create a service account user in AAP with "Auditor" access
3. Create a token for the service account
4. Create your secrets.json with the token that was created
  - File should be only user read/write (chmod 600)
  - File should be in at the root level of the OPA policy folder
6. Modify the base_url variable in the fqdn.rego file with the your AAP url
7. Modify the max_hosts variable in the fqdn.rego file with the max amount of hosts allowed in a single inventory

AAP Configuration
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


#### Process
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
