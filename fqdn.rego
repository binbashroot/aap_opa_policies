package aap.fqdn

import rego.v1

# Configuration
# Adjustable variables
max_hosts := 10000
base_url := "https://REPLACE_WITH_YOUR_AAP_MAIN_URL/api/controller/v2"
# Note:
# "aap_controller_bearer_token" matches the key name
# from the secrets.json file for the token variable below 
token := data.secrets.aap_controller_bearer_token

# Static variables
# Do not modify
auth_header := sprintf("Bearer %v", [token])
fqdn_regex := `^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,63}$`

# Helper: Regex match checks
valid_hostname(h) if h == "localhost"
valid_hostname(h) if regex.match(fqdn_regex, h)

# 1. Fetch hosts (Single call, max_hosts var sets page_size)
# We pull the metadata to check the count and the host list in one go
api_response := response if {
    input.inventory.id != null

    url := sprintf("%v/inventories/%v/hosts/?page_size=%v", [
          base_url,
          input.inventory.id,
          max_hosts,
        ])

    response := http.send({
        "method": "GET",
        "url": url,
        "tls_insecure_skip_verify": true,
        "headers": {
            "Authorization": auth_header,
            "Content-Type": "application/json"
        }
    })
    response.status_code == 200
}

# 2. Evaluation Rules
violations contains msg if {
    # Check if the total count in AAP exceeds the limit
    api_response.body.count > max_hosts
    msg := sprintf(
           "CRITICAL: Inventory '%v' exceeds the host limit. Found %v hosts (Max: %v).", 
            [
              input.inventory.id,
              api_response.body.count,
              max_hosts,
            ])
}

violations contains msg if {
    some host in api_response.body.results
    not valid_hostname(host.name)
    regex.match(`^(\d{1,3}\.){3}\d{1,3}$`, host.name)
    msg := sprintf("Inventory contains IP address '%v' — must be an FQDN", [host.name])
}

violations contains msg if {
    some host in api_response.body.results
    not valid_hostname(host.name)
    not regex.match(`^(\d{1,3}\.){3}\d{1,3}$`, host.name)
    msg := sprintf("Inventory contains invalid FQDN '%v'", [host.name])
}

# 3. Decision Mapping
default check := {
    "allowed": true,
    "violations": []
}

check:= {
    "allowed": false,
    "violations": violations
} if {
    count(violations) > 0
}
