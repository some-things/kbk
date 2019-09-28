#!/usr/bin/env bash

set -o errexit

USER_TICKETS_DIR="${KBK_TICKETS_DIR:-${HOME}/Documents/logs/tickets}"

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

mainHelp() {
  cat <<EOF
kbk - a simple command line tool for parsing files contained within Kubernetes diagnostic bundles.

 Find more information at: https://github.com/some-things/kbk

Commands:
  extract        Extracts a compressed bundles to a specified directory
  checks         Run checks against a bundle to find errors, misconfigurations and more
  logs           Display the logs for a container in a pod
  up             Create a kbk cluster for a bundle
  down           Destroy a kbk cluster for a bundle
  kubeconfig     Display the kubeconfig files for kbk clusters
  status         Display cluster info
EOF
}

extractHelp() {
  cat <<EOF
Extracts a compressed bundles to a specified directory.
usage: kbk extract <bundle-name>.tar.gz [options]
  Options:
  --help          - Display this help

EOF
}

checksHelp() {
  cat <<EOF
Run checks against a bundle to find errors, misconfigurations and more.
usage: kbk checks [options]
  Options:
  --help          - Display this help

EOF
}

logsHelp() {
  cat <<EOF
Display the logs for a container in a pod.
usage: kbk logs <pod-namespace> <pod-name> [options]
  Options:
  --help          - Display this help

EOF
}

kubeconfigHelp() {
  cat <<EOF
Display the kubeconfig file for the current kbk cluster.
usage: kbk kubeconfig [options]
  Options:
  --help          - Display this help

EOF
}

upHelp() {
  cat <<EOF
Deploy a cluster to analyze bundle resources.
usage: kbk up [options]
  Options:
  --force         - Force overwrite of current cluster state
  --help          - Display this help

EOF
}

downHelp() {
  cat <<EOF
Destroy the current managed cluster.
usage: kbk down [options]
  Options:
  --help          - Display this help

EOF
}

statusHelp() {
  cat <<EOF
Display the status of the current managed cluster.
usage: kbk status [options]
  Options:
  --help          - Display this help

EOF
}

extract()  {
  # Bring this in line with other functions
  extractBundle "$@"
}

extractBundle() {
  if [[ -n "${2}" ]]; then
    read -r -p "Ticket number: " TICKET_NUM
    BUNDLE_DIR="${USER_TICKETS_DIR}/${TICKET_NUM}/bundle-${2%%.tar.gz}"
    mkdir -p "${BUNDLE_DIR}"
    echo "Extracting bundle to ${BUNDLE_DIR}..."
    tar -xf "${2}" -C "${BUNDLE_DIR}"
    if [ -n "$(ls -A "${BUNDLE_DIR}/bundles/" 2> /dev/null)" ]; then
      mv "${BUNDLE_DIR}/bundles/"* "${BUNDLE_DIR}"
      rm -r "${BUNDLE_DIR}/bundles/"
      echo "Extracting nodes..."
      find "${BUNDLE_DIR}" -name '*.tar.gz' -exec sh -c 'node_dir="${1%%.tar.gz}"; mkdir "${node_dir}" 2> /dev/null; tar -xvzf "$1" -C "${node_dir}" 2> /dev/null && rm -r "$1"' sh "{}" \;
    fi
    echo "Finished extracting bundle to ${BUNDLE_DIR}"
    exit 0
  else
    echo "Please specify a compressed Konvoy diagnostic bundle file to extract."
    exit 1
  fi
}

preflightBundle() {
  #####
  # Bundle root pre-flight checks
  #####
  if [[ -n $KBK_BUNDLE_DIR ]] || [[ $(pwd | cut -d '/' -f "$(pwd | awk -F \| 'BEGIN {FS = "/"}; NR==1 {for (i=1;i<=NF;i++) if ($i ~/^bundle-/) print i}')" 2> /dev/null) == "bundle-"* ]]; then
    if [[ $(pwd | cut -d '/' -f "$(pwd | awk -F \| 'BEGIN {FS = "/"}; NR==1 {for (i=1;i<=NF;i++) if ($i ~/^bundle-/) print i}')" 2> /dev/null) == "bundle-"* ]]; then
      BUNDLE_ROOT="$(pwd | cut -d '/' -f -"$(pwd | awk -F \| 'BEGIN {FS = "/"}; NR==1 {for (i=1;i<=NF;i++) if ($i ~/^bundle-/) print i}')")"
    elif [[ -n $KBK_BUNDLE_DIR ]]; then
      BUNDLE_ROOT=$KBK_BUNDLE_DIR
      echo "Bundle root from KBK_BUNDLE_DIR ENV: ${KBK_BUNDLE_DIR}"
    fi

    API_RESOURCES_DIR=$(find "${BUNDLE_ROOT}" -name '*api-resources*' -type d)
    POD_LOGS_DIR=$(find "${BUNDLE_ROOT}" -name 'pods_logs' -type d)
    
    if [[ -z $API_RESOURCES_DIR ]]; then
      echo "Could not locate an 'api-resources' directory within the bundle root. This will limit functionality."
    fi
    if [[ -z $POD_LOGS_DIR ]]; then
      echo "Could not locate an 'pods_logs' directory within the bundle root. This will limit functionality."
    fi
  else
    echo "Could not find the bundle root directory and KBK_BUNDLE_DIR is unset. Please navigate to a bundle or set KBK_BUNDLE_DIR to the full path to the bundle root."
    exit 1
  fi
}

logs() {
  declare -a otherargs

  while [ -n "${1}" ]; do
    arg="${1}"
    shift
    case "$arg" in
    --help | -h)
      logsHelp
      exit 0
      ;;
    -*)
      echo "Unrecognized argument: $arg" 1>&2
      logsHelp
      exit 1
      ;;
    *)
      otherargs+=("$arg")
      ;;
    esac
  done

  viewPodLogs "${otherargs[@]}"
}

viewPodLogs() {
  preflightBundle

  POD_LOG="$(find "${POD_LOGS_DIR}" -name '*.log' -type f -exec basename "{}" \; | sed -e 's/.log$//;s/_/ /g' | awk '($1 == "'"${2}"'" && $2 == "'"${3}"'") {print $1"_"$2".log"}')"

  if [[ -n $POD_LOG ]]; then
    less "${POD_LOGS_DIR}/${POD_LOG}"
  else
    printf "Could not find pod logs for pod \"%s\" in \"%s\" namespace.\n" "${3}" "${2}"
    exit 1
  fi
}

preflightCluster() {
  # k3d
  if ! command -v k3d >/dev/null 2>&1; then
    echo "${RED}Unable to find k3d in path. Please install k3d to continue.${RESET}"
    exit 1
  fi

  # yq
  if ! command -v yq >/dev/null 2>&1; then
    echo "${RED}Unable to find yq in path. Please install yq to continue.${RESET}"
    exit 1
  fi

  # k3d docker functionality
  if ! k3d check-tools >/dev/null 2>&1; then
    echo "${RED}Docker check failed. Is Docker running?${RESET}"
    exit 1
  fi

  # sqlite3 cli
  if ! command -v sqlite3 >/dev/null 2>&1; then
    echo "${RED}SQLite3 check failed. Please install the sqlite3 CLI to continue.${RESET}"
    exit 1
  fi

  # state dir
  if [ ! -d "${HOME}/.kbk" ]; then
    if ! mkdir -p "${HOME}/.kbk" >/dev/null 2>&1; then
      echo "${RED}Unable to create directory: ${HOME}/.kbk${RESET}"
      exit 1
    fi
  fi

  # state file
  if [ ! -f "${HOME}/.kbk/state.json" ]; then
    if ! touch "${HOME}/.kbk/state.json" >/dev/null 2>&1; then
      echo "${RED}Unable to create file: ${HOME}/.kbk/state.json${RESET}"
      exit 1
    fi
  fi

  STATE_FILE="${HOME}/.kbk/state.json"
  CLUSTER_NAME="$(jq -r '.clusterName' "${STATE_FILE}")"

  #  k3d list | grep -i kbk-k3d-cluster-cb67e0ce | awk 'BEGIN {FS="|"}; {print$4}'
  # May want to filter this better
  if [[ $(k3d list 2>/dev/null | grep -i "${CLUSTER_NAME}") == *"running"* && ("${CLUSTER_NAME}" != "") ]]; then
    CLUSTER_STATUS="running"
  # elif [[ "${CLUSTER_NAME}" == "" ]]; then
  #     CLUSTER_STATUS="deleted"
  elif [[ ($(k3d list 2>/dev/null | grep -i "${CLUSTER_NAME}") == *"${CLUSTER_NAME}"*) && ("${CLUSTER_NAME}" != "") ]]; then
    CLUSTER_STATUS="unavailable"
  else
    CLUSTER_STATUS="deleted"
  fi
}

kubeconfig() {
  declare -a otherargs

  while [ -n "${1}" ]; do
    arg="${1}"
    shift
    case "$arg" in
    --help | -h)
      kubeconfigHelp
      exit 0
      ;;
    -*)
      echo "Unrecognized argument: $arg" 1>&2
      kubeconfigHelp
      exit 1
      ;;
    *)
      otherargs+=("$arg")
      ;;
    esac
  done

  preflightCluster
  getKubeconfig
}

getKubeconfig() {
  printf "Current KUBECONFIG file: %s\n" "$(jq -r '.kubeconfigFile' "${STATE_FILE}")"
  printf "For cluster access:\n"
  printf "export KUBECONFIG=\"%s\"\n" "$(jq -r '.kubeconfigFile' "${STATE_FILE}")"
}

preflightUp() {
  declare -a otherargs

  while [ -n "${1}" ]; do
    arg="${1}"
    shift
    case "$arg" in
    --help | -h)
      upHelp
      exit 0
      ;;
    --force | -f)
      echo "Forcing overwrite of the cluster state!"
      FORCE=1
      ;;
    -*)
      echo "Unrecognized argument: $arg" 1>&2
      upHelp
      exit 1
      ;;
    *)
      otherargs+=("$arg")
      ;;
    esac
  done

  preflightCluster
  preflightBundle
}

preflightDown() {
  declare -a otherargs

  while [ -n "${1}" ]; do
    arg="${1}"
    shift
    case "$arg" in
    --help | -h)
      downHelp
      exit 0
      ;;
    -*)
      echo "Unrecognized argument: $arg" 1>&2
      downHelp
      exit 1
      ;;
    *)
      otherargs+=("$arg")
      ;;
    esac
  done

  preflightCluster
}

createCluster() {
  CLUSTER_NAME="${KB_CLUSTER_NAME:-kbk-cluster-$(date | md5sum | head -c8)}"

  if [[ $FORCE == 1 ]]; then
    k3d delete --name "${CLUSTER_NAME}"
  fi

  # Add (?):
  # - Version?
  # - Maybe want to set cluster-cidr from what's detected in the bundle?

  k3d create \
    --name "${CLUSTER_NAME}" \
    --workers 0 \
    --volume "${API_RESOURCES_DIR}/.kbk/db:/var/lib/rancher/k3s/server/db/" \
    --server-arg --disable-agent \
    --server-arg --no-deploy=coredns \
    --server-arg --no-deploy=servicelb \
    --server-arg --no-deploy=traefik \
    --server-arg --kube-apiserver-arg=event-ttl=168h0m0s \
    --server-arg --kube-controller-arg=disable-attach-detach-reconcile-sync \
    --server-arg --kube-controller-arg=controllers=-attachdetach,-clusterrole-aggregation,-cronjob,-csrapproving,-csrcleaner,-csrsigning,-daemonset,-deployment,-disruption,-endpoint,-garbagecollector,-horizontalpodautoscaling,-job,-namespace,-nodeipam,-nodelifecycle,-persistentvolume-binder,-persistentvolume-expander,-podgc,-pv-protection,-pvc-protection,-replicaset,-replicationcontroller,-resourcequota,-root-ca-cert-publisher,-serviceaccount,-serviceaccount-token,-statefulset,-ttl

  # May want to write the kubeconfig file differently
  cat <<EOF >"${STATE_FILE}"
{
    "clusterName": "${CLUSTER_NAME}",
    "bundleRoot": "${BUNDLE_ROOT}",
    "dataDirectory": "${API_RESOURCES_DIR}/.kbk",
    "datebaseFile": "${API_RESOURCES_DIR}/.kbk/db/state.db",
    "kubeconfigFile": "${HOME}/.config/k3d/${CLUSTER_NAME}/kubeconfig.yaml",
    "lastUpdated": "$(date +%FT%TZ)"
}
EOF

  # Add 'until' kubectl responds with response indicating cluster is up (with a timeout)
  sleep 5

  echo "${GREEN}Stopping cluster to write to database.${RESET}"

  k3d stop --name "${CLUSTER_NAME}"

  ###
  # Begin resources section
  ###
  # Issues
  # - componentstatuses doesn't report correctly - add a 'check' to parse this file

  # Set a base resource ID to something [hopefully] out of the range of current cluster resources to avoid conflicts
  RESOURCE_ID=100000000

  API_RESOURCE_FILES="$(basename -a -- "${API_RESOURCES_DIR}/"*".yaml" | grep -vi 'secrets.yaml')"


  for file in $API_RESOURCE_FILES; do
    API_RESOURCE_NAME="$(basename -a $file | cut -d '.' -f1 | sed 's/^nodes$/minions/g;s/^endpoints$/services\/endpoints/g;s/^services$/services\/specs/g;s/^leases$/leases\/kube-node-lease/g;s/^ingresses$/ingress/g;s/^podsecuritypolicies$/podsecuritypolicy/g')"
    # API_RESOURCE_GROUP="$(basename -a $file | cut -d '.' -f2- | sed 's/.yaml//g;s/yaml//g;s/apps//g;s/certificates.k8s.io//g;s/coordination.k8s.io//g;s/^extensions$//g;s/networking.k8s.io//g;s/rbac.authorization.k8s.io//g;s/scheduling.k8s.io//g;s/storage.k8s.io//g')"
    API_RESOURCE_GROUP="$(basename -a $file | cut -d '.' -f2- | sed -E 's/(.yaml|yaml|apps|certificates.k8s.io|coordination.k8s.io|^extensions$|networking.k8s.io|rbac.authorization.k8s.io|scheduling.k8s.io|storage.k8s.io)//g')"
    API_RESOURCE_NAMESPACED="$(yq '.items[].metadata | has("namespace")' "${API_RESOURCES_DIR}/${file}" | uniq)"

    if [[ -z $API_RESOURCE_NAMESPACED ]]; then
      echo "${YELLOW}Skipping empty $API_RESOURCE_NAME resource file.${RESET}"
    elif [[ $API_RESOURCE_NAMESPACED == "false" ]]; then
      if [[ -z $API_RESOURCE_GROUP ]]; then
        FILENAME=$file
        ITEMLIST="$(yq -c '.items[]' "${API_RESOURCES_DIR}/${FILENAME}" | sed s/\'/\'\'/g)"
        ITEMNAMELIST="$(yq -r '"\(.items[].metadata.name)"' "${API_RESOURCES_DIR}/${FILENAME}")"
        ITEMCOUNT=$(echo "${ITEMNAMELIST}" | wc -l | xargs)

        while [ $ITEMCOUNT -gt 0 ]; do
          ITEMNAME="$(echo "${ITEMNAMELIST}" | awk 'FNR=='$ITEMCOUNT'')"
          ITEMSTATE="$(echo "${ITEMLIST}" | awk 'FNR=='$ITEMCOUNT'')"

          echo "Building ${API_RESOURCE_NAME} state: ${ITEMNAME}"
          cat <<EOF >>"${API_RESOURCES_DIR}/.kbk/${FILENAME}.sql"
INSERT INTO key_value(name, value, create_revision, revision, ttl, version, del, id, old_revision) VALUES('/registry/$API_RESOURCE_NAME/$ITEMNAME', '$ITEMSTATE', $((RESOURCE_ID + 1)), $((RESOURCE_ID + 1)), 9999999999, 1, 0, $RESOURCE_ID, 0);

EOF
          ((RESOURCE_ID += 2))
          ((ITEMCOUNT--))
        done
      else
        FILENAME=$file
        ITEMLIST="$(yq -c '.items[]' "${API_RESOURCES_DIR}/${FILENAME}" | sed s/\'/\'\'/g)"
        ITEMNAMELIST="$(yq -r '"\(.items[].metadata.name)"' "${API_RESOURCES_DIR}/${FILENAME}")"
        ITEMCOUNT=$(echo "${ITEMNAMELIST}" | wc -l | xargs)

        while [ $ITEMCOUNT -gt 0 ]; do
          ITEMNAME="$(echo "${ITEMNAMELIST}" | awk 'FNR=='$ITEMCOUNT'')"
          ITEMSTATE="$(echo "${ITEMLIST}" | awk 'FNR=='$ITEMCOUNT'')"

          echo "Building ${API_RESOURCE_NAME} state: ${ITEMNAME}"
          cat <<EOF >>"${API_RESOURCES_DIR}/.kbk/${FILENAME}.sql"
INSERT INTO key_value(name, value, create_revision, revision, ttl, version, del, id, old_revision) VALUES('/registry/$API_RESOURCE_GROUP/$API_RESOURCE_NAME/$ITEMNAME', '$ITEMSTATE', $((RESOURCE_ID + 1)), $((RESOURCE_ID + 1)), 9999999999, 1, 0, $RESOURCE_ID, 0);

EOF
          ((RESOURCE_ID += 2))
          ((ITEMCOUNT--))
        done
      fi
    elif [[ $API_RESOURCE_NAMESPACED == "true" ]]; then
      if [[ -z $API_RESOURCE_GROUP ]]; then
        FILENAME=$file
        ITEMLIST="$(yq -c '.items[]' "${API_RESOURCES_DIR}/${FILENAME}" | sed s/\'/\'\'/g)"
        ITEMNAMELIST="$(yq -r '"\(.items[].metadata | .namespace + "/" + .name)"' "${API_RESOURCES_DIR}/${FILENAME}")"
        ITEMCOUNT=$(echo "${ITEMNAMELIST}" | wc -l | xargs)

        while [ $ITEMCOUNT -gt 0 ]; do
          NAMESPACE="$(echo "${ITEMNAMELIST}" | awk 'FNR=='$ITEMCOUNT'' | cut -d '/' -f 1)"
          ITEMNAME="$(echo "${ITEMNAMELIST}" | awk 'FNR=='$ITEMCOUNT'' | cut -d '/' -f 2)"
          ITEMSTATE="$(echo "${ITEMLIST}" | awk 'FNR=='$ITEMCOUNT'')"

          echo "Building ${API_RESOURCE_NAME} state: ${NAMESPACE}/${ITEMNAME}"
          cat <<EOF >>"${API_RESOURCES_DIR}/.kbk/${FILENAME}.sql"
INSERT INTO key_value(name, value, create_revision, revision, ttl, version, del, id, old_revision) VALUES('/registry/$API_RESOURCE_NAME/$NAMESPACE/$ITEMNAME', '$ITEMSTATE', $((RESOURCE_ID + 1)), $((RESOURCE_ID + 1)), 9999999999, 1, 0, $RESOURCE_ID, 0);

EOF
          ((RESOURCE_ID += 2))
          ((ITEMCOUNT--))
        done
      else
        FILENAME=$file
        ITEMLIST="$(yq -c '.items[]' "${API_RESOURCES_DIR}/${FILENAME}" | sed s/\'/\'\'/g)"
        ITEMNAMELIST="$(yq -r '"\(.items[].metadata | .namespace + "/" + .name)"' "${API_RESOURCES_DIR}/${FILENAME}")"
        ITEMCOUNT=$(echo "${ITEMNAMELIST}" | wc -l | xargs)

        while [ $ITEMCOUNT -gt 0 ]; do
          NAMESPACE="$(echo "${ITEMNAMELIST}" | awk 'FNR=='$ITEMCOUNT'' | cut -d '/' -f 1)"
          ITEMNAME="$(echo "${ITEMNAMELIST}" | awk 'FNR=='$ITEMCOUNT'' | cut -d '/' -f 2)"
          ITEMSTATE="$(echo "${ITEMLIST}" | awk 'FNR=='$ITEMCOUNT'')"

          echo "Building ${API_RESOURCE_NAME} state: ${NAMESPACE}/${ITEMNAME}"
          cat <<EOF >>"${API_RESOURCES_DIR}/.kbk/${FILENAME}.sql"
INSERT INTO key_value(name, value, create_revision, revision, ttl, version, del, id, old_revision) VALUES('/registry/$API_RESOURCE_GROUP/$API_RESOURCE_NAME/$NAMESPACE/$ITEMNAME', '$ITEMSTATE', $((RESOURCE_ID + 1)), $((RESOURCE_ID + 1)), 9999999999, 1, 0, $RESOURCE_ID, 0);

EOF
          ((RESOURCE_ID += 2))
          ((ITEMCOUNT--))
        done
      fi
    fi
  done

  ###
  # End resources section
  ###

  echo "${GREEN}Adding resources into database.${RESET}"
  find "${API_RESOURCES_DIR}/.kbk" -name "*.sql" -type f -exec sh -c 'sqlite3 '"${API_RESOURCES_DIR}/.kbk/db/state.db"' < "$1"' x "{}" \;

  sleep 5

  # Add a check here to make sure that everything started properly (3x retry - 30s timeout)
  echo "${GREEN}Starting cluster.${RESET}"
  k3d start --name "${CLUSTER_NAME}"

  sleep 5

  echo "${GREEN}Started cluster. Please set your kubeconfig with:${RESET}"
  echo "export KUBECONFIG=\"\$(k3d get-kubeconfig --name='$CLUSTER_NAME')\""

  # Add disclaimers here: 
  #   - e.g., missing x endpoints due to k3d cluster conficts, etc., or maybe play with diff ports if this is actually a problem
  #   - Print empty apiresources at the end so that the user knows what is _ACTUALLY_ missing
}

up() {
  preflightUp "$@"

  if [[ $CLUSTER_STATUS == "deleted" ]] || [[ $FORCE == 1 ]]; then
    createCluster
  elif [[ $CLUSTER_STATUS == "unavailable" ]]; then
    echo "Found a previous cluster unavailable: ${CLUSTER_NAME}"
    echo "To force overwrite the cluster state and create a new cluster, use the --force flag."
    exit 1
  elif [[ $CLUSTER_STATUS == "running" ]]; then
    echo "Found a previous cluster running: ${CLUSTER_NAME}"
    echo "To force overwrite the cluster state and create a new cluster, use the --force flag."
    exit 1
  fi
}

down() {
  preflightDown "$@"

  if [[ $CLUSTER_STATUS == "deleted" ]]; then
    echo "Cluster not found. Was it already deleted?"
    exit 1
  fi

  echo "Deleting cluster: ${CLUSTER_NAME}"
  k3d delete --name "${CLUSTER_NAME}"
  echo "Deleting database resources."
  # Add prompt here saying what dir will be deleted and a --yes/--force flag
  rm -r "$(jq -r '.dataDirectory' "${STATE_FILE}")"
  echo "Wiping cluster state file."
  echo >"${STATE_FILE}"
  echo "Done."
}

status() {
  declare -a otherargs

  while [ -n "${1}" ]; do
    arg="${1}"
    shift
    case "$arg" in
    --help | -h)
      statusHelp
      exit 0
      ;;
    -*)
      echo "Unrecognized argument: $arg" 1>&2
      statusHelp
      exit 1
      ;;
    *)
      otherargs+=("$arg")
      ;;
    esac
  done

  preflightCluster

  if [[ $CLUSTER_NAME == "" ]]; then
    echo "No cluster found."
  else
    jq '.' "${STATE_FILE}"
  fi
}

podChecks() {
  PODS_NOT_RUNNING="$(find "${API_RESOURCES_DIR}" -name 'pods.yaml' -type f -exec yq -r '"\(.items[] | select(([.status.containerStatuses[]? | select(.ready == true) | .ready] | length | tostring) != ([.status.containerStatuses[]?.ready] | length | tostring)) | (.metadata | .namespace + "~" + .name) + "~" + ([.status.containerStatuses[]? | select(.ready == true) | .ready] | length | tostring) + "/" + ([.status.containerStatuses[]?.ready] | length | tostring) + "~" + (if .status.conditions[] | select(.type == "Ready") | .status == "True" then .status.phase else .status.conditions[] | select(.type == "Ready") | .reason end) + "~" + ((reduce .status.containerStatuses[]? as $cr (0; . + ($cr | .restartCount) )) | tostring) + "~" + .metadata.creationTimestamp + "~" + (if .status.podIP? != null then .status.podIP? else "<none>" end) + "~" + (if .spec.nodeName? != null then .spec.nodeName? else "<none>" end))"' "{}" \;)"

  if [[ -n $PODS_NOT_RUNNING ]]; then
    echo -e "${RED} X Detected the following pods not ready:${RESET}"
    (echo "NAMESPACE~NAME~READY~STATUS~RESTARTS~CREATED~IP~NODE"
    echo -e "$PODS_NOT_RUNNING") | column -t -s '~' | sed 's/^/   /g'
  else
    echo -e "${GREEN} + No pods not in a ready state.${RESET}"
  fi
}

nodeChecks() {
  # Nodes not ready
  NODES_NOT_READY="$(find "${API_RESOURCES_DIR}" -name 'nodes*.yaml' -type f -exec yq -r '"\(.items[] | select(.status.conditions[] | select(.type == "Ready") | .status != "True") | .metadata.name + "~" + (.status.conditions[] | select(.type == "Ready") | if .status == "True" then "Ready" else "NotReady" end) + "~" + (.metadata.labels | if ."node-role.kubernetes.io/master"? then "master" else "worker" end) + "~" + (.metadata.creationTimestamp | tostring) + "~" + (.status.addresses[] | select(.type == "InternalIP") .address) + "~" + (.status.conditions[] | select(.type == "Ready") | .status + "~" + .reason + "~" + .message + "~" + (.lastHeartbeatTime | tostring)))"' "{}" \;)"

  if [[ -n $NODES_NOT_READY ]]; then
    echo -e "${RED} X Detected the following nodes not ready:${RESET}"
    (echo "NAME~STATUS~ROLES~CREATED~INTERNAL-IP~STATUS~REASON~MESSAGE~LAST-HEARTBEAT"
    echo -e "$NODES_NOT_READY") | column -t -s '~' | sed 's/^/   /g'
  else
    echo -e "${GREEN} + No nodes not in a ready state.${RESET}"
  fi

  # Kubelet not running
  KUBELET_INACTIVE_NODES="$(grep -R 'Active:' "${BUNDLE_ROOT}/"*"/kubelet.service.status.txt" | grep -vi 'Active: active (running)' | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\|(.*)' | paste -d "~" - -)"

  if [[ -n $KUBELET_INACTIVE_NODES ]]; then
    echo -e "${RED} X Detected kubelet not running on the following nodes:${RESET}"
    (echo "IP~KUBELET-STATUS"
    echo -e "$KUBELET_INACTIVE_NODES") | column -t -s '~'| sed 's/^/   /g'
  else
    echo -e "${GREEN} + No nodes with kubelet not running found.${RESET}"
  fi

  # Unsupported OS versions
  UNSUPPORTED_OS_NODES="$(find "${BUNDLE_ROOT}" -name 'ansible_facts.json' -type f -exec jq -r '"\(select((.distribution | (contains("CentOS") or contains("RedHat")) | not) or (.distribution_version | startswith("7.6") | not)) | .nodename + "~" + .default_ipv4.address + "~" + .distribution + " " + .distribution_version)"' "{}" \;)"

  if [[ -n $UNSUPPORTED_OS_NODES ]]; then
    echo -e "${RED} X Detected an unsupported OS the following node(s):${RESET}"
    (echo -e "NODE~IP~OS-VERSION"
    echo -e "$UNSUPPORTED_OS_NODES") | column -t -s '~' | sed 's/^/   /g'
  else
    echo -e "${GREEN} + No unsupported OS found.${RESET}"
  fi

  # Unsupported kernel versions
  UNSUPPORTED_KERNEL_VERSIONS="$(find "${BUNDLE_ROOT}" -name 'ansible_facts.json' -type f -exec jq -r '"\(select(.kernel | startswith("3.10.0-957") | not) | .nodename + "~" + .default_ipv4.address + "~" + .kernel)"' "{}" \;)"
  
  if [[ -n $UNSUPPORTED_KERNEL_VERSIONS ]]; then
    echo -e "${RED} X Detected an unsupported kernel on the following node(s):${RESET}"
    (echo -e "NODE~IP~KERNEL-VERSION"
    echo -e "$UNSUPPORTED_KERNEL_VERSIONS") | column -t -s '~' | sed 's/^/   /g'
  else
    echo -e "${GREEN} + No unsupported kernel found.${RESET}"
  fi

  # Disk space critical
  NODE_CRITICAL_DISK_USAGE_PER_MOUNT="$(find "${BUNDLE_ROOT}" -name 'ansible_facts.json' -type f -exec jq -r '"\(select(.mounts[] | (.size_available? != null) and (.size_total? != null) and ((((.size_available / .size_total) * 100) > 10) | not)) as $fd | $fd | .nodename + "~" + .default_ipv4.address + "~" + (.mounts[] | select((.size_available? != null) and (.size_total? != null) and ((((.size_available / .size_total) * 100) < 10))) | .mount + "~" + ((((.size_available / .size_total) * 100) | floor | tostring) + "%") + " (" + (((.size_available / 1000000000) | floor | tostring) + " GB") + ")" + "~" + .device))"' "{}" \;)"
  
  if [[ -n $NODE_CRITICAL_DISK_USAGE_PER_MOUNT ]]; then
    echo -e "${RED} X Detected high disk space usage the following node(s):${RESET}"
    (echo -e "NODE~IP~MOUNT~DISK-FREE~DEVICE"
    echo -e "$NODE_CRITICAL_DISK_USAGE_PER_MOUNT") | column -t -s '~' | sed 's/^/   /g'
  else
    echo -e "${GREEN} + No high disk space usage found.${RESET}"
  fi

  # Swap enabled
  SWAP_ENABLED_NODES="$(find "${BUNDLE_ROOT}" -name 'ansible_facts.json' -type f -exec jq -r '"\(select(.swaptotal_mb != 0) | .nodename + "~" + .default_ipv4.address + "~true~" + (.swaptotal_mb | tostring))"' "{}" \;)"

  if [[ -n $SWAP_ENABLED_NODES ]]; then
    echo -e "${RED} X Detected swap enabled on the following nodes:${RESET}"
    (echo "NODE~IP~SWAP-ENABLED~SWAP-SIZE"
    echo -e "$SWAP_ENABLED_NODES") | column -t -s '~'| sed 's/^/   /g'
  else
    echo -e "${GREEN} + No nodes with swap enabled found.${RESET}"
  fi

  # Containerd not running
  CONTAINERD_INACTIVE_NODES="$(grep -R 'Active:' "${BUNDLE_ROOT}/"*"/containerd.service.status.txt" | grep -vi 'Active: active (running)' | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\|(.*)' | paste -d "~" - -)"

  if [[ -n $CONTAINERD_INACTIVE_NODES ]]; then
    echo -e "${RED} X Detected containerd not running on the following nodes:${RESET}"
    (echo "IP~CONTAINERD-STATUS"
    echo -e "$CONTAINERD_INACTIVE_NODES") | column -t -s '~'| sed 's/^/   /g'
  else
    echo -e "${GREEN} + No nodes with containerd not running found.${RESET}"
  fi

  # AppArmor enabled
  APP_ARMOR_ENABLED_NODES="$(find "${BUNDLE_ROOT}" -name 'ansible_facts.json' -type f -exec jq -r '"\(select(.apparmor.status != "disabled") | .nodename + "~" + .default_ipv4.address + "~" + .apparmor.status)"' "{}" \;)"
  
  if [[ -n $APP_ARMOR_ENABLED_NODES ]]; then
    echo -e "${RED} X Detected AppArmor enabled on the following nodes:${RESET}"
    (echo "NODE~IP~APPARMOR-STATUS"
    echo -e "$APP_ARMOR_ENABLED_NODES") | column -t -s '~'| sed 's/^/   /g'
  else
    echo -e "${GREEN} + No nodes with AppArmor enabled found.${RESET}"
  fi

  # KMEM leaks
  KMEM_EVENTS_PER_NODE="$(grep -i 'SLUB: Unable to allocate memory on node -1' -- "${BUNDLE_ROOT}/"*"/dmesg"* 2> /dev/null | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | sort -k 2 | uniq -c)"

  if [[ -n $KMEM_EVENTS_PER_NODE ]]; then
    echo -e "${RED} X Detected kmem events on the following nodes:${RESET}"
    (echo -e "EVENTS NODE"
    echo -e "$KMEM_EVENTS_PER_NODE") | column -t | sed 's/^/   /g'
  else
    echo -e "${GREEN} + No KMEM related events found.${RESET}"
  fi

  # OOM kills
  OOM_EVENTS_PER_NODE="$(grep -i 'killed process' -- "${BUNDLE_ROOT}/"*"/dmesg"* 2> /dev/null | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\|(.*)' | paste - - | sort | uniq -c | sort -k 2)"

  if [[ -n $OOM_EVENTS_PER_NODE ]]; then
    echo -e "${RED} X Detected processes oom-killed on the following nodes:${RESET}"
    (echo -e "EVENTS NODE PROCESS"
    echo -e "$OOM_EVENTS_PER_NODE") | column -t | sed 's/^/   /g'
  else
    echo -e "${GREEN} + No out of memory events found.${RESET}"
  fi
}

preflightChecks() {
  declare -a otherargs

  while [ -n "${1}" ]; do
    arg="${1}"
    shift
    case "$arg" in
    --help | -h)
      checksHelp
      exit 0
      ;;
    -*)
      echo "Unrecognized argument: $arg" 1>&2
      checksHelp
      exit 1
      ;;
    *)
      otherargs+=("$arg")
      ;;
    esac
  done

  preflightBundle
}

checks() {
  preflightChecks "$@"

  podChecks
  nodeChecks
}

case "${1}" in
  extract | e)
    extract "$@"
    ;;
  logs | l )
    logs "$@"
    ;;
  up | u)
    up "$@"
    ;;
  down | d)
    down "$@"
    ;;
  status | s)
    status "$@"
    ;;
  kubeconfig | k)
    kubeconfig "$@"
    ;;
  checks | c)
    checks "$@"
    ;;
  *)
    mainHelp
    ;;
esac
