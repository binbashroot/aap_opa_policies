package aap.main
import rego.v1

# Dynamically gather all 'check' rules from all packages under 'aap'
all_violations := v if {
    # This gathers the 'check' object from every package in 'aap'
    # excluding the 'main' package itself to avoid circular loops
    v := [violation |
        some pkg_name
        pkg_name != "main"
        check_result := data.aap[pkg_name].check
        violation := check_result.violations[_]
    ]
} else := []

evaluate := {
    "allowed": count(all_violations) == 0,
    "violations": all_violations
}
