#!/bin/bash -e

main() {
    local token=${1:?"Pull token was not provided"}
    local namespace="openshift-pipelines"
    local secret_name="trace-demo-pull-secret"
    local registry="quay.io"
    local robot_user="rekonflux+pullbot"

    echo "Creating pull secret '$secret_name' in namespace '$namespace'"

    oc create secret docker-registry "$secret_name" \
        --docker-server="$registry" \
        --docker-username="$robot_user" \
        --docker-password="$token" \
        --namespace="$namespace" \
        -o yaml --dry-run=client | oc apply -f -

    for sa in pipelines-as-code-controller pipelines-as-code-watcher pipelines-as-code-webhook; do
        echo "Linking secret to service account '$sa'"
        oc secrets link "$sa" "$secret_name" --for=pull --namespace="$namespace"
    done

    echo "Done"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
