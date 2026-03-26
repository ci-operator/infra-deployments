#!/bin/bash -e

main() {
    local token=${1:?"Pull token was not provided"}
    local registry="quay.io"
    local robot_user="rekonflux+pullbot"

    echo "Adding trace-demo pull credentials to global pull secret"
    auth=$(mktemp)
    oc get secret/pull-secret -n openshift-config --template='{{index .data ".dockerconfigjson" | base64decode}}' > "$auth"
    oc registry login --registry="$registry" --auth-basic="${robot_user}:${token}" --to="$auth"
    oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson="$auth"
    rm "$auth"
    echo "Done — nodes will pick up the new credentials on next image pull"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
