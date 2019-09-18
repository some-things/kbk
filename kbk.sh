#!/usr/bin/env bash

# set -o errexit
# set -o pipefail
# set -o nounset

#####
# Extract
#####
# Set the full path to where you would like to have bundle and ticket files and folders created.
USER_TICKETS_DIR="${KBK_TICKETS_DIR:-${HOME}/Documents/logs/tickets}"

# USER_TICKETS_DIR must be set to a valid path for any 'extract' commands to function properly
extractBundle ()  {
  if [[ -n "${1}" ]]; then
    read -r -p "Ticket number: " TICKET_NUM
    BUNDLE_DIR="${USER_TICKETS_DIR}/${TICKET_NUM}/bundle-${1%%.tar.gz}"
    mkdir -p "${BUNDLE_DIR}"
    echo "Extracting bundle to ${BUNDLE_DIR}..."
    tar -xf "${1}" -C "${BUNDLE_DIR}"
    mv "${BUNDLE_DIR}/bundles/"* "${BUNDLE_DIR}"
    rm -r "${BUNDLE_DIR}/bundles/"
    echo "Extracting nodes..."
    find "${BUNDLE_DIR}" -name '*.tar.gz' -exec sh -c 'node_dir="${1%%.tar.gz}"; mkdir "${node_dir}" 2> /dev/null; tar -xvzf "$1" -C "${node_dir}" 2> /dev/null && rm -rf "$1"' sh {} \;
    echo "Finished extracting bundle to ${BUNDLE_DIR}"
    exit 0
  else
    echo "Please specify a compressed Konvoy diagnostic bundle file to extract."
    exit 1
  fi
}

extract-Help() {
  cat <<EOF
kbk extract usage:
  extract <bundle-name>.tar.gz - Extracts a compressed bundles to a specified directory.
EOF
}

#####
# // TODO: This will need to be diffed and maintained for each Konvoy release (e.g., if api versions change). This should be done a different way 
# Explain
#####

explain-Binding() {
  cat <<EOF
KIND:     Binding
VERSION:  v1

DESCRIPTION:
     Binding ties one object to another; for example, a pod is bound to a node
     by a scheduler. Deprecated in 1.7, please use the bindings subresource of
     pods instead.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object's metadata. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata

   target	<Object> -required-
     The target object that you want to bind to the standard object.
EOF
}


explain-ComponentStatus() {
  cat <<EOF
KIND:     ComponentStatus
VERSION:  v1

DESCRIPTION:
     ComponentStatus (and ComponentStatusList) holds the cluster validation
     info.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   conditions	<[]Object>
     List of component conditions observed

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object's metadata. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
EOF
}

explain-ConfigMap() {
  cat <<EOF
KIND:     ConfigMap
VERSION:  v1

DESCRIPTION:
     ConfigMap holds configuration data for pods to consume.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   binaryData	<map[string]string>
     BinaryData contains the binary data. Each key must consist of alphanumeric
     characters, '-', '_' or '.'. BinaryData can contain byte sequences that are
     not in the UTF-8 range. The keys stored in BinaryData must not overlap with
     the ones in the Data field, this is enforced during validation process.
     Using this field will require 1.10+ apiserver and kubelet.

   data	<map[string]string>
     Data contains the configuration data. Each key must consist of alphanumeric
     characters, '-', '_' or '.'. Values with non-UTF-8 byte sequences must use
     the BinaryData field. The keys stored in Data must not overlap with the
     keys in the BinaryData field, this is enforced during validation process.

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object's metadata. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
EOF
}

explain-Endpoints() {
  cat <<EOF
KIND:     Endpoints
VERSION:  v1

DESCRIPTION:
     Endpoints is a collection of endpoints that implement the actual service.
     Example: Name: "mysvc", Subsets: [ { Addresses: [{"ip": "10.10.1.1"},
     {"ip": "10.10.2.2"}], Ports: [{"name": "a", "port": 8675}, {"name": "b",
     "port": 309}] }, { Addresses: [{"ip": "10.10.3.3"}], Ports: [{"name": "a",
     "port": 93}, {"name": "b", "port": 76}] }, ]

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object's metadata. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata

   subsets	<[]Object>
     The set of all endpoints is the union of all subsets. Addresses are placed
     into subsets according to the IPs they share. A single address with
     multiple ports, some of which are ready and some of which are not (because
     they come from different containers) will result in the address being
     displayed in different subsets for the different ports. No address will
     appear in both Addresses and NotReadyAddresses in the same subset. Sets of
     addresses and ports that comprise a service.
EOF
}

explain-Event() {
  cat <<EOF
KIND:     Event
VERSION:  v1

DESCRIPTION:
     Event is a report of an event somewhere in the cluster.

FIELDS:
   action	<string>
     What action was taken/failed regarding to the Regarding object.

   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   count	<integer>
     The number of times this event has occurred.

   eventTime	<string>
     Time when this Event was first observed.

   firstTimestamp	<string>
     The time at which the event was first recorded. (Time of server receipt is
     in TypeMeta.)

   involvedObject	<Object> -required-
     The object that this event is about.

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   lastTimestamp	<string>
     The time at which the most recent occurrence of this event was recorded.

   message	<string>
     A human-readable description of the status of this operation.

   metadata	<Object> -required-
     Standard object's metadata. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata

   reason	<string>
     This should be a short, machine understandable string that gives the reason
     for the transition into the object's current status.

   related	<Object>
     Optional secondary object for more complex actions.

   reportingComponent	<string>
     Name of the controller that emitted this Event, e.g.
     \`kubernetes.io/kubelet\`.

   reportingInstance	<string>
     ID of the controller instance, e.g. \`kubelet-xyzf\`.

   series	<Object>
     Data about the Event series this event represents or nil if it's a
     singleton Event.

   source	<Object>
     The component reporting this event. Should be a short machine
     understandable string.

   type	<string>
     Type of this event (Normal, Warning), new types could be added in the
     future
EOF
}

explain-LimitRange() {
  cat <<EOF
KIND:     LimitRange
VERSION:  v1

DESCRIPTION:
     LimitRange sets resource usage limits for each kind of resource in a
     Namespace.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object's metadata. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata

   spec	<Object>
     Spec defines the limits enforced. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
EOF
}

explain-Namespace() {
  cat <<EOF
KIND:     Namespace
VERSION:  v1

DESCRIPTION:
     Namespace provides a scope for Names. Use of multiple namespaces is
     optional.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object's metadata. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata

   spec	<Object>
     Spec defines the behavior of the Namespace. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status

   status	<Object>
     Status describes the current status of a Namespace. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
EOF
}

explain-Node() {
  cat <<EOF
KIND:     Node
VERSION:  v1

DESCRIPTION:
     Node is a worker node in Kubernetes. Each node will have a unique
     identifier in the cache (i.e. in etcd).

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object's metadata. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata

   spec	<Object>
     Spec defines the behavior of a node.
     https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status

   status	<Object>
     Most recently observed status of the node. Populated by the system.
     Read-only. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
EOF
}

explain-PersistentVolumeClaim() {
  cat <<EOF
KIND:     PersistentVolumeClaim
VERSION:  v1

DESCRIPTION:
     PersistentVolumeClaim is a user's request for and claim to a persistent
     volume

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object's metadata. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata

   spec	<Object>
     Spec defines the desired characteristics of a volume requested by a pod
     author. More info:
     https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistentvolumeclaims

   status	<Object>
     Status represents the current information/status of a persistent volume
     claim. Read-only. More info:
     https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistentvolumeclaims
EOF
}

explain-PersistentVolume() {
  cat <<EOF
KIND:     PersistentVolume
VERSION:  v1

DESCRIPTION:
     PersistentVolume (PV) is a storage resource provisioned by an
     administrator. It is analogous to a node. More info:
     https://kubernetes.io/docs/concepts/storage/persistent-volumes

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object's metadata. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata

   spec	<Object>
     Spec defines a specification of a persistent volume owned by the cluster.
     Provisioned by an administrator. More info:
     https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistent-volumes

   status	<Object>
     Status represents the current information/status for the persistent volume.
     Populated by the system. Read-only. More info:
     https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistent-volumes
EOF
}

explain-Pod() {
  cat <<EOF
KIND:     Pod
VERSION:  v1

DESCRIPTION:
     Pod is a collection of containers that can run on a host. This resource is
     created by clients and scheduled onto hosts.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object's metadata. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata

   spec	<Object>
     Specification of the desired behavior of the pod. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status

   status	<Object>
     Most recently observed status of the pod. This data may not be up to date.
     Populated by the system. Read-only. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
EOF
}

explain-PodTemplate() {
  cat <<EOF
KIND:     PodTemplate
VERSION:  v1

DESCRIPTION:
     PodTemplate describes a template for creating copies of a predefined pod.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object's metadata. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata

   template	<Object>
     Template defines the pods that will be created from this pod template.
     https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
EOF
}

explain-ReplicationController() {
  cat <<EOF
KIND:     ReplicationController
VERSION:  v1

DESCRIPTION:
     ReplicationController represents the configuration of a replication
     controller.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     If the Labels of a ReplicationController are empty, they are defaulted to
     be the same as the Pod(s) that the replication controller manages. Standard
     object's metadata. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata

   spec	<Object>
     Spec defines the specification of the desired behavior of the replication
     controller. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status

   status	<Object>
     Status is the most recently observed status of the replication controller.
     This data may be out of date by some window of time. Populated by the
     system. Read-only. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
EOF
}

explain-ResourceQuota() {
  cat <<EOF
KIND:     ResourceQuota
VERSION:  v1

DESCRIPTION:
     ResourceQuota sets aggregate quota restrictions enforced per namespace

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object's metadata. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata

   spec	<Object>
     Spec defines the desired quota.
     https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status

   status	<Object>
     Status defines the actual enforced quota and its current usage.
     https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
EOF
}

explain-Secret() {
  cat <<EOF
KIND:     Secret
VERSION:  v1

DESCRIPTION:
     Secret holds secret data of a certain type. The total bytes of the values
     in the Data field must be less than MaxSecretSize bytes.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   data	<map[string]string>
     Data contains the secret data. Each key must consist of alphanumeric
     characters, '-', '_' or '.'. The serialized form of the secret data is a
     base64 encoded string, representing the arbitrary (possibly non-string)
     data value here. Described in https://tools.ietf.org/html/rfc4648#section-4

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object's metadata. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata

   stringData	<map[string]string>
     stringData allows specifying non-binary secret data in string form. It is
     provided as a write-only convenience method. All keys and values are merged
     into the data field on write, overwriting any existing values. It is never
     output when reading from the API.

   type	<string>
     Used to facilitate programmatic handling of secret data.
EOF
}

explain-ServiceAccount() {
  cat <<EOF
KIND:     ServiceAccount
VERSION:  v1

DESCRIPTION:
     ServiceAccount binds together: * a name, understood by users, and perhaps
     by peripheral systems, for an identity * a principal that can be
     authenticated and authorized * a set of secrets

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   automountServiceAccountToken	<boolean>
     AutomountServiceAccountToken indicates whether pods running as this service
     account should have an API token automatically mounted. Can be overridden
     at the pod level.

   imagePullSecrets	<[]Object>
     ImagePullSecrets is a list of references to secrets in the same namespace
     to use for pulling any images in pods that reference this ServiceAccount.
     ImagePullSecrets are distinct from Secrets because Secrets can be mounted
     in the pod, but ImagePullSecrets are only accessed by the kubelet. More
     info:
     https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object's metadata. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata

   secrets	<[]Object>
     Secrets is the list of secrets allowed to be used by pods running using
     this ServiceAccount. More info:
     https://kubernetes.io/docs/concepts/configuration/secret
EOF
}

explain-Service() {
  cat <<EOF
KIND:     Service
VERSION:  v1

DESCRIPTION:
     Service is a named abstraction of software service (for example, mysql)
     consisting of local port (for example 3306) that the proxy listens on, and
     the selector that determines which pods will answer requests sent through
     the proxy.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object's metadata. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata

   spec	<Object>
     Spec defines the behavior of a service.
     https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status

   status	<Object>
     Most recently observed status of the service. Populated by the system.
     Read-only. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
EOF
}

explain-MutatingWebhookConfiguration() {
  cat <<EOF
KIND:     MutatingWebhookConfiguration
VERSION:  admissionregistration.k8s.io/v1beta1

DESCRIPTION:
     MutatingWebhookConfiguration describes the configuration of and admission
     webhook that accept or reject and may change the object.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object metadata; More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata.

   webhooks	<[]Object>
     Webhooks is a list of webhooks and the affected resources and operations.
EOF
}

explain-ValidatingWebhookConfiguration() {
  cat <<EOF
KIND:     ValidatingWebhookConfiguration
VERSION:  admissionregistration.k8s.io/v1beta1

DESCRIPTION:
     ValidatingWebhookConfiguration describes the configuration of and admission
     webhook that accept or reject and object without changing it.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object metadata; More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata.

   webhooks	<[]Object>
     Webhooks is a list of webhooks and the affected resources and operations.
EOF
}

explain-CustomResourceDefinition() {
  cat <<EOF
KIND:     CustomResourceDefinition
VERSION:  apiextensions.k8s.io/v1beta1

DESCRIPTION:
     CustomResourceDefinition represents a resource that should be exposed on
     the API server. Its name MUST be in the format <.spec.name>.<.spec.group>.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>

   spec	<Object> -required-
     Spec describes how the user wants the resources to appear

   status	<Object>
     Status indicates the actual state of the CustomResourceDefinition
EOF
}

explain-APIService() {
  cat <<EOF
KIND:     APIService
VERSION:  apiregistration.k8s.io/v1

DESCRIPTION:
     APIService represents a server for a particular GroupVersion. Name must be
     "version.group".

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>

   spec	<Object>
     Spec contains information for locating and communicating with a server

   status	<Object>
     Status contains derived information about an API server
EOF
}

explain-ControllerRevision() {
  cat <<EOF
KIND:     ControllerRevision
VERSION:  apps/v1

DESCRIPTION:
     ControllerRevision implements an immutable snapshot of state data. Clients
     are responsible for serializing and deserializing the objects that contain
     their internal state. Once a ControllerRevision has been successfully
     created, it can not be updated. The API Server will fail validation of all
     requests that attempt to mutate the Data field. ControllerRevisions may,
     however, be deleted. Note that, due to its use by both the DaemonSet and
     StatefulSet controllers for update and rollback, this object is beta.
     However, it may be subject to name and representation changes in future
     releases, and clients should not depend on its stability. It is primarily
     for internal use by controllers.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   data	<Object>
     Data is the serialized representation of the state.

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object's metadata. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata

   revision	<integer> -required-
     Revision indicates the revision of the state represented by Data.
EOF
}

explain-DaemonSet() {
  cat <<EOF
KIND:     DaemonSet
VERSION:  extensions/v1beta1

DESCRIPTION:
     DEPRECATED - This group version of DaemonSet is deprecated by
     apps/v1beta2/DaemonSet. See the release notes for more information.
     DaemonSet represents the configuration of a daemon set.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object's metadata. More info:
     https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata

   spec	<Object>
     The desired behavior of this daemon set. More info:
     https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status

   status	<Object>
     The current status of this daemon set. This data may be out of date by some
     window of time. Populated by the system. Read-only. More info:
     https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
EOF
}

explain-Deployment() {
  cat <<EOF
KIND:     Deployment
VERSION:  extensions/v1beta1

DESCRIPTION:
     DEPRECATED - This group version of Deployment is deprecated by
     apps/v1beta2/Deployment. See the release notes for more information.
     Deployment enables declarative updates for Pods and ReplicaSets.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object metadata.

   spec	<Object>
     Specification of the desired behavior of the Deployment.

   status	<Object>
     Most recently observed status of the Deployment.
EOF
}

explain-ReplicaSet() {
  cat <<EOF
KIND:     ReplicaSet
VERSION:  extensions/v1beta1

DESCRIPTION:
     DEPRECATED - This group version of ReplicaSet is deprecated by
     apps/v1beta2/ReplicaSet. See the release notes for more information.
     ReplicaSet ensures that a specified number of pod replicas are running at
     any given time.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     If the Labels of a ReplicaSet are empty, they are defaulted to be the same
     as the Pod(s) that the ReplicaSet manages. Standard object's metadata. More
     info:
     https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata

   spec	<Object>
     Spec defines the specification of the desired behavior of the ReplicaSet.
     More info:
     https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status

   status	<Object>
     Status is the most recently observed status of the ReplicaSet. This data
     may be out of date by some window of time. Populated by the system.
     Read-only. More info:
     https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
EOF
}

explain-StatefulSet() {
  cat <<EOF
KIND:     StatefulSet
VERSION:  apps/v1

DESCRIPTION:
     StatefulSet represents a set of pods with consistent identities. Identities
     are defined as: - Network: A single stable DNS and hostname. - Storage: As
     many VolumeClaims as requested. The StatefulSet guarantees that a given
     network identity will always map to the same storage identity.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>

   spec	<Object>
     Spec defines the desired identities of pods in this set.

   status	<Object>
     Status is the current status of Pods in this StatefulSet. This data may be
     out of date by some window of time.
EOF
}

explain-TokenReview() {
  cat <<EOF
KIND:     TokenReview
VERSION:  authentication.k8s.io/v1

DESCRIPTION:
     TokenReview attempts to authenticate a token to a known user. Note:
     TokenReview requests may be cached by the webhook token authenticator
     plugin in the kube-apiserver.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>

   spec	<Object> -required-
     Spec holds information about the request being evaluated

   status	<Object>
     Status is filled in by the server and indicates whether the request can be
     authenticated.
EOF
}

explain-LocalSubjectAccessReview() {
  cat <<EOF
KIND:     LocalSubjectAccessReview
VERSION:  authorization.k8s.io/v1

DESCRIPTION:
     LocalSubjectAccessReview checks whether or not a user or group can perform
     an action in a given namespace. Having a namespace scoped resource makes it
     much easier to grant namespace scoped policy that includes permissions
     checking.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>

   spec	<Object> -required-
     Spec holds information about the request being evaluated. spec.namespace
     must be equal to the namespace you made the request against. If empty, it
     is defaulted.

   status	<Object>
     Status is filled in by the server and indicates whether the request is
     allowed or not
EOF
}

explain-SelfSubjectAccessReview() {
  cat <<EOF
KIND:     SelfSubjectAccessReview
VERSION:  authorization.k8s.io/v1

DESCRIPTION:
     SelfSubjectAccessReview checks whether or the current user can perform an
     action. Not filling in a spec.namespace means "in all namespaces". Self is
     a special case, because users should always be able to check whether they
     can perform an action

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>

   spec	<Object> -required-
     Spec holds information about the request being evaluated. user and groups
     must be empty

   status	<Object>
     Status is filled in by the server and indicates whether the request is
     allowed or not
EOF
}

explain-SelfSubjectRulesReview() {
  cat <<EOF
KIND:     SelfSubjectRulesReview
VERSION:  authorization.k8s.io/v1

DESCRIPTION:
     SelfSubjectRulesReview enumerates the set of actions the current user can
     perform within a namespace. The returned list of actions may be incomplete
     depending on the server's authorization mode, and any errors experienced
     during the evaluation. SelfSubjectRulesReview should be used by UIs to
     show/hide actions, or to quickly let an end user reason about their
     permissions. It should NOT Be used by external systems to drive
     authorization decisions as this raises confused deputy, cache
     lifetime/revocation, and correctness concerns. SubjectAccessReview, and
     LocalAccessReview are the correct way to defer authorization decisions to
     the API server.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>

   spec	<Object> -required-
     Spec holds information about the request being evaluated.

   status	<Object>
     Status is filled in by the server and indicates the set of actions a user
     can perform.
EOF
}

explain-SubjectAccessReview() {
  cat <<EOF
KIND:     SubjectAccessReview
VERSION:  authorization.k8s.io/v1

DESCRIPTION:
     SubjectAccessReview checks whether or not a user or group can perform an
     action.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>

   spec	<Object> -required-
     Spec holds information about the request being evaluated

   status	<Object>
     Status is filled in by the server and indicates whether the request is
     allowed or not
EOF
}

explain-HorizontalPodAutoscaler() {
  cat <<EOF
KIND:     HorizontalPodAutoscaler
VERSION:  autoscaling/v1

DESCRIPTION:
     configuration of a horizontal pod autoscaler.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object metadata. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata

   spec	<Object>
     behaviour of autoscaler. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status.

   status	<Object>
     current information about the autoscaler.
EOF
}

explain-CronJob() {
  cat <<EOF
KIND:     CronJob
VERSION:  batch/v1beta1

DESCRIPTION:
     CronJob represents the configuration of a single cron job.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object's metadata. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata

   spec	<Object>
     Specification of the desired behavior of a cron job, including the
     schedule. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status

   status	<Object>
     Current status of a cron job. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
EOF
}

explain-Job() {
  cat <<EOF
KIND:     Job
VERSION:  batch/v1

DESCRIPTION:
     Job represents the configuration of a single job.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object's metadata. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata

   spec	<Object>
     Specification of the desired behavior of a job. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status

   status	<Object>
     Current status of a job. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
EOF
}

explain-CertificateSigningRequest() {
  cat <<EOF
KIND:     CertificateSigningRequest
VERSION:  certificates.k8s.io/v1beta1

DESCRIPTION:
     Describes a certificate signing request

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>

   spec	<Object>
     The certificate request itself and any additional information.

   status	<Object>
     Derived information about the request.
EOF
}

explain-Lease() {
  cat <<EOF
KIND:     Lease
VERSION:  coordination.k8s.io/v1

DESCRIPTION:
     Lease defines a lease concept.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata

   spec	<Object>
     Specification of the Lease. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status
EOF
}

explain-BGPConfiguration() {
  cat <<EOF
KIND:     BGPConfiguration
VERSION:  crd.projectcalico.org/v1

DESCRIPTION:
     <empty>
EOF
}

explain-BGPPeer() {
  cat <<EOF
KIND:     BGPPeer
VERSION:  crd.projectcalico.org/v1

DESCRIPTION:
     <empty>
EOF
}

explain-BlockAffinity() {
  cat <<EOF
KIND:     BlockAffinity
VERSION:  crd.projectcalico.org/v1

DESCRIPTION:
     <empty>
EOF
}

explain-ClusterInformation() {
  cat <<EOF
KIND:     ClusterInformation
VERSION:  crd.projectcalico.org/v1

DESCRIPTION:
     <empty>
EOF
}

explain-FelixConfiguration() {
  cat <<EOF
KIND:     FelixConfiguration
VERSION:  crd.projectcalico.org/v1

DESCRIPTION:
     <empty>
EOF
}

explain-GlobalNetworkPolicy() {
  cat <<EOF
KIND:     GlobalNetworkPolicy
VERSION:  crd.projectcalico.org/v1

DESCRIPTION:
     <empty>
EOF
}

explain-GlobalNetworkSet() {
  cat <<EOF
KIND:     GlobalNetworkSet
VERSION:  crd.projectcalico.org/v1

DESCRIPTION:
     <empty>
EOF
}

explain-HostEndpoint() {
  cat <<EOF
KIND:     HostEndpoint
VERSION:  crd.projectcalico.org/v1

DESCRIPTION:
     <empty>
EOF
}

explain-IPAMBlock() {
  cat <<EOF
KIND:     IPAMBlock
VERSION:  crd.projectcalico.org/v1

DESCRIPTION:
     <empty>
EOF
}

explain-IPAMConfig() {
  cat <<EOF
KIND:     IPAMConfig
VERSION:  crd.projectcalico.org/v1

DESCRIPTION:
     <empty>
EOF
}

explain-IPAMHandle() {
  cat <<EOF
KIND:     IPAMHandle
VERSION:  crd.projectcalico.org/v1

DESCRIPTION:
     <empty>
EOF
}

explain-IPPool() {
  cat <<EOF
KIND:     IPPool
VERSION:  crd.projectcalico.org/v1

DESCRIPTION:
     <empty>
EOF
}

explain-NetworkPolicy() {
  cat <<EOF
KIND:     NetworkPolicy
VERSION:  extensions/v1beta1

DESCRIPTION:
     DEPRECATED 1.9 - This group version of NetworkPolicy is deprecated by
     networking/v1/NetworkPolicy. NetworkPolicy describes what network traffic
     is allowed for a set of Pods

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object's metadata. More info:
     https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata

   spec	<Object>
     Specification of the desired behavior for this NetworkPolicy.
EOF
}

explain-NetworkSet() {
  cat <<EOF
KIND:     NetworkSet
VERSION:  crd.projectcalico.org/v1

DESCRIPTION:
     <empty>
EOF
}

explain-AuthCode() {
  cat <<EOF
KIND:     AuthCode
VERSION:  dex.coreos.com/v1

DESCRIPTION:
     <empty>
EOF
}

explain-AuthRequest() {
  cat <<EOF
KIND:     AuthRequest
VERSION:  dex.coreos.com/v1

DESCRIPTION:
     <empty>
EOF
}

explain-Connector() {
  cat <<EOF
KIND:     Connector
VERSION:  dex.coreos.com/v1

DESCRIPTION:
     <empty>
EOF
}

explain-OAuth2Client() {
  cat <<EOF
KIND:     OAuth2Client
VERSION:  dex.coreos.com/v1

DESCRIPTION:
     <empty>
EOF
}

explain-OfflineSessions() {
  cat <<EOF
KIND:     OfflineSessions
VERSION:  dex.coreos.com/v1

DESCRIPTION:
     <empty>
EOF
}

explain-Password() {
  cat <<EOF
KIND:     Password
VERSION:  dex.coreos.com/v1

DESCRIPTION:
     <empty>
EOF
}

explain-RefreshToken() {
  cat <<EOF
KIND:     RefreshToken
VERSION:  dex.coreos.com/v1

DESCRIPTION:
     <empty>
EOF
}

explain-SigningKey() {
  cat <<EOF
KIND:     SigningKey
VERSION:  dex.coreos.com/v1

DESCRIPTION:
     <empty>
EOF
}

explain-Ingress() {
  cat <<EOF
KIND:     Ingress
VERSION:  extensions/v1beta1

DESCRIPTION:
     Ingress is a collection of rules that allow inbound connections to reach
     the endpoints defined by a backend. An Ingress can be configured to give
     services externally-reachable urls, load balance traffic, terminate SSL,
     offer name based virtual hosting etc. DEPRECATED - This group version of
     Ingress is deprecated by networking.k8s.io/v1beta1 Ingress. See the release
     notes for more information.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object's metadata. More info:
     https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata

   spec	<Object>
     Spec is the desired state of the Ingress. More info:
     https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status

   status	<Object>
     Status is the current state of the Ingress. More info:
     https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
EOF
}

explain-PodSecurityPolicy() {
  cat <<EOF
KIND:     PodSecurityPolicy
VERSION:  extensions/v1beta1

DESCRIPTION:
     PodSecurityPolicy governs the ability to make requests that affect the
     Security Context that will be applied to a pod and container. Deprecated:
     use PodSecurityPolicy from policy API Group instead.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object's metadata. More info:
     https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata

   spec	<Object>
     spec defines the policy enforced.
EOF
}

explain-Addon() {
  cat <<EOF
KIND:     Addon
VERSION:  kubeaddons.mesosphere.io/v1alpha1

DESCRIPTION:
     <empty>
EOF
}

explain-MinIOInstance() {
  cat <<EOF
KIND:     MinIOInstance
VERSION:  miniocontroller.min.io/v1beta1

DESCRIPTION:
     <empty>
EOF
}

explain-Alertmanager() {
  cat <<EOF
KIND:     Alertmanager
VERSION:  monitoring.coreos.com/v1

DESCRIPTION:
     <empty>
EOF
}

explain-Prometheus() {
  cat <<EOF
KIND:     Prometheus
VERSION:  monitoring.coreos.com/v1

DESCRIPTION:
     <empty>
EOF
}

explain-PrometheusRule() {
  cat <<EOF
KIND:     PrometheusRule
VERSION:  monitoring.coreos.com/v1

DESCRIPTION:
     <empty>
EOF
}

explain-ServiceMonitor() {
  cat <<EOF
KIND:     ServiceMonitor
VERSION:  monitoring.coreos.com/v1

DESCRIPTION:
     <empty>
EOF
}

explain-RuntimeClass() {
  cat <<EOF
KIND:     RuntimeClass
VERSION:  node.k8s.io/v1beta1

DESCRIPTION:
     RuntimeClass defines a class of container runtime supported in the cluster.
     The RuntimeClass is used to determine which container runtime is used to
     run all containers in a pod. RuntimeClasses are (currently) manually
     defined by a user or cluster provisioner, and referenced in the PodSpec.
     The Kubelet is responsible for resolving the RuntimeClassName reference
     before running the pod. For more details, see
     https://git.k8s.io/enhancements/keps/sig-node/runtime-class.md

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   handler	<string> -required-
     Handler specifies the underlying runtime and configuration that the CRI
     implementation will use to handle pods of this class. The possible values
     are specific to the node & CRI configuration. It is assumed that all
     handlers are available on every node, and handlers of the same name are
     equivalent on every node. For example, a handler called "runc" might
     specify that the runc OCI runtime (using native Linux containers) will be
     used to run the containers in a pod. The Handler must conform to the DNS
     Label (RFC 1123) requirements, and is immutable.

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata
EOF
}

explain-PodDisruptionBudget() {
  cat <<EOF
KIND:     PodDisruptionBudget
VERSION:  policy/v1beta1

DESCRIPTION:
     PodDisruptionBudget is an object to define the max disruption that can be
     caused to a collection of pods

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>

   spec	<Object>
     Specification of the desired behavior of the PodDisruptionBudget.

   status	<Object>
     Most recently observed status of the PodDisruptionBudget.
EOF
}

explain-ClusterRoleBinding() {
  cat <<EOF
KIND:     ClusterRoleBinding
VERSION:  rbac.authorization.k8s.io/v1

DESCRIPTION:
     ClusterRoleBinding references a ClusterRole, but not contain it. It can
     reference a ClusterRole in the global namespace, and adds who information
     via Subject.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object's metadata.

   roleRef	<Object> -required-
     RoleRef can only reference a ClusterRole in the global namespace. If the
     RoleRef cannot be resolved, the Authorizer must return an error.

   subjects	<[]Object>
     Subjects holds references to the objects the role applies to.
EOF
}

explain-ClusterRole() {
  cat <<EOF
KIND:     ClusterRole
VERSION:  rbac.authorization.k8s.io/v1

DESCRIPTION:
     ClusterRole is a cluster level, logical grouping of PolicyRules that can be
     referenced as a unit by a RoleBinding or ClusterRoleBinding.

FIELDS:
   aggregationRule	<Object>
     AggregationRule is an optional field that describes how to build the Rules
     for this ClusterRole. If AggregationRule is set, then the Rules are
     controller managed and direct changes to Rules will be stomped by the
     controller.

   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object's metadata.

   rules	<[]Object>
     Rules holds all the PolicyRules for this ClusterRole
EOF
}

explain-RoleBinding() {
  cat <<EOF
KIND:     RoleBinding
VERSION:  rbac.authorization.k8s.io/v1

DESCRIPTION:
     RoleBinding references a role, but does not contain it. It can reference a
     Role in the same namespace or a ClusterRole in the global namespace. It
     adds who information via Subjects and namespace information by which
     namespace it exists in. RoleBindings in a given namespace only have effect
     in that namespace.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object's metadata.

   roleRef	<Object> -required-
     RoleRef can reference a Role in the current namespace or a ClusterRole in
     the global namespace. If the RoleRef cannot be resolved, the Authorizer
     must return an error.

   subjects	<[]Object>
     Subjects holds references to the objects the role applies to.
EOF
}

explain-Role() {
  cat <<EOF
KIND:     Role
VERSION:  rbac.authorization.k8s.io/v1

DESCRIPTION:
     Role is a namespaced, logical grouping of PolicyRules that can be
     referenced as a unit by a RoleBinding.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object's metadata.

   rules	<[]Object>
     Rules holds all the PolicyRules for this Role
EOF
}

explain-PriorityClass() {
  cat <<EOF
KIND:     PriorityClass
VERSION:  scheduling.k8s.io/v1

DESCRIPTION:
     PriorityClass defines mapping from a priority class name to the priority
     integer value. The value can be any valid integer.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   description	<string>
     description is an arbitrary string that usually provides guidelines on when
     this priority class should be used.

   globalDefault	<boolean>
     globalDefault specifies whether this PriorityClass should be considered as
     the default priority for pods that do not have any priority class. Only one
     PriorityClass can be marked as \`globalDefault\`. However, if more than one
     PriorityClasses exists with their \`globalDefault\` field set to true, the
     smallest value of such global default PriorityClasses will be used as the
     default priority.

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object's metadata. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata

   preemptionPolicy	<string>
     PreemptionPolicy is the Policy for preempting pods with lower priority. One
     of Never, PreemptLowerPriority. Defaults to PreemptLowerPriority if unset.
     This field is alpha-level and is only honored by servers that enable the
     NonPreemptingPriority feature.

   value	<integer> -required-
     The value of this priority class. This is the actual priority that pods
     receive when they have the name of this class in their pod spec.
EOF
}

explain-VolumeSnapshotClass() {
  cat <<EOF
KIND:     VolumeSnapshotClass
VERSION:  snapshot.storage.k8s.io/v1alpha1

DESCRIPTION:
     <empty>
EOF
}

explain-VolumeSnapshotContent() {
  cat <<EOF
KIND:     VolumeSnapshotContent
VERSION:  snapshot.storage.k8s.io/v1alpha1

DESCRIPTION:
     <empty>
EOF
}

explain-VolumeSnapshot() {
  cat <<EOF
KIND:     VolumeSnapshot
VERSION:  snapshot.storage.k8s.io/v1alpha1

DESCRIPTION:
     <empty>
EOF
}

explain-ObservableCluster() {
  cat <<EOF
KIND:     ObservableCluster
VERSION:  stable.mesosphere.com/v1

DESCRIPTION:
     <empty>
EOF
}

explain-CSIDriver() {
  cat <<EOF
KIND:     CSIDriver
VERSION:  storage.k8s.io/v1beta1

DESCRIPTION:
     CSIDriver captures information about a Container Storage Interface (CSI)
     volume driver deployed on the cluster. CSI drivers do not need to create
     the CSIDriver object directly. Instead they may use the
     cluster-driver-registrar sidecar container. When deployed with a CSI driver
     it automatically creates a CSIDriver object representing the driver.
     Kubernetes attach detach controller uses this object to determine whether
     attach is required. Kubelet uses this object to determine whether pod
     information needs to be passed on mount. CSIDriver objects are
     non-namespaced.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object metadata. metadata.Name indicates the name of the CSI
     driver that this object refers to; it MUST be the same name returned by the
     CSI GetPluginName() call for that driver. The driver name must be 63
     characters or less, beginning and ending with an alphanumeric character
     ([a-z0-9A-Z]) with dashes (-), dots (.), and alphanumerics between. More
     info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata

   spec	<Object> -required-
     Specification of the CSI Driver.
EOF
}

explain-CSINode() {
  cat <<EOF
KIND:     CSINode
VERSION:  storage.k8s.io/v1beta1

DESCRIPTION:
     CSINode holds information about all CSI drivers installed on a node. CSI
     drivers do not need to create the CSINode object directly. As long as they
     use the node-driver-registrar sidecar container, the kubelet will
     automatically populate the CSINode object for the CSI driver as part of
     kubelet plugin registration. CSINode has the same name as a node. If the
     object is missing, it means either there are no CSI Drivers available on
     the node, or the Kubelet version is low enough that it doesn't create this
     object. CSINode has an OwnerReference that points to the corresponding node
     object.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     metadata.name must be the Kubernetes node name.

   spec	<Object> -required-
     spec is the specification of CSINode
EOF
}

explain-StorageClass() {
  cat <<EOF
KIND:     StorageClass
VERSION:  storage.k8s.io/v1

DESCRIPTION:
     StorageClass describes the parameters for a class of storage for which
     PersistentVolumes can be dynamically provisioned. StorageClasses are
     non-namespaced; the name of the storage class according to etcd is in
     ObjectMeta.Name.

FIELDS:
   allowVolumeExpansion	<boolean>
     AllowVolumeExpansion shows whether the storage class allow volume expand

   allowedTopologies	<[]Object>
     Restrict the node topologies where volumes can be dynamically provisioned.
     Each volume plugin defines its own supported topology specifications. An
     empty TopologySelectorTerm list means there is no topology restriction.
     This field is only honored by servers that enable the VolumeScheduling
     feature.

   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object's metadata. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata

   mountOptions	<[]string>
     Dynamically provisioned PersistentVolumes of this storage class are created
     with these mountOptions, e.g. ["ro", "soft"]. Not validated - mount of the
     PVs will simply fail if one is invalid.

   parameters	<map[string]string>
     Parameters holds the parameters for the provisioner that should create
     volumes of this storage class.

   provisioner	<string> -required-
     Provisioner indicates the type of the provisioner.

   reclaimPolicy	<string>
     Dynamically provisioned PersistentVolumes of this storage class are created
     with this reclaimPolicy. Defaults to Delete.

   volumeBindingMode	<string>
     VolumeBindingMode indicates how PersistentVolumeClaims should be
     provisioned and bound. When unset, VolumeBindingImmediate is used. This
     field is only honored by servers that enable the VolumeScheduling feature.
EOF
}

explain-VolumeAttachment() {
  cat <<EOF
KIND:     VolumeAttachment
VERSION:  storage.k8s.io/v1

DESCRIPTION:
     VolumeAttachment captures the intent to attach or detach the specified
     volume to/from the specified node. VolumeAttachment objects are
     non-namespaced.

FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#resources

   kind	<string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds

   metadata	<Object>
     Standard object metadata. More info:
     https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata

   spec	<Object> -required-
     Specification of the desired attach/detach volume behavior. Populated by
     the Kubernetes system.

   status	<Object>
     Status of the VolumeAttachment request. Populated by the entity completing
     the attach or detach operation, i.e. the external-attacher.
EOF
}

explain-Backup() {
  cat <<EOF
KIND:     Backup
VERSION:  velero.io/v1

DESCRIPTION:
     <empty>
EOF
}

explain-BackupStorageLocation() {
  cat <<EOF
KIND:     BackupStorageLocation
VERSION:  velero.io/v1

DESCRIPTION:
     <empty>
EOF
}

explain-DeleteBackupRequest() {
  cat <<EOF
KIND:     DeleteBackupRequest
VERSION:  velero.io/v1

DESCRIPTION:
     <empty>
EOF
}

explain-DownloadRequest() {
  cat <<EOF
KIND:     DownloadRequest
VERSION:  velero.io/v1

DESCRIPTION:
     <empty>
EOF
}

explain-PodVolumeBackup() {
  cat <<EOF
KIND:     PodVolumeBackup
VERSION:  velero.io/v1

DESCRIPTION:
     <empty>
EOF
}

explain-PodVolumeRestore() {
  cat <<EOF
KIND:     PodVolumeRestore
VERSION:  velero.io/v1

DESCRIPTION:
     <empty>
EOF
}

explain-ResticRepository() {
  cat <<EOF
KIND:     ResticRepository
VERSION:  velero.io/v1

DESCRIPTION:
     <empty>
EOF
}

explain-Restore() {
  cat <<EOF
KIND:     Restore
VERSION:  velero.io/v1

DESCRIPTION:
     <empty>
EOF
}

explain-Schedule() {
  cat <<EOF
KIND:     Schedule
VERSION:  velero.io/v1

DESCRIPTION:
     <empty>
EOF
}

explain-ServerStatusRequest() {
  cat <<EOF
KIND:     ServerStatusRequest
VERSION:  velero.io/v1

DESCRIPTION:
     <empty>
EOF
}

explain-VolumeSnapshotLocation() {
  cat <<EOF
KIND:     VolumeSnapshotLocation
VERSION:  velero.io/v1

DESCRIPTION:
     <empty>
EOF
}

explain-Help() {
  cat <<EOF
kbk explain usage:
  explain <resource-kind> - Print metadata about specific resource types. This is useful for learning about the resource.
EOF
}

case "${1}" in
  explain | e )
    case "$(echo "${2}" | awk '{print tolower($0)}')" in
      help | -h | --h | -help | --help | "" ) explain-Help;;
      addon | addons ) explain-Addon;;
      alertmanager | alertmanagers ) explain-Alertmanager;;
      apiservice | apiservices ) explain-APIService;;
      authcode | authcodes ) explain-AuthCode;;
      authrequest | authrequests ) explain-AuthRequest;;
      backup | backups ) explain-Backup;;
      backupstoragelocation | backupstoragelocations ) explain-BackupStorageLocation;;
      bgpconfiguration | bgpconfigurations ) explain-BGPConfiguration;;
      bgppeer | bgppeers ) explain-BGPPeer;;
      binding | bindings ) explain-Binding;;
      blockaffinity | blockaffinities ) explain-BlockAffinity;;
      certificatesigningrequest | certificatesigningrequests | csr | csrs ) explain-CertificateSigningRequest;;
      clusterinformation | clusterinformations ) explain-ClusterInformation;;
      clusterrolebinding | clusterrolebindings ) explain-ClusterRoleBinding;;
      clusterrole | clusterroles ) explain-ClusterRole;;
      componentstatus | componentstatuses | cs ) explain-ComponentStatus;;
      configmap | configmaps | cm ) explain-ConfigMap;;
      connector | connectors ) explain-Connector;;
      controllerrevision | controllerrevisions ) explain-ControllerRevision;;
      cronjob | cronjobs | cj | cjs ) explain-CronJob;;
      csidriver | csidrivers ) explain-CSIDriver;;
      csinode | csinodes ) explain-CSINode;;
      customresourcedefinition | customresourcedefinitions | crd | crds ) explain-CustomResourceDefinition;;
      daemonset | daemonsets | ds ) explain-DaemonSet;;
      deletebackuprequest | deletebackuprequests ) explain-DeleteBackupRequest;;
      deployment | deployments | deploy | deploys ) explain-Deployment;;
      downloadrequest | downloadrequests ) explain-DownloadRequest;;
      endpoint | endpoints | ep ) explain-Endpoints;;
      event | events | ev | evs ) explain-Event;;
      felixconfiguration | felixconfigurations ) explain-FelixConfiguration;;
      globalnetworkpolicy | globalnetworkpolicies ) explain-GlobalNetworkPolicy;;
      globalnetworkset | globalnetworksets ) explain-GlobalNetworkSet;;
      horizontalpodautoscaler | horizontalpodautoscalers | hpa | hpas ) explain-HorizontalPodAutoscaler;;
      hostendpoint | hostendpoints ) explain-HostEndpoint;;
      ingress | ingresses | ing | ings ) explain-Ingress;;
      ipamblock | ipamblocks ) explain-IPAMBlock;;
      ipamconfig | ipamconfigs ) explain-IPAMConfig;;
      ipamhandle | ipamhandles ) explain-IPAMHandle;;
      ippool | ippools ) explain-IPPool;;
      job | jobs ) explain-Job;;
      lease | leases ) explain-Lease;;
      limitrange | limitranges | limit | limits ) explain-LimitRange;;
      localsubjectaccessreview | localsubjectaccessreviews ) explain-LocalSubjectAccessReview;;
      minioinstance | minioinstances ) explain-MinIOInstance;;
      mutatingwebhookconfiguration | mutatingwebhookconfigurations ) explain-MutatingWebhookConfiguration;;
      namespace | namespaces | ns ) explain-Namespace;;
      networkpolicy | networkpolicies | netpol | netpols ) explain-NetworkPolicy;;
      networkset | networksets ) explain-NetworkSet;;
      node | nodes | no ) explain-Node;;
      oauth2client | oauth2clients ) explain-OAuth2Client;;
      observablecluster | observableclusters | oc | ocs ) explain-ObservableCluster;;
      offlinesessions | offlinesessionses | offlinesession ) explain-OfflineSessions;;
      password | passwords ) explain-Password;;
      persistentvolumeclaim | persistentvolumeclaims | pvc | pvcs ) explain-PersistentVolumeClaim;;
      persistentvolume | persistentvolumes | pv | pvs ) explain-PersistentVolume;;
      poddisruptionbudget | poddisruptionbudgets | pdb | pdbs ) explain-PodDisruptionBudget;;
      pod | pods | po ) explain-Pod;;
      podsecuritypolicy | podsecuritypolicies | psp | psps ) explain-PodSecurityPolicy;;
      podtemplate | podtemplates ) explain-PodTemplate;;
      podvolumebackup | podvolumebackups ) explain-PodVolumeBackup;;
      podvolumerestore | podvolumerestores ) explain-PodVolumeRestore;;
      priorityclass | priorityclasses | pc | pcs ) explain-PriorityClass;;
      prometheus | prometheuses ) explain-Prometheus;;
      prometheusrule | prometheusrules ) explain-PrometheusRule;;
      refreshtoken | refreshtokens ) explain-RefreshToken;;
      replicaset | replicasets | rs ) explain-ReplicaSet;;
      replicationcontroller | replicationcontrollers | rc ) explain-ReplicationController;;
      resourcequota | resourcequotas | quota | quotas ) explain-ResourceQuota;;
      resticrepository | resticrepositories ) explain-ResticRepository;;
      restore | restores ) explain-Restore;;
      rolebinding | rolebindings ) explain-RoleBinding;;
      role | roles ) explain-Role;;
      runtimeclass | runtimeclasses ) explain-RuntimeClass;;
      schedule | schedules ) explain-Schedule;;
      secret | secrets ) explain-Secret;;
      selfsubjectaccessreview | selfsubjectaccessreviews ) explain-SelfSubjectAccessReview;;
      selfsubjectrulesreview | selfsubjectrulesreviews ) explain-SelfSubjectRulesReview;;
      serverstatusrequest | serverstatusrequests ) explain-ServerStatusRequest;;
      serviceaccount | serviceaccounts | sa | sas ) explain-ServiceAccount;;
      servicemonitor | servicemonitors ) explain-ServiceMonitor;;
      service | services | svc | svcs ) explain-Service;;
      signingkey | signingkeies | signingkeys ) explain-SigningKey;;
      statefulset | statefulsets | sts ) explain-StatefulSet;;
      storageclass | storageclasses | sc | scs ) explain-StorageClass;;
      subjectaccessreview | subjectaccessreviews ) explain-SubjectAccessReview;;
      tokenreview | tokenreviews ) explain-TokenReview;;
      validatingwebhookconfiguration | validatingwebhookconfigurations ) explain-ValidatingWebhookConfiguration;;
      volumeattachment | volumeattachments ) explain-VolumeAttachment;;
      volumesnapshotclass | volumesnapshotclasses ) explain-VolumeSnapshotClass;;
      volumesnapshotcontent | volumesnapshotcontents ) explain-VolumeSnapshotContent;;
      volumesnapshotlocation | volumesnapshotlocations ) explain-VolumeSnapshotLocation;;
      volumesnapshot | volumesnapshots ) explain-VolumeSnapshot;;
      * ) echo "The ${2} resource kind is currently unsupported in kbk."
    esac
    ;;
esac

preflight() {
  #####
  # jq/yq pre-flight checks
  #####
  if [[ -z $(command -v yq) ]]; then
    echo "ERROR: 'yq' not found. Please install yq and add it to your PATH to continue."
    exit 1
  elif [[ -z $(command -v jq) ]]; then
    echo "ERROR: 'jq' not found. Please install yq and add it to your PATH to continue."
    exit 1 
  fi

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
    API_RESOURCES_DIR=$(find "${BUNDLE_ROOT}" -name 'api-resources' -type d)
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

#####
# Get
#####

get-API-Resources() {
  # TODO - improve this to be more like `kubectl api-resources` e.g.,  show api group, namespaced bool, and kind (if possible)
  find "${API_RESOURCES_DIR}" -name "*.yaml" -type f -exec basename {} \; | cut -d '.' -f 1 | sort -u
}

get-Addon() {
  (echo "NAMESPACE~NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'addons.*.yaml' -type f -exec yq -r '"\(.items[].metadata | .namespace + "~" + .name + "~" + (.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-Alertmanager() {
  (echo "NAMESPACE~NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'alertmanagers.*.yaml' -type f -exec yq -r '"\(.items[].metadata | .namespace + "~" + .name + "~" + (.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-APIService() {
  (echo "NAME~SERVICE~AVAILABLE~CREATED"
  find "${API_RESOURCES_DIR}" -name 'apiservices.*.yaml' -type f -exec yq -r '"\(.items[] | .metadata.name + "~" + (if .status.conditions[] | select(.type == "Available") | .reason == "Local" then .status.conditions[] | select(.type == "Available") | .reason elif .spec.service != null then .spec.service | .namespace + "/" + .name  else "<none>" end) + "~" + (.status.conditions[] | select(.type == "Available") | .status) + "~" + (.metadata.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-AuthCode() {
  # TODO test examples for this (not available in default bundle)
  (echo "NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'authcodes*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .name + "~" + (.creationTimestamp | tostring)))"' {} \;) | column -t -s '~'
}

get-AuthRequest() {
  # TODO test examples for this (not available in default bundle)
  (echo "NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'authrequests*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .name + "~" + (.creationTimestamp | tostring)))"' {} \;) | column -t -s '~'
}

get-Backup() {
  (echo "NAMESPACE~NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'backups.*.yaml' -type f -exec yq -r '"\(.items[].metadata | .namespace + "~" + .name + "~" + (.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-BackupStorageLocation() {
  (echo "NAMESPACE~NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'backupstoragelocations.*.yaml' -type f -exec yq -r '"\(.items[].metadata | .namespace + "~" + .name + "~" + (.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-BGPConfiguration() {
  (echo "NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'bgpconfigurations*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .name + "~" + (.creationTimestamp | tostring)))"' {} \;) | column -t -s '~'
}

get-BGPPeer() {
  (echo "NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'bgppeers*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .name + "~" + (.creationTimestamp | tostring)))"' {} \;) | column -t -s '~'
}

get-Binding() {
  # TODO test examples for this (not available in default bundle)
  # Error from server (NotFound): Unable to list "/v1, Resource=bindings": the server could not find the requested resource
  (echo "NAMESPACE~NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'bindings*.yaml' -type f -exec yq -r '"\(.items[].metadata | .namespace + "~" + .name + "~" + (.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-BlockAffinity() {
  (echo "NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'blockaffinities.*.yaml' -type f -exec yq -r '"\(.items[].metadata | .name + "~" + (.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-CertificateSigningRequest() {
  (echo "NAME~APPROVED~CREATED"
  find "${API_RESOURCES_DIR}" -name 'certificatesigningrequests.*.yaml' -type f -exec yq -r '"\(.items[] | .metadata.name + "~" + (.status.conditions[] | select(.type == "Approved") | .reason) + "~" + (.metadata.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-ClusterInformation() {
  (echo "NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'clusterinformations.*.yaml' -type f -exec yq -r '"\(.items[].metadata | .name + "~" + (.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-ClusterRoleBinding() {
  # TODO - fix this to be the same as -A -o wide...
  # NAME~CREATED~ROLE~USERS~GROUPS~SERVICEACCOUNTS
  (echo "NAME~CREATED~ROLE"
  find "${API_RESOURCES_DIR}" -name 'clusterrolebindings*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .name + "~" + (.creationTimestamp | tostring)) + "~" + (.roleRef | .kind + "/" + .name))"' {} \;) | column -t -s '~'
}

get-ClusterRole() {
  (echo "NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'clusterroles.*.yaml' -type f -exec yq -r '"\(.items[].metadata | .name + "~" + (.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-ComponentStatus() {
  # TODO - test where/how errors manifest in here
  (echo "NAME~STATUS~MESSAGE~ERROR"
  find "${API_RESOURCES_DIR}" -name 'componentstatuses*.yaml' -type f -exec yq -r '"\(.items[] | .metadata.name + "~" + (if .conditions[] | select(.type == "Healthy") .status == "True" then "Healthy" else "NotHealthy" end) + "~" + .conditions[].message)"' {} \;) | column -t -s '~'
}

get-ConfigMap() {
  (echo "NAMESPACE~NAME~DATA~CREATED"
  find "${API_RESOURCES_DIR}" -name 'configmaps*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name) + "~" + (.data | length | tostring) + "~" + (.metadata.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-Connector() {
  # TODO test examples for this (not available in default bundle)
  (echo "NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'connectors*.yaml' -type f -exec yq -r '"\(.items[].metadata | .name + "~" + (.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-ControllerRevision() {
  (echo "NAMESPACE~NAME~CONTROLLER~REVISION~CREATED"
  find "${API_RESOURCES_DIR}" -name 'controllerrevisions.*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name + "~" + (.ownerReferences[] | .kind + "/" + .name)) + "~" + (.revision | tostring) + "~" + (.metadata.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-CronJob() {
  (echo "NAMESPACE~NAME~SCHEDULE~SUSPEND~ACTIVE~LAST SCHEDULE~CREATED~CONTAINERS~IMAGES~SELECTOR"
  find "${API_RESOURCES_DIR}" -name 'cronjobs*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name) + "~" + (.spec | .schedule + "~" + (.suspend | tostring)) + "~" + (.status.active? | length | tostring) + "~" + (.metadata.creationTimestamp | tostring) + "~" + (.status.lastScheduleTime | tostring) + "~" + (.spec.jobTemplate.spec.template.spec.containers | (map(.name) | join(",")) + "~" + (map(.image) | join(","))) + "~" + (.spec.template.spec | if .nodeSelector? != null then .nodeSelector | tostring else "<none>" end))"' {} \;) | column -t -s '~'
}

get-CSIDriver() {
  (echo "NAME~APIVERSION~CREATED"
  find "${API_RESOURCES_DIR}" -name 'csidrivers*.yaml' -type f -exec yq -r '"\(.items[] | .metadata.name + "~" + .apiVersion + "~" + (.metadata.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-CSINode() {
  (echo "NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'csinodes*.yaml' -type f -exec yq -r '"\(.items[].metadata | .name + "~" + (.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-CustomResourceDefinition() {
  (echo "NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'customresourcedefinitions*.yaml' -type f -exec yq -r '"\(.items[].metadata | .name + "~" + (.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

# TODO - Verify this for other selectors
get-DaemonSet() {
  (echo "NAMESPACE~NAME~DESIRED~CURRENT~READY~UP-TO-DATE~AVAILABLE~NODE SELECTOR~CREATED~CONTAINERS~IMAGES"
  find "${API_RESOURCES_DIR}" -name 'daemonsets.*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name) + "~" + (.status | (.desiredNumberScheduled | tostring) + "~" + (.currentNumberScheduled | tostring) + "~" + (.numberReady | tostring) + "~" + (.updatedNumberScheduled | tostring) + "~" + (.numberAvailable | tostring)) + "~" + (.spec.template.spec | if .nodeSelector? != null then .nodeSelector | tostring else "<none>" end) + "~" + (.metadata.creationTimestamp | tostring) + "~" + (.spec.template.spec.containers | (map(.name) | join(",")) + "~" + (map(.image) | join(","))))"' {} \; | sort -u -k 1) | column -t -s '~'
}

get-DeleteBackupRequest() {
  # TODO test examples for this (not available in default bundle) (assuming there is a namespace here based on backups being scoped to a namespace)
  (echo "NAMESPACE~NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'deletebackuprequests*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name + "~" + (.creationTimestamp | tostring)))"' {} \;) | column -t -s '~'
}

get-Deployment() {
  # TODO add selector back https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#resources-that-support-set-based-requirements
  # echo "NAMESPACE~NAME~READY~UP-TO-DATE~AVAILABLE~CREATED~CONTAINERS~IMAGES"
  (echo "NAMESPACE~NAME~READY~UP-TO-DATE~AVAILABLE~CREATED~CONTAINERS~IMAGES~SELECTOR"
  find "${API_RESOURCES_DIR}" -name 'deployments.*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name) + "~" + (.status | (.readyReplicas | tostring) + "/" + (.replicas | tostring) + "~" + (.updatedReplicas | tostring) + "~" + (.availableReplicas | tostring)) + "~" + (.metadata.creationTimestamp | tostring) + "~" + (.spec.template.spec.containers | (map(.name) | join(",")) + "~" + (map(.image) | join(","))) + "~" + (.spec.selector | if .matchLabels? != null then .matchLabels | tostring else "<none>" end))"' {} \; | sort -u -k 1) | column -t -s '~'
}

get-DownloadRequest() {
  (echo "NAMESPACE~NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'downloadrequests*.yaml' -type f -exec yq -r '"\(.items[].metadata | .namespace + "~" + .name + "~" + (.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-Endpoints() {
  # TODO fix this to more closely match kubectl... ENDPOINTS being <ip>:<port>... However, this is somewhat easier to read with a large number of endpoints
  (echo "NAMESPACE~NAME~ENDPOINTS~PORTS~CREATED"
  find "${API_RESOURCES_DIR}" -name 'endpoints*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name) + "~" + (if .subsets == null then "<none>~<none>" else (.subsets[].addresses | map(.ip) | join(",")) + "~" + (.subsets[].ports | map(.port | tostring) | join(",")) end) + "~" + (.metadata.creationTimestamp | tostring))"' {} \; | sort -u -k 1) | column -t -s '~'
}

get-Event() {
  # TODO - sanity check if this needs to include events.events.k8s.io.yaml (they appear to be redundant) -- there's some weirdness happening in my test bundle where some fields don't get printed even though the yaml and yq seem correct...
  # good doc: https://www.bluematador.com/blog/kubernetes-events-explained
  # NAMESPACE~LAST SEEN~TYPE~REASON~OBJECT~SUBOBJECT~SOURCE~MESSAGE~FIRST SEEN~COUNT~NAME
  # (echo "LAST SEEN~TYPE~REASON~KIND~SOURCE~MESSAGE"
  # find "${API_RESOURCES_DIR}" -name 'events.yaml' -type f -exec yq -r '"\(.items[] | (.lastTimestamp | tostring) + "~" + .type + "~" + .reason + "~" + (.involvedObject | .kind + "~" + .name) + "~" + .message)"' {} \; | sort -k 1) | column -t -s '~'
  (echo "NAMESPACE~LAST SEEN~TYPE~REASON~OBJECT~MESSAGE"
  find "${API_RESOURCES_DIR}" -name 'events.yaml' -type f -exec yq -r '"\(.items[] | (.metadata.namespace) + "~" + (.lastTimestamp | tostring) + "~" + .type + "~" + .reason + "~" + (.involvedObject | .kind + "/" + .name) + "~" + .message)"' {} \; | sort -n -t '~' -k2) | column -t -s '~'
}

get-EventWide() {
  (echo "NAMESPACE~LAST SEEN~TYPE~REASON~OBJECT~SUBOBJECT~SOURCE~MESSAGE~FIRST SEEN~COUNT~NAME"
  find "${API_RESOURCES_DIR}" -name 'events.yaml' -type f -exec yq -r '"\(.items[] | (.metadata.namespace) + "~" + (.lastTimestamp | tostring) + "~" + .type + "~" + .reason + "~" + (.involvedObject | .kind + "/" + .name + "~" + (if .fieldPath? then .fieldPath else " " end)) + "~" + (.source | .component + (if .host? then ", " + .host else "" end)) + "~" + .message + "~" + (.firstTimestamp | tostring) + "~" + (.count | tostring) + "~" + .metadata.name)"' {} \;) | column -t -s '~'
}

get-FelixConfiguration() {
  (echo "NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'felixconfigurations*.yaml' -type f -exec yq -r '"\(.items[].metadata | .name + "~" + (.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-GlobalNetworkPolicy() {
  (echo "NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'globalnetworkpolicies*.yaml' -type f -exec yq -r '"\(.items[].metadata | .name + "~" + (.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-GlobalNetworkSet() {
  (echo "NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'globalnetworksets*.yaml' -type f -exec yq -r '"\(.items[].metadata | .name + "~" + (.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-HorizontalPodAutoscaler() {
  # TODO - maybe add support for targets(metrics)...
  # can pull metrics from values then use fromjson to parse
  # see: https://stackoverflow.com/questions/34340549/convert-string-to-json-in-jq
  (echo "NAMESPACE~NAME~REFERENCE~MINPODS~MAXPODS~REPLICAS~CREATED"
  find "${API_RESOURCES_DIR}" -name 'horizontalpodautoscalers*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name) + "~" + (.spec.scaleTargetRef | .kind + "/" + .name) + "~" + (.spec | (.minReplicas | tostring) + "~" + (.maxReplicas | tostring)) + "~" + (.status.currentReplicas | tostring) + "~" + (.metadata.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-HostEndpoint() {
  (echo "NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'hostendpoints*.yaml' -type f -exec yq -r '"\(.items[].metadata | .name + "~" + (.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-Ingress() {
  # TODO - add/fix ports
  # echo "NAMESPACE~NAME~HOSTS~ADDRESS~PORTS~CREATED"
  (echo "NAMESPACE~NAME~HOSTS~ADDRESS~CREATED"
  find "${API_RESOURCES_DIR}" -name 'ingress*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name) + "~" + (.spec | if .rules[].host? != null then .rules | map(.host) | join(",") else "*" end) + "~" + (.status.loadBalancer? | if .ingress[].hostname != null then .ingress | map(.hostname) | join(",") else "<none>" end) + "~" + (.metadata.creationTimestamp | tostring))"' {} \; | sort -u -k 1) | column -t -s '~'
}

get-IPAMBlock() {
  (echo "NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'ipamblocks*.yaml' -type f -exec yq -r '"\(.items[].metadata | .name + "~" + (.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-IPAMConfig() {
  (echo "NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'ipamconfigs*.yaml' -type f -exec yq -r '"\(.items[].metadata | .name + "~" + (.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-IPAMHandle() {
  (echo "NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'ipamhandles*.yaml' -type f -exec yq -r '"\(.items[].metadata | .name + "~" + (.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-IPPool() {
  (echo "NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'ippool*.yaml' -type f -exec yq -r '"\(.items[].metadata | .name + "~" + (.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-Job() {
  # TODO - Duration needs a sanity check....
  (echo "NAMESPACE~NAME~COMPLETIONS~DURATION~CREATED~CONTAINERS~IMAGES~SELECTOR"
  find "${API_RESOURCES_DIR}" -name 'jobs*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name) + "~" + ((.status.succeeded | tostring) + "/" + (.spec.completions | tostring)) + "~" + (((.status.completionTime | fromdate) - (.status.startTime | fromdate) | tostring) + "s") + "~" + (.metadata.creationTimestamp | tostring) + "~" + (.spec.template.spec.containers | (map(.name) | join(",")) + "~" + (map(.image) | join(","))) + "~" + (.spec.template.spec | if .nodeSelector? != null then .nodeSelector | tostring else "<none>" end))"' {} \;) | column -t -s '~'
}

get-Lease() {
  (echo "NAMESPACE~NAME~HOLDER~CREATED"
  find "${API_RESOURCES_DIR}" -name 'leases*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name) + "~" + .spec.holderIdentity + "~" + (.metadata.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-LimitRange() {
  (echo "NAMESPACE~NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'limitranges*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name) + "~" + (.metadata.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-LocalSubjectAccessReview() {
  echo "This method is not allowed on the requested resource."
}

get-MinIOInstance() {
  (echo "NAMESPACE~NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'minioinstances*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name + "~" + (.creationTimestamp | tostring)))"' {} \;) | column -t -s '~'
}

get-MutatingWebhookConfiguration() {
  (echo "NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'mutatingwebhookconfigurations*.yaml' -type f -exec yq -r '"\(.items[].metadata | .name + "~" + (.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-Namespace() {
  (echo "NAME~STATUS~CREATED"
  find "${API_RESOURCES_DIR}" -name 'namespaces*.yaml' -type f -exec yq -r '"\(.items[] | .metadata.name + "~" + .status.phase + "~" + (.metadata.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-NetworkPolicy() {
  # https://github.com/stedolan/jq/issues/785#issuecomment-101411519
  (echo "NAMESPACE~NAME~POD-SELECTOR~CREATED"
  find "${API_RESOURCES_DIR}" -name 'networkpolicies*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name) + "~" + (.spec.podSelector.matchLabels | tostring) + "~" + (.metadata.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-NetworkSet() {
  (echo "NAMESPACE~NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'networksets*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name + "~" + (.creationTimestamp | tostring)))"' {} \;) | column -t -s '~'
}

get-Node() {
  # TODO - refactor this
  (echo "NAME~STATUS~ROLES~CREATED~VERSION~INTERNAL-IP~EXTERNAL-IP~OS-IMAGE~KERNEL-VERSION~CONTAINER-RUNTIME"
  find "${API_RESOURCES_DIR}" -name 'nodes*.yaml' -type f -exec yq -r '"\(.items[] | .metadata.name + "~" + (.status.conditions[] | select(.type == "Ready") | if .status == "True" then "Ready" else "NotReady" end) + "~" + (.metadata.labels? | if ."node-role.kubernetes.io/master"? then "master" else "worker" end) + "~" + (.metadata.creationTimestamp | tostring) + "~" + (.status.nodeInfo.kubeletVersion) + "~" + (.status.addresses[] | select(.type == "InternalIP") .address) + "~" + (if (.status.addresses[]? | select(.type? == "ExternalIP") .address?) then .status.addresses[]? | select(.type? == "ExternalIP") .address? else "<none>" end) + "~" + (.status.nodeInfo | .osImage + "~" + .kernelVersion + "~" + .containerRuntimeVersion))"' {} \;) | column -t -s '~'
}

get-OAuth2Client() {
  # TODO test examples for this (not available in default bundle)
  (echo "NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'oauth2clients*.yaml' -type f -exec yq -r '"\(.items[].metadata | .name + "~" + (.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-ObservableCluster() {
  (echo "NAMESPACE~NAME~DISPLAY NAME~API SERVER~AUTHENTICATION SECRET~CREATED"
  find "${API_RESOURCES_DIR}" -name 'observablecluster*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name) + "~" + (.spec | .displayName + "~" + .apiServer + "~" + .authenticationSecretName) + "~" + (.metadata.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-OfflineSessions() {
  # TODO test examples for this (not available in default bundle)
  (echo "NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'offlinesessions*.yaml' -type f -exec yq -r '"\(.items[].metadata | .name + "~" + (.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-Password() {
  # TODO test examples for this (not available in default bundle)
  (echo "NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'passwords*.yaml' -type f -exec yq -r '"\(.items[].metadata | .name + "~" + (.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-PersistentVolumeClaim() {
  (echo "NAMESPACE~NAME~STATUS~VOLUME~CAPACITY~ACCESS MODES~STORAGECLASS~CREATED~VOLUMEMODE"
  find "${API_RESOURCES_DIR}" -name 'persistentvolumeclaims*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name) + "~" + .status.phase + "~" + .spec.volumeName + "~" + .status.capacity.storage + "~" + (.status | [.accessModes | tostring] | join(",")) + "~" + .spec.storageClassName + "~" + (.metadata.creationTimestamp | tostring) + "~" + .spec.volumeMode)"' {} \;) | column -t -s '~'
}

get-PersistentVolume() {
  # TODO - add back 'reason' -- this is empty thus far and needs testing
  # echo "NAME~CAPACITY~ACCESS MODES~RECLAIM POLICY~STATUS~CLAIM~STORAGECLASS~REASON~CREATED~VOLUMEMODE"
  (echo "NAME~CAPACITY~ACCESS MODES~RECLAIM POLICY~STATUS~CLAIM~STORAGECLASS~CREATED~VOLUMEMODE"
  find "${API_RESOURCES_DIR}" -name 'persistentvolumes*.yaml' -type f -exec yq -r '"\(.items[] | .metadata.name + "~" + .spec.capacity.storage + "~" + (.spec | [.accessModes | tostring] | join(",")) + "~" + .spec.persistentVolumeReclaimPolicy + "~" + .status.phase + "~" + (.spec.claimRef | .namespace + "/" + .name) + "~" + .spec.storageClassName + "~" + (.metadata.creationTimestamp | tostring) + "~" + .spec.volumeMode)"' {} \;) | column -t -s '~'
}

get-PodDisruptionBudget() {
  (echo "NAMESPACE~NAME~MIN AVAILABLE~MAX UNAVAILABLE~ALLOWED DISRUPTIONS~CREATED"
  find "${API_RESOURCES_DIR}" -name 'poddisruptionbudgets*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name) + "~" + (.spec | (.minAvailable | tostring) + "~" + (if .maxUnavailable? then (.maxUnavailable | tostring) else "N/A" end)) + "~" + (.status.disruptionsAllowed | tostring) + "~" + (.metadata.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-Pod() {
  # TODO - figure out why this is complaining. Test 'nominated node' and 'readiness gates'
  # echo "NAMESPACE~NAME~READY~STATUS~RESTARTS~CREATED~IP~NODE~NOMINATED NODE~READINESS GATES"
  (echo "NAMESPACE~NAME~READY~STATUS~RESTARTS~CREATED~IP~NODE"
  find "${API_RESOURCES_DIR}" -name 'pods.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name) + "~" + ([.status.containerStatuses[]? | select(.ready == true) | .ready] | length | tostring) + "/" + ([.status.containerStatuses[]?.ready] | length | tostring) + "~" + (if .status.conditions[] | select(.type == "Ready") | .status == "True" then .status.phase else .status.conditions[] | select(.type == "Ready") | .reason end) + "~" + ((reduce .status.containerStatuses[]? as $cr (0; . + ($cr | .restartCount) )) | tostring) + "~" + .metadata.creationTimestamp + "~" + (if .status.podIP? != null then .status.podIP? else "<none>" end) + "~" + (if .spec.nodeName? != null then .spec.nodeName? else "<none>" end))"' {} \;) | column -t -s '~'
}

get-PodSecurityPolicy() {
  (echo "NAME~PRIV~CAPS~SELINUX~RUNASUSER~FSGROUP~SUPGROUP~READONLYROOTFS~VOLUMES"
  find "${API_RESOURCES_DIR}" -name 'podsecuritypolicies*.yaml' -type f -exec yq -r '"\(.items[] | .metadata.name + "~" + (.spec | (if .privileged? == true then "true" else "false" end) + "~" + " " + "~" + .seLinux.rule + "~" + .runAsUser.rule + "~" + .fsGroup.rule + "~" + .supplementalGroups.rule + "~" + (if .readOnlyRootFilesystem? == true then "true" else "false" end)) + "~" + (.spec | [.volumes | tostring] | join(",")))"' {} \; | sort -u) | column -t -s '~'
}

get-PodTemplate() {
  # TODO test examples for this (not available in default bundle)
  (echo "NAMESPACE~NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'networksets*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name + "~" + (.creationTimestamp | tostring)))"' {} \;) | column -t -s '~'
}

get-PodVolumeBackup() {
  # TODO test examples for this (not available in default bundle)
  (echo "NAMESPACE~NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'podvolumebackups*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name + "~" + (.creationTimestamp | tostring)))"' {} \;) | column -t -s '~'
}

get-PodVolumeRestore() {
  # TODO test examples for this (not available in default bundle)
  (echo "NAMESPACE~NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'podvolumerestores*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name + "~" + (.creationTimestamp | tostring)))"' {} \;) | column -t -s '~'
}

get-PriorityClass() {
  (echo "NAME~VALUE~GLOBAL-DEFAULT~CREATED"
  find "${API_RESOURCES_DIR}" -name 'priorityclasses*.yaml' -type f -exec yq -r '"\(.items[] | .metadata.name + "~" + (.value | tostring) + "~" + (if .globalDefault? == true then "true" else "false" end) + "~" + (.metadata.creationTimestamp | tostring))"' {} \; | sort -u) | column -t -s '~'
}

get-Prometheus() {
  (echo "NAMESPACE~NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'prometheuses*.yaml' -type f -exec yq -r '"\(.items[].metadata | .namespace + "~" + .name + "~" + (.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-PrometheusRule() {
  (echo "NAMESPACE~NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'prometheusrule*.yaml' -type f -exec yq -r '"\(.items[].metadata | .namespace + "~" + .name + "~" + (.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-RefreshToken() {
  (echo "NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'refreshtokens*.yaml' -type f -exec yq -r '"\(.items[].metadata | .name + "~" + (.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-ReplicaSet() {
  # TODO - verify this for other selectors
  (echo "NAMESPACE~NAME~DESIRED~CURRENT~READY~CREATED~CONTAINERS~IMAGES~SELECTOR"
  find "${API_RESOURCES_DIR}" -name 'replicasets*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name) + "~" + (.spec.replicas | tostring) + "~" + (.status | (.availableReplicas | tostring) + "~" + (.readyReplicas | tostring)) + "~" + (.metadata.creationTimestamp | tostring) + "~" + (.spec.template.spec.containers | (map(.name) | join(",")) + "~" + (map(.image) | join(","))) + "~" + (.spec.selector | if .matchLabels? != null then .matchLabels | tostring else "<none>" end))"' {} \; | sort -u) | column -t -s '~'
}

get-ReplicationController() {
  (echo "NAMESPACE~NAME~DESIRED~CURRENT~READY~CREATED~CONTAINERS~IMAGES~SELECTOR"
  find "${API_RESOURCES_DIR}" -name 'replicationcontrollers*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name) + "~" + (.spec.replicas | tostring) + "~" + (.status | (.replicas | tostring) + "~" + (.readyReplicas | tostring)) + "~" + (.metadata.creationTimestamp | tostring) + "~" + (.spec.template.spec.containers | (map(.name) | join(",")) + "~" + (map(.image) | join(","))) + "~" + (.spec.selector | if .matchLabels? != null then .matchLabels | tostring else "<none>" end))"' {} \;) | column -t -s '~'
}

get-ResourceQuota() {
  (echo "NAMESPACE~NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'resourcequotas*.yaml' -type f -exec yq -r '"\(.items[].metadata | .namespace + "~" + .name + "~" + (.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-ResticRepository() {
  (echo "NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'resticrepositories*.yaml' -type f -exec yq -r '"\(.items[].metadata | .name + "~" + (.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-Restore() {
  (echo "NAMESPACE~NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'restores*.yaml' -type f -exec yq -r '"\(.items[].metadata | .namespace + "~" + .name + "~" + (.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-RoleBinding() {
  #
  #
  # Try something like this? jq 'map(select(. >= 2))'
  #
  #
  # TODO - Need to fix this to properly show users/groups/serviceaccounts!
  # (echo "NAMESPACE~NAME~CREATED~ROLE~USERS~GROUPS~SERVICEACCOUNTS"
  # find "${API_RESOURCES_DIR}" -name 'rolebindings*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name + "~" + (.creationTimestamp | tostring)) + "~" + (.roleRef | .kind + "/" + .name) + "~" + (select(.subjects[].kind == "User") | .subjects | map(.name) | join(",")))"' {} \;) | column -t -s '~'
  (echo "NAMESPACE~NAME~CREATED~ROLE"
  find "${API_RESOURCES_DIR}" -name 'rolebindings*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name + "~" + (.creationTimestamp | tostring)) + "~" + (.roleRef | .kind + "/" + .name))"' {} \;) | column -t -s '~'
}

get-Role() {
  (echo "NAMESPACE~NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'roles*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name + "~" + (.creationTimestamp | tostring)))"' {} \;) | column -t -s '~'
}

get-RuntimeClass() {
  (echo "NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'runtimeclasses*.yaml' -type f -exec yq -r '"\(.items[].metadata | .name + "~" + (.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-Schedule() {
  (echo "NAMESPACE~NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'schedules*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name + "~" + (.creationTimestamp | tostring)))"' {} \;) | column -t -s '~'
}

get-Secret() {
  echo "*** SECRETS FILE IS NOT VALID YAML - DUMPING FILE(S) ***"
  find "${API_RESOURCES_DIR}" -name 'secrets*.yaml' -type f -exec cat {} \;
  echo "*** SECRETS FILE IS NOT VALID YAML - END DUMPING FILE(S) ***"
}

get-SelfSubjectAccessReview() {
  echo "This method is not allowed on the requested resource."
}

get-SelfSubjectRulesReview() {
  echo "This method is not allowed on the requested resource."
}

get-ServerStatusRequest() {
  (echo "NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'serverstatusrequests*.yaml' -type f -exec yq -r '"\(.items[].metadata | .name + "~" + (.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-ServiceAccount() {
  (echo "NAMESPACE~NAME~SECRETS~CREATED"
  find "${API_RESOURCES_DIR}" -name 'serviceaccounts*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name) + "~" + (.secrets | length | tostring) + "~" + (.metadata.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-ServiceMonitor() {
  (echo "NAMESPACE~NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'servicemonitors*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name + "~" + (.creationTimestamp | tostring)))"' {} \;) | column -t -s '~'
}

get-Service() {
  # TODO fix port/protocol output (maybe here: https://stackoverflow.com/questions/50354926/jq-merge-two-arrays)
  (echo "NAMESPACE~NAME~TYPE~CLUSTER-IP~EXTERNAL-IP~PORT(S)~CREATED~SELECTOR"
  find "${API_RESOURCES_DIR}" -name 'services*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name) + "~" + (.spec | .type + "~" + .clusterIP) + "~" + (.status.loadBalancer? | if has("ingress") then .ingress | map(.hostname) | join(",") else "<none>" end) + "~" + (.spec.ports | [map(.port), map(.protocol)] | tostring) + "~" + (.metadata.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-SigningKey() {
  (echo "NAMESPACE~NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'signingke*s*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name + "~" + (.creationTimestamp | tostring)))"' {} \;) | column -t -s '~'
}

get-StatefulSet() {
  (echo "NAMESPACE~NAME~READY~CREATED~CONTAINERS~IMAGES"
  find "${API_RESOURCES_DIR}" -name 'statefulsets*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name) + "~" + ((.status.readyReplicas | tostring) + "/" + (.spec.replicas | tostring)) + "~" + (.metadata.creationTimestamp | tostring) + "~" + (.spec.template.spec.containers | (map(.name) | join(",")) + "~" + (map(.image) | join(","))))"' {} \;) | column -t -s '~'
}

get-StorageClass() {
  (echo "NAME~PROVISIONER~CREATED"
  find "${API_RESOURCES_DIR}" -name 'storageclasses*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .name + (if .annotations."storageclass.kubernetes.io/is-default-class"? == "true" then " (default)" else null end)) + "~" + .provisioner + "~" + (.metadata.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-SubjectAccessReview() {
  echo "This method is not allowed on the requested resource."
}

get-TokenReview() {
  echo "This method is not allowed on the requested resource."
}

get-ValidatingWebhookConfiguration() {
  (echo "NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'validatingwebhookconfiguration*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .name + "~" + (.creationTimestamp | tostring)))"' {} \;) | column -t -s '~'
}

get-VolumeAttachment() {
  (echo "NAME~ATTACHER~PV~NODE~ATTACHED~CREATED"
  find "${API_RESOURCES_DIR}" -name 'volumeattachments*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .name) + "~" + (.spec | .attacher + "~" + .source.persistentVolumeName + "~" + .nodeName) + "~" + (.status.attached | tostring) + "~" + (.metadata.creationTimestamp | tostring))"' {} \;) | column -t -s '~'
}

get-VolumeSnapshotClass() {
  (echo "NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'volumesnapshotclasses*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .name + "~" + (.creationTimestamp | tostring)))"' {} \;) | column -t -s '~'
}

get-VolumeSnapshotContent() {
  (echo "NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'volumesnapshotcontents*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .name + "~" + (.creationTimestamp | tostring)))"' {} \;) | column -t -s '~'
}

get-VolumeSnapshotLocation() {
  (echo "NAMESPACE~NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'volumesnapshotlocations*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .namespace + "~" + .name + "~" + (.creationTimestamp | tostring)))"' {} \;) | column -t -s '~'
}

get-VolumeSnapshot() {
  (echo "NAME~CREATED"
  find "${API_RESOURCES_DIR}" -name 'volumesnapshots*.yaml' -type f -exec yq -r '"\(.items[] | (.metadata | .name + "~" + (.creationTimestamp | tostring)))"' {} \;) | column -t -s '~'
}

get-Help() {
  cat <<EOF
kbk get usage:
  get <resource-kind> - Reads resources from the cluster and formats them as output.
EOF
}

#####
# Describe
#####
describe-Addon() {
  find "${API_RESOURCES_DIR}" -name 'addons*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-Alertmanager() {
  find "${API_RESOURCES_DIR}" -name 'alertmanagers*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-APIService() {
  find "${API_RESOURCES_DIR}" -name 'apiservices*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-AuthCode() {
  # TODO test examples for this (not available in default bundle)
  find "${API_RESOURCES_DIR}" -name 'authcodes*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-AuthRequest() {
  # TODO test examples for this (not available in default bundle)
  find "${API_RESOURCES_DIR}" -name 'authrequests*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-Backup() {
  find "${API_RESOURCES_DIR}" -name 'backups*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-BackupStorageLocation() {
  find "${API_RESOURCES_DIR}" -name 'backupstoragelocations*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-BGPConfiguration() {
  find "${API_RESOURCES_DIR}" -name 'bgpconfigurations*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-BGPPeer() {
  find "${API_RESOURCES_DIR}" -name 'bgppeers*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-Binding() {
  # TODO test examples for this (not available in default bundle)
  # Error from server (NotFound): Unable to list "/v1, Resource=bindings": the server could not find the requested resource
  find "${API_RESOURCES_DIR}" -name 'bindings*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-BlockAffinity() {
  find "${API_RESOURCES_DIR}" -name 'blockaffinities*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-CertificateSigningRequest() {
  find "${API_RESOURCES_DIR}" -name 'certificatesigningrequests*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-ClusterInformation() {
  find "${API_RESOURCES_DIR}" -name 'clusterinformations*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-ClusterRoleBinding() {
  find "${API_RESOURCES_DIR}" -name 'clusterrolebindings*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-ClusterRole() {
  find "${API_RESOURCES_DIR}" -name 'clusterroles*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-ComponentStatus() {
  find "${API_RESOURCES_DIR}" -name 'componentstatuses*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-ConfigMap() {
  find "${API_RESOURCES_DIR}" -name 'configmaps*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-Connector() {
  # TODO test examples for this (not available in default bundle)
  find "${API_RESOURCES_DIR}" -name 'connectors*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-ControllerRevision() {
  find "${API_RESOURCES_DIR}" -name 'controllerrevisions*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-CronJob() {
  find "${API_RESOURCES_DIR}" -name 'cronjobs*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-CSIDriver() {
  find "${API_RESOURCES_DIR}" -name 'csidrivers*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-CSINode() {
  find "${API_RESOURCES_DIR}" -name 'csinodes*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-CustomResourceDefinition() {
  find "${API_RESOURCES_DIR}" -name 'customresourcedefinitions*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-DaemonSet() {
  find "${API_RESOURCES_DIR}" -name 'daemonsets.apps*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-DeleteBackupRequest() {
  # TODO test examples for this (not available in default bundle)
  find "${API_RESOURCES_DIR}" -name 'deletebackuprequests*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-Deployment() {
  find "${API_RESOURCES_DIR}" -name 'deployments.apps*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-DownloadRequest() {
  find "${API_RESOURCES_DIR}" -name 'downloadrequests*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-Endpoints() {
  find "${API_RESOURCES_DIR}" -name 'endpoints*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-Event() {
  find "${API_RESOURCES_DIR}" -name 'events.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-FelixConfiguration() {
  find "${API_RESOURCES_DIR}" -name 'felixconfigurations*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-GlobalNetworkPolicy() {
  find "${API_RESOURCES_DIR}" -name 'globalnetworkpolicies*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-GlobalNetworkSet() {
  find "${API_RESOURCES_DIR}" -name 'globalnetworksets*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-HorizontalPodAutoscaler() {
  # TODO test examples for this (not available in default bundle)
  find "${API_RESOURCES_DIR}" -name 'horizontalpodautoscalers*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-HostEndpoint() {
  find "${API_RESOURCES_DIR}" -name 'hostendpoints*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-Ingress() {
  find "${API_RESOURCES_DIR}" -name 'ingresses.networking.k8s.io.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-IPAMBlock() {
  find "${API_RESOURCES_DIR}" -name 'ipamblocks*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-IPAMConfig() {
  # TODO test examples for this (not available in default bundle)
  find "${API_RESOURCES_DIR}" -name 'ipamconfigs*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-IPAMHandle() {
  find "${API_RESOURCES_DIR}" -name 'ipamhandles*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-IPPool() {
  find "${API_RESOURCES_DIR}" -name 'ippools*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-Job() {
  find "${API_RESOURCES_DIR}" -name 'jobs*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-Lease() {
  find "${API_RESOURCES_DIR}" -name 'leases*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-LimitRange() {
  # https://kubernetes.io/docs/tasks/administer-cluster/manage-resources/memory-default-namespace/#create-a-limitrange-and-a-pod
  find "${API_RESOURCES_DIR}" -name 'limitranges*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-LocalSubjectAccessReview() {
  echo "This method is not allowed on the requested resource."
}

describe-MinIOInstance() {
  find "${API_RESOURCES_DIR}" -name 'minioinstances*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-MutatingWebhookConfiguration() {
  find "${API_RESOURCES_DIR}" -name 'mutatingwebhookconfigurations*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-Namespace() {
  find "${API_RESOURCES_DIR}" -name 'namespaces*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-NetworkPolicy() {
  find "${API_RESOURCES_DIR}" -name 'networkpolicies*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-NetworkSet() {
  find "${API_RESOURCES_DIR}" -name 'networksets*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-Node() {
  find "${API_RESOURCES_DIR}" -name 'nodes.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-OAuth2Client() {
  # TODO test examples for this (not available in default bundle)
  find "${API_RESOURCES_DIR}" -name 'oauth2clients*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-ObservableCluster() {
  find "${API_RESOURCES_DIR}" -name 'observableclusters*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-OfflineSessions() {
  # TODO test examples for this (not available in default bundle)
  find "${API_RESOURCES_DIR}" -name 'offlinesessions*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-Password() {
  # TODO test examples for this (not available in default bundle)
  find "${API_RESOURCES_DIR}" -name 'passwords*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-PersistentVolumeClaim() {
  find "${API_RESOURCES_DIR}" -name 'persistentvolumeclaims*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-PersistentVolume() {
  find "${API_RESOURCES_DIR}" -name 'persistentvolumes*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-PodDisruptionBudget() {
  find "${API_RESOURCES_DIR}" -name 'poddisruptionbudgets*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-Pod() {
  find "${API_RESOURCES_DIR}" -name 'pods.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-PodSecurityPolicy() {
  find "${API_RESOURCES_DIR}" -name 'podsecuritypolicies.policy.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-PodTemplate() {
  # TODO test examples for this (not available in default bundle)
  find "${API_RESOURCES_DIR}" -name 'podtemplates*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-PodVolumeBackup() {
  # TODO test examples for this (not available in default bundle)
  find "${API_RESOURCES_DIR}" -name 'podvolumebackups*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-PodVolumeRestore() {
  # TODO test examples for this (not available in default bundle)
  find "${API_RESOURCES_DIR}" -name 'podvolumerestores*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-PriorityClass() {
  find "${API_RESOURCES_DIR}" -name 'priorityclasses*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-Prometheus() {
  find "${API_RESOURCES_DIR}" -name 'prometheuses*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-PrometheusRule() {
  find "${API_RESOURCES_DIR}" -name 'prometheusrules*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-RefreshToken() {
  find "${API_RESOURCES_DIR}" -name 'refreshtokens*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-ReplicaSet() {
  find "${API_RESOURCES_DIR}" -name 'replicasets*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-ReplicationController() {
  find "${API_RESOURCES_DIR}" -name 'replicationcontrollers*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-ResourceQuota() {
  find "${API_RESOURCES_DIR}" -name 'resourcequotas*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-ResticRepository() {
  # TODO - need to test if this is scoped to ns
  find "${API_RESOURCES_DIR}" -name 'resticrepositories*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-Restore() {
  find "${API_RESOURCES_DIR}" -name 'restores*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-RoleBinding() {
  find "${API_RESOURCES_DIR}" -name 'rolebindings*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-Role() {
  find "${API_RESOURCES_DIR}" -name 'roles*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-RuntimeClass() {
  find "${API_RESOURCES_DIR}" -name 'runtimeclasses*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-Schedule() {
  find "${API_RESOURCES_DIR}" -name 'schedules*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-Secret() {
  echo "*** SECRETS FILE IS NOT VALID YAML - DUMPING FILE(S) ***"
  find "${API_RESOURCES_DIR}" -name 'secrets*.yaml' -type f -exec cat {} \;
  echo "*** SECRETS FILE IS NOT VALID YAML - END DUMPING FILE(S) ***"
}

describe-SelfSubjectAccessReview() {
  echo "This method is not allowed on the requested resource."
}

describe-SelfSubjectRulesReview() {
  echo "This method is not allowed on the requested resource."
}

describe-ServerStatusRequest() {
  find "${API_RESOURCES_DIR}" -name 'serverstatusrequests*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-ServiceAccount() {
  find "${API_RESOURCES_DIR}" -name 'serviceaccounts*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-ServiceMonitor() {
  find "${API_RESOURCES_DIR}" -name 'servicemonitors*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-Service() {
  find "${API_RESOURCES_DIR}" -name 'services*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-SigningKey() {
  find "${API_RESOURCES_DIR}" -name 'signingke*s*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-StatefulSet() {
  find "${API_RESOURCES_DIR}" -name 'statefulsets*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-StorageClass() {
  find "${API_RESOURCES_DIR}" -name 'storageclasses*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-SubjectAccessReview() {
  echo "This method is not allowed on the requested resource."
}

describe-TokenReview() {
  echo "This method is not allowed on the requested resource."
}

describe-ValidatingWebhookConfiguration() {
  find "${API_RESOURCES_DIR}" -name 'validatingwebhookconfigurations*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-VolumeAttachment() {
  find "${API_RESOURCES_DIR}" -name 'volumeattachments*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-VolumeSnapshotClass() {
  find "${API_RESOURCES_DIR}" -name 'volumesnapshotclasses*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-VolumeSnapshotContent() {
  find "${API_RESOURCES_DIR}" -name 'volumesnapshotcontents*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-VolumeSnapshotLocation() {
  find "${API_RESOURCES_DIR}" -name 'volumesnapshotlocations*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'" and .namespace == "'"${NAMESPACE}"'")' {} \;
}

describe-VolumeSnapshot() {
  find "${API_RESOURCES_DIR}" -name 'volumesnapshots*.yaml' -type f -exec yq -y '.items[] | select(.metadata | .name == "'"${NAME}"'")' {} \;
}

describe-Help() {
  cat <<EOF
kbk describe usage:
  describe <resource-kind> <name> [-n <namespace>] - Shows details about a resource and formats and prints this information on multiple lines.
EOF
}

podChecks() {
  PODS_NOT_RUNNING="$(find "${API_RESOURCES_DIR}" -name 'pods.yaml' -type f -exec yq -r '"\(.items[] | select(([.status.containerStatuses[]? | select(.ready == true) | .ready] | length | tostring) != ([.status.containerStatuses[]?.ready] | length | tostring)) | (.metadata | .namespace + "~" + .name) + "~" + ([.status.containerStatuses[]? | select(.ready == true) | .ready] | length | tostring) + "/" + ([.status.containerStatuses[]?.ready] | length | tostring) + "~" + (if .status.conditions[] | select(.type == "Ready") | .status == "True" then .status.phase else .status.conditions[] | select(.type == "Ready") | .reason end) + "~" + ((reduce .status.containerStatuses[]? as $cr (0; . + ($cr | .restartCount) )) | tostring) + "~" + .metadata.creationTimestamp + "~" + (if .status.podIP? != null then .status.podIP? else "<none>" end) + "~" + (if .spec.nodeName? != null then .spec.nodeName? else "<none>" end))"' {} \;)"

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
  NODES_NOT_READY="$(find "${API_RESOURCES_DIR}" -name 'nodes*.yaml' -type f -exec yq -r '"\(.items[] | select(.status.conditions[] | select(.type == "Ready") | .status != "True") | .metadata.name + "~" + (.status.conditions[] | select(.type == "Ready") | if .status == "True" then "Ready" else "NotReady" end) + "~" + (.metadata.labels | if ."node-role.kubernetes.io/master"? then "master" else "worker" end) + "~" + (.metadata.creationTimestamp | tostring) + "~" + (.status.addresses[] | select(.type == "InternalIP") .address) + "~" + (.status.conditions[] | select(.type == "Ready") | .status + "~" + .reason + "~" + .message + "~" + (.lastHeartbeatTime | tostring)))"' {} \;)"

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
  UNSUPPORTED_OS_NODES="$(find "${BUNDLE_ROOT}" -name 'ansible_facts.json' -type f -exec jq -r '"\(select((.distribution | (contains("CentOS") or contains("RedHat")) | not) or (.distribution_version | startswith("7.6") | not)) | .nodename + "~" + .default_ipv4.address + "~" + .distribution + " " + .distribution_version)"' {} \;)"

  if [[ -n $UNSUPPORTED_OS_NODES ]]; then
    echo -e "${RED} X Detected an unsupported OS the following node(s):${RESET}"
    (echo -e "NODE~IP~OS-VERSION"
    echo -e "$UNSUPPORTED_OS_NODES") | column -t -s '~' | sed 's/^/   /g'
  else
    echo -e "${GREEN} + No unsupported OS found.${RESET}"
  fi

  # Unsupported kernel versions
  UNSUPPORTED_KERNEL_VERSIONS="$(find "${BUNDLE_ROOT}" -name 'ansible_facts.json' -type f -exec jq -r '"\(select(.kernel | startswith("3.10.0-957") | not) | .nodename + "~" + .default_ipv4.address + "~" + .kernel)"' {} \;)"
  
  if [[ -n $UNSUPPORTED_KERNEL_VERSIONS ]]; then
    echo -e "${RED} X Detected an unsupported kernel on the following node(s):${RESET}"
    (echo -e "NODE~IP~KERNEL-VERSION"
    echo -e "$UNSUPPORTED_KERNEL_VERSIONS") | column -t -s '~' | sed 's/^/   /g'
  else
    echo -e "${GREEN} + No unsupported kernel found.${RESET}"
  fi

  # Disk space critical
  NODE_CRITICAL_DISK_USAGE_PER_MOUNT="$(find "${BUNDLE_ROOT}" -name 'ansible_facts.json' -type f -exec jq -r '"\(select(.mounts[] | (.size_available? != null) and (.size_total? != null) and ((((.size_available / .size_total) * 100) > 10) | not)) as $fd | $fd | .nodename + "~" + .default_ipv4.address + "~" + (.mounts[] | select((.size_available? != null) and (.size_total? != null) and ((((.size_available / .size_total) * 100) < 10))) | .mount + "~" + ((((.size_available / .size_total) * 100) | floor | tostring) + "%") + " (" + (((.size_available / 1000000000) | floor | tostring) + " GB") + ")" + "~" + .device))"' {} \;)"
  
  if [[ -n $NODE_CRITICAL_DISK_USAGE_PER_MOUNT ]]; then
    echo -e "${RED} X Detected high disk space usage the following node(s):${RESET}"
    (echo -e "NODE~IP~MOUNT~DISK-FREE~DEVICE"
    echo -e "$NODE_CRITICAL_DISK_USAGE_PER_MOUNT") | column -t -s '~' | sed 's/^/   /g'
  else
    echo -e "${GREEN} + No high disk space usage found.${RESET}"
  fi

  # Swap enabled
  SWAP_ENABLED_NODES="$(find "${BUNDLE_ROOT}" -name 'ansible_facts.json' -type f -exec jq -r '"\(select(.swaptotal_mb != 0) | .nodename + "~" + .default_ipv4.address + "~true~" + (.swaptotal_mb | tostring))"' {} \;)"

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
  APP_ARMOR_ENABLED_NODES="$(find "${BUNDLE_ROOT}" -name 'ansible_facts.json' -type f -exec jq -r '"\(select(.apparmor.status != "disabled") | .nodename + "~" + .default_ipv4.address + "~" + .apparmor.status)"' {} \;)"
  
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

cluster-Help() {
  cat <<EOF
kbk cluster usage:
  summary - Run checks against a bundle to find errors, misconfigurations and more.
  leaders - Display information about kube-scheduler and kube-controller-manager leaders.
EOF
}

checks-Help() {
  cat <<EOF
kbk checks usage:
  checks - Run checks against a bundle to find errors, misconfigurations and more.
EOF
}

main-Help() {
  cat <<EOF
kbk - a simple command line tool for parsing files contained within Kubernetes diagnostic bundles.

 Find more information at: https://github.com/some-things/kbk

Commands:
  extract        Extracts a compressed bundles to a specified directory
  explain        Documentation of resources
  get            Display one or many resources
  cluster        Display cluster info
  describe       Show details of a specific resource or group of resources
  logs           Display the logs for a container in a pod
  api-resources  Display the supported API resources on the server
  checks         Run checks against a bundle to find errors, misconfigurations and more
EOF
}

ARGS="$*"
case "${1}" in
  "extract" )
    case "${2}" in
      *.tar.gz ) extractBundle "${2}"
      ;;
      * ) extract-Help
      ;;
    esac
  ;;
  api-resource | api-resources | apiresource | apiresources | a ) 
    preflight
    get-API-Resources
  ;;
  describe | desc | d )
    preflight
    while [ -n "$1" ]; do
        arg="$1"
        shift
        case "$arg" in
            -n)
              NAMESPACE=$1
            ;;
            help | -h | --h | -help | --help )
              describe-Help
              exit 0
            ;;            
            -*)
              echo "unrecognized argument: $arg" 1>&2
              exit 1
            ;;
        esac
    done
    NAME="$(echo "${ARGS}" | awk '{print tolower($3)}')"

    case "$(echo "${ARGS}" | awk '{print tolower($2)}')" in
      help | -h | --h | -help | --help | "" ) describe-Help;;
      addon | addons ) describe-Addon;;
      alertmanager | alertmanagers ) describe-Alertmanager;;
      apiservice | apiservices ) describe-APIService;;
      authcode | authcodes ) describe-AuthCode;;
      authrequest | authrequests ) describe-AuthRequest;;
      backup | backups ) describe-Backup;;
      backupstoragelocation | backupstoragelocations ) describe-BackupStorageLocation;;
      bgpconfiguration | bgpconfigurations ) describe-BGPConfiguration;;
      bgppeer | bgppeers ) describe-BGPPeer;;
      binding | bindings ) describe-Binding;;
      blockaffinity | blockaffinities ) describe-BlockAffinity;;
      certificatesigningrequest | certificatesigningrequests | csr | csrs ) describe-CertificateSigningRequest;;
      clusterinformation | clusterinformations ) describe-ClusterInformation;;
      clusterrolebinding | clusterrolebindings ) describe-ClusterRoleBinding;;
      clusterrole | clusterroles ) describe-ClusterRole;;
      componentstatus | componentstatuses | cs ) describe-ComponentStatus;;
      configmap | configmaps | cm ) describe-ConfigMap;;
      connector | connectors ) describe-Connector;;
      controllerrevision | controllerrevisions ) describe-ControllerRevision;;
      cronjob | cronjobs | cj | cjs ) describe-CronJob;;
      csidriver | csidrivers ) describe-CSIDriver;;
      csinode | csinodes ) describe-CSINode;;
      customresourcedefinition | customresourcedefinitions | crd | crds ) describe-CustomResourceDefinition;;
      daemonset | daemonsets | ds ) describe-DaemonSet;;
      deletebackuprequest | deletebackuprequests ) describe-DeleteBackupRequest;;
      deployment | deployments | deploy | deploys ) describe-Deployment;;
      downloadrequest | downloadrequests ) describe-DownloadRequest;;
      endpoint | endpoints | ep ) describe-Endpoints;;
      event | events | ev | evs ) describe-Event;;
      felixconfiguration | felixconfigurations ) describe-FelixConfiguration;;
      globalnetworkpolicy | globalnetworkpolicies ) describe-GlobalNetworkPolicy;;
      globalnetworkset | globalnetworksets ) describe-GlobalNetworkSet;;
      horizontalpodautoscaler | horizontalpodautoscalers | hpa | hpas ) describe-HorizontalPodAutoscaler;;
      hostendpoint | hostendpoints ) describe-HostEndpoint;;
      ingress | ingresses | ing | ings ) describe-Ingress;;
      ipamblock | ipamblocks ) describe-IPAMBlock;;
      ipamconfig | ipamconfigs ) describe-IPAMConfig;;
      ipamhandle | ipamhandles ) describe-IPAMHandle;;
      ippool | ippools ) describe-IPPool;;
      job | jobs ) describe-Job;;
      lease | leases ) describe-Lease;;
      limitrange | limitranges | limit | limits ) describe-LimitRange;;
      localsubjectaccessreview | localsubjectaccessreviews ) describe-LocalSubjectAccessReview;;
      minioinstance | minioinstances ) describe-MinIOInstance;;
      mutatingwebhookconfiguration | mutatingwebhookconfigurations ) describe-MutatingWebhookConfiguration;;
      namespace | namespaces | ns ) describe-Namespace;;
      networkpolicy | networkpolicies | netpol | netpols ) describe-NetworkPolicy;;
      networkset | networksets ) describe-NetworkSet;;
      node | nodes | no ) describe-Node;;
      oauth2client | oauth2clients ) describe-OAuth2Client;;
      observablecluster | observableclusters | oc | ocs ) describe-ObservableCluster;;
      offlinesessions | offlinesessionses | offlinesession ) describe-OfflineSessions;;
      password | passwords ) describe-Password;;
      persistentvolumeclaim | persistentvolumeclaims | pvc | pvcs ) describe-PersistentVolumeClaim;;
      persistentvolume | persistentvolumes | pv | pvs ) describe-PersistentVolume;;
      poddisruptionbudget | poddisruptionbudgets | pdb | pdbs ) describe-PodDisruptionBudget;;
      pod | pods | po ) describe-Pod;;
      podsecuritypolicy | podsecuritypolicies | psp | psps ) describe-PodSecurityPolicy;;
      podtemplate | podtemplates ) describe-PodTemplate;;
      podvolumebackup | podvolumebackups ) describe-PodVolumeBackup;;
      podvolumerestore | podvolumerestores ) describe-PodVolumeRestore;;
      priorityclass | priorityclasses | pc | pcs ) describe-PriorityClass;;
      prometheus | prometheuses ) describe-Prometheus;;
      prometheusrule | prometheusrules ) describe-PrometheusRule;;
      refreshtoken | refreshtokens ) describe-RefreshToken;;
      replicaset | replicasets | rs ) describe-ReplicaSet;;
      replicationcontroller | replicationcontrollers | rc ) describe-ReplicationController;;
      resourcequota | resourcequotas | quota | quotas ) describe-ResourceQuota;;
      resticrepository | resticrepositories ) describe-ResticRepository;;
      restore | restores ) describe-Restore;;
      rolebinding | rolebindings ) describe-RoleBinding;;
      role | roles ) describe-Role;;
      runtimeclass | runtimeclasses ) describe-RuntimeClass;;
      schedule | schedules ) describe-Schedule;;
      secret | secrets ) describe-Secret;;
      selfsubjectaccessreview | selfsubjectaccessreviews ) describe-SelfSubjectAccessReview;;
      selfsubjectrulesreview | selfsubjectrulesreviews ) describe-SelfSubjectRulesReview;;
      serverstatusrequest | serverstatusrequests ) describe-ServerStatusRequest;;
      serviceaccount | serviceaccounts | sa | sas ) describe-ServiceAccount;;
      servicemonitor | servicemonitors ) describe-ServiceMonitor;;
      service | services | svc | svcs ) describe-Service;;
      signingkey | signingkeies | signingkeys ) describe-SigningKey;;
      statefulset | statefulsets | sts ) describe-StatefulSet;;
      storageclass | storageclasses | sc | scs ) describe-StorageClass;;
      subjectaccessreview | subjectaccessreviews ) describe-SubjectAccessReview;;
      tokenreview | tokenreviews ) describe-TokenReview;;
      validatingwebhookconfiguration | validatingwebhookconfigurations ) describe-ValidatingWebhookConfiguration;;
      volumeattachment | volumeattachments ) describe-VolumeAttachment;;
      volumesnapshotclass | volumesnapshotclasses ) describe-VolumeSnapshotClass;;
      volumesnapshotcontent | volumesnapshotcontents ) describe-VolumeSnapshotContent;;
      volumesnapshotlocation | volumesnapshotlocations ) describe-VolumeSnapshotLocation;;
      volumesnapshot | volumesnapshots ) describe-VolumeSnapshot;;
      * ) echo "Could not find a $(echo "${ARGS}" | awk '{print tolower($2)}') resource named ${NAME}. Did you specify the correct name and namespace?";;
    esac
  ;;
  get | g )
    preflight
    case "$(echo "${2}" | awk '{print tolower($0)}')" in
      help | -h | --h | -help | --help | "" ) get-Help;;
      apiresources | api-resources ) get-API-Resources;;
      addon | addons ) get-Addon;;
      alertmanager | alertmanagers ) get-Alertmanager;;
      apiservice | apiservices ) get-APIService;;
      authcode | authcodes ) get-AuthCode;;
      authrequest | authrequests ) get-AuthRequest;;
      backup | backups ) get-Backup;;
      backupstoragelocation | backupstoragelocations ) get-BackupStorageLocation;;
      bgpconfiguration | bgpconfigurations ) get-BGPConfiguration;;
      bgppeer | bgppeers ) get-BGPPeer;;
      binding | bindings ) get-Binding;;
      blockaffinity | blockaffinities ) get-BlockAffinity;;
      certificatesigningrequest | certificatesigningrequests | csr | csrs ) get-CertificateSigningRequest;;
      clusterinformation | clusterinformations ) get-ClusterInformation;;
      clusterrolebinding | clusterrolebindings ) get-ClusterRoleBinding;;
      clusterrole | clusterroles ) get-ClusterRole;;
      componentstatus | componentstatuses | cs ) get-ComponentStatus;;
      configmap | configmaps | cm ) get-ConfigMap;;
      connector | connectors ) get-Connector;;
      controllerrevision | controllerrevisions ) get-ControllerRevision;;
      cronjob | cronjobs | cj | cjs ) get-CronJob;;
      csidriver | csidrivers ) get-CSIDriver;;
      csinode | csinodes ) get-CSINode;;
      customresourcedefinition | customresourcedefinitions | crd | crds ) get-CustomResourceDefinition;;
      daemonset | daemonsets | ds ) get-DaemonSet;;
      deletebackuprequest | deletebackuprequests ) get-DeleteBackupRequest;;
      deployment | deployments | deploy | deploys ) get-Deployment;;
      downloadrequest | downloadrequests ) get-DownloadRequest;;
      endpoint | endpoints | ep ) get-Endpoints;;
      event | events | ev | evs ) get-Event;;
      felixconfiguration | felixconfigurations ) get-FelixConfiguration;;
      globalnetworkpolicy | globalnetworkpolicies ) get-GlobalNetworkPolicy;;
      globalnetworkset | globalnetworksets ) get-GlobalNetworkSet;;
      horizontalpodautoscaler | horizontalpodautoscalers | hpa | hpas ) get-HorizontalPodAutoscaler;;
      hostendpoint | hostendpoints ) get-HostEndpoint;;
      ingress | ingresses | ing | ings ) get-Ingress;;
      ipamblock | ipamblocks ) get-IPAMBlock;;
      ipamconfig | ipamconfigs ) get-IPAMConfig;;
      ipamhandle | ipamhandles ) get-IPAMHandle;;
      ippool | ippools ) get-IPPool;;
      job | jobs ) get-Job;;
      lease | leases ) get-Lease;;
      limitrange | limitranges | limit | limits ) get-LimitRange;;
      localsubjectaccessreview | localsubjectaccessreviews ) get-LocalSubjectAccessReview;;
      minioinstance | minioinstances ) get-MinIOInstance;;
      mutatingwebhookconfiguration | mutatingwebhookconfigurations ) get-MutatingWebhookConfiguration;;
      namespace | namespaces | ns ) get-Namespace;;
      networkpolicy | networkpolicies | netpol | netpols ) get-NetworkPolicy;;
      networkset | networksets ) get-NetworkSet;;
      node | nodes | no ) get-Node;;
      oauth2client | oauth2clients ) get-OAuth2Client;;
      observablecluster | observableclusters | oc | ocs ) get-ObservableCluster;;
      offlinesessions | offlinesessionses | offlinesession ) get-OfflineSessions;;
      password | passwords ) get-Password;;
      persistentvolumeclaim | persistentvolumeclaims | pvc | pvcs ) get-PersistentVolumeClaim;;
      persistentvolume | persistentvolumes | pv | pvs ) get-PersistentVolume;;
      poddisruptionbudget | poddisruptionbudgets | pdb | pdbs ) get-PodDisruptionBudget;;
      pod | pods | po ) get-Pod;;
      podsecuritypolicy | podsecuritypolicies | psp | psps ) get-PodSecurityPolicy;;
      podtemplate | podtemplates ) get-PodTemplate;;
      podvolumebackup | podvolumebackups ) get-PodVolumeBackup;;
      podvolumerestore | podvolumerestores ) get-PodVolumeRestore;;
      priorityclass | priorityclasses | pc | pcs ) get-PriorityClass;;
      prometheus | prometheuses ) get-Prometheus;;
      prometheusrule | prometheusrules ) get-PrometheusRule;;
      refreshtoken | refreshtokens ) get-RefreshToken;;
      replicaset | replicasets | rs ) get-ReplicaSet;;
      replicationcontroller | replicationcontrollers | rc ) get-ReplicationController;;
      resourcequota | resourcequotas | quota | quotas ) get-ResourceQuota;;
      resticrepository | resticrepositories ) get-ResticRepository;;
      restore | restores ) get-Restore;;
      rolebinding | rolebindings ) get-RoleBinding;;
      role | roles ) get-Role;;
      runtimeclass | runtimeclasses ) get-RuntimeClass;;
      schedule | schedules ) get-Schedule;;
      secret | secrets ) get-Secret;;
      selfsubjectaccessreview | selfsubjectaccessreviews ) get-SelfSubjectAccessReview;;
      selfsubjectrulesreview | selfsubjectrulesreviews ) get-SelfSubjectRulesReview;;
      serverstatusrequest | serverstatusrequests ) get-ServerStatusRequest;;
      serviceaccount | serviceaccounts | sa | sas ) get-ServiceAccount;;
      servicemonitor | servicemonitors ) get-ServiceMonitor;;
      service | services | svc | svcs ) get-Service;;
      signingkey | signingkeies | signingkeys ) get-SigningKey;;
      statefulset | statefulsets | sts ) get-StatefulSet;;
      storageclass | storageclasses | sc | scs ) get-StorageClass;;
      subjectaccessreview | subjectaccessreviews ) get-SubjectAccessReview;;
      tokenreview | tokenreviews ) get-TokenReview;;
      validatingwebhookconfiguration | validatingwebhookconfigurations ) get-ValidatingWebhookConfiguration;;
      volumeattachment | volumeattachments ) get-VolumeAttachment;;
      volumesnapshotclass | volumesnapshotclasses ) get-VolumeSnapshotClass;;
      volumesnapshotcontent | volumesnapshotcontents ) get-VolumeSnapshotContent;;
      volumesnapshotlocation | volumesnapshotlocations ) get-VolumeSnapshotLocation;;
      volumesnapshot | volumesnapshots ) get-VolumeSnapshot;;
      * ) echo "The ${2} resource kind is currently unsupported in kbk."
    esac
  ;;
  log | logs )
    preflight
    case "${2}" in
      $(find "${POD_LOGS_DIR}" -name "${2}.log" -type f -exec basename {} \; | sed -e "s/.log$//") ) less "${POD_LOGS_DIR}/${2}.log"
      ;;
      * ) echo "Logs for pod '${2}' were not found. Is this pod in the 'kube-system' or 'kubeaddons' namespace?"
      ;;
    esac
  ;;
  cluster )
    preflight
    case "${2}" in
      summary )
        (echo "NODE~IP~OS-VERSION~KERNEL-VERSION~MEM(MB)~CPU"
          find "${BUNDLE_ROOT}" -name 'ansible_facts.json' -type f -exec jq -r '"\(.nodename + "~" + .default_ipv4.address + "~" + .distribution + " " + .distribution_version + "~" + .kernel + "~" + (.memory_mb.real | (.used | tostring) + "/" + (.total | tostring)) + "~" + (.processor_vcpus | tostring))"' {} \;) | 
          column -t  -s '~'
      ;;
      leader | leaders | l | ls )
        echo "kube-scheduler leader information:"
        find "${API_RESOURCES_DIR}" -name 'endpoints*.yaml' -type f -exec yq '.items[].metadata | select(.namespace == "kube-system" and .name == "kube-scheduler") | .annotations."control-plane.alpha.kubernetes.io/leader"? | fromjson | .' {} \;
        echo "kube-controller-manager leader information:"
        find "${API_RESOURCES_DIR}" -name 'endpoints*.yaml' -type f -exec yq -r '.items[].metadata | select(.namespace == "kube-system" and .name == "kube-controller-manager") | .annotations."control-plane.alpha.kubernetes.io/leader"? | fromjson | .' {} \;
      ;;
      * )
        cluster-Help
      ;;
    esac
  ;;
  check | checks | c )
    preflight
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    # YELLOW=$(tput setaf 3)
    RESET=$(tput sgr0)
    podChecks
    nodeChecks
  ;;
  help | -h | --h | -help | --help | "" ) main-Help
  ;;
esac