# kbk - Kubernetes Bundle Tool

- [kbk - Kubernetes Bundle Tool](#kbk---kubernetes-bundle-tool)
  - [Summary](#summary)
  - [Setup](#setup)
    - [Running Locally](#running-locally)
      - [Prerequisites](#prerequisites)
      - [Download and Installation](#download-and-installation)
    - [Running via Docker](#running-via-docker)
  - [Environment Variables](#environment-variables)
  - [Usage](#usage)
    - [Interacting with Kubernetes Resources](#interacting-with-kubernetes-resources)
      - [`up`](#up)
      - [`down`](#down)
      - [`status`](#status)
      - [`kubeconfig`](#kubeconfig)
    - [Viewing Logs](#viewing-logs)
      - [`logs`](#logs)
    - [Check for Issues](#check-for-issues)
      - [`checks`](#checks)
    - [Miscellaneous](#miscellaneous)
      - [`extract`](#extract)
  - [Troubleshooting with `kbk`](#troubleshooting-with-kbk)
    - [Clusters](#clusters)
      - [Specific scenarios](#specific-scenarios)
    - [Applications](#applications)
      - [Debugging Pods](#debugging-pods)
        - [My pod stays pending](#my-pod-stays-pending)
        - [My pod stays waiting](#my-pod-stays-waiting)
        - [My pod is crashing or otherwise unhealthy](#my-pod-is-crashing-or-otherwise-unhealthy)
      - [Debugging Replication Controllers](#debugging-replication-controllers)
      - [Debugging Services](#debugging-services)
        - [My service is missing endpoints](#my-service-is-missing-endpoints)
        - [Network traffic is not forwarded](#network-traffic-is-not-forwarded)

## Summary

Kubernetes Bundle Tool (kbk) is a simple command-line tool for analyzing files contained within Kubernetes diagnostic bundles.

The intent of `kbk` is to provide easy access to cluster information and resources on the fly using `kubectl`. This allows the user to interact with Kubernetes diagnostic bundles and parse their contents more effective and efficiently. Using `kbk` allows you to quickly gather information about a cluster and its state without having to open large, and often cumbersome, YAML, JSON, and log files.

## Setup

Users have multiple options for running `kbk`, including running locally or within a Docker container.

### Running Locally

#### Prerequisites

To use `kbk`, the following prerequisites must be installed:

- [`jq`](https://github.com/stedolan/jq) for parsing JSON and as a dependency for `yq`
- [`yq`](https://github.com/kislyuk/yq) for parsing YAML
- [`docker`](https://www.docker.com/) for running the Kubernetes cluster components and as a dependency for `k3d`
- [`k3d`](https://github.com/rancher/k3d) for managing the Kubernetes cluster's lifecycle
- [`sqlite3`](https://www.sqlite.org/cli.html) for interacting with the Kubernetes backend SQLite database
- [`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/) for interacting with the Kubernetes cluster

On MacOS, these can be installed with `brew`:

```sh
brew install jq python-yq docker k3d sqlite3 kubernetes-cli
```

On RedHat based distros:

```sh
yum install -y epel-release \
  yum-utils \
  device-mapper-persistent-data \
  lvm2
yum-config-manager \
  --add-repo \
  https://download.docker.com/linux/centos/docker-ce.repo
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
yum install -y jq \
  python3 \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  sqlite \
  kubectl
systemctl enable docker && systemctl restart docker
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py
export PATH=$PATH:/usr/local/bin
pip3 install yq
curl -s https://raw.githubusercontent.com/rancher/k3d/master/install.sh | bash
```

#### Download and Installation

Once all preqrequisites are installed, simply download `kbk` and add it to your `PATH`.

```sh
curl -O https://raw.githubusercontent.com/some-things/kbk/master/kbk.sh
sudo mv kbk.sh /usr/local/bin/kbk
sudo chmod +x /usr/local/bin/kbk
kbk --help
```

### Running via Docker

Coming soon.

## Environment Variables

`kbk` supports the following environment variables:

|Variable|Default|Description|
|---|---|---|
|KBK_TICKETS_DIR|${HOME}/Documents/logs/tickets|Directory where the bundle will be extracted|
|KBK_BUNDLE_DIR|Folder prefixed with 'bundle-' in /path/to/work/dir|Directoy of the bundle root|

## Usage

Note: `kbk` relies on the bundle root directory name being prefixed with `bundle-`. However, it can also be invoked from any sub-directory or overriden by setting the `KBK_BUNDLE_DIR` environment variable. This is only a factor when running locally. To automatically extract a bundle and its contents to a directory name prefixed with `bundle-`, please see [`kbk extract`](#extract).

### Interacting with Kubernetes Resources

#### `up`

Provisions a Kubernetes cluster and injects the resources contained within the bundle into the cluster's backing database. This then allows the user to parse bundle resources using `kubectl` (and thus, any `kubectl` plugins).

How it works:

1) A Kubernetes cluster is provisioned.
2) The managed cluster's state and associated file paths are written to `${HOME}/.kbk/state.json`
3) The Kubernetes cluster is stopped.
4) SQL queries (INSERT statements) are created based on the contents of the resource YAML in the api-resources directory.
5) The resulting SQL statements ran against the Kubernetes backend SQLite database.
6) The Kubernetes cluster is started once again and is available via `kubectl`.

```sh
kbk up
```

```sh
$ kbk up
2019/09/29 22:57:57 Created cluster network with ID 2838730fe632ddaedfa407f57cfb53c484b01621927cea1cb31eca77e9d87b50
2019/09/29 22:57:57 Created docker volume  k3d-kbk-cluster-e4e6544d-images
2019/09/29 22:57:57 Creating cluster [kbk-cluster-e4e6544d]
...
Adding resources into database.
Starting cluster.
2019/09/29 23:02:34 Starting cluster [kbk-cluster-e4e6544d]
2019/09/29 23:02:34 ...Starting server
2019/09/29 23:02:35 SUCCESS: Started cluster [kbk-cluster-e4e6544d]
Started cluster. Please set your kubeconfig with:
export KUBECONFIG="$(k3d get-kubeconfig --name='kbk-cluster-e4e6544d')"
```

#### `down`

Destroy the current managed cluster and all associated resources.

How it works:

1) The current managed Kubernetes cluster is deleted.
2) The kbk cluster's `dataDirectory` (`${API_RESOURCES_DIR}/.kbk`) is deleted.
3) The kbk state file (`${HOME}/.kbk/state.json`) is wiped.

```sh
kbk down
```

```sh
$ kbk down
Deleting cluster: kbk-cluster-e4e6544d
2019/09/29 23:07:54 Removing cluster [kbk-cluster-e4e6544d]
2019/09/29 23:07:54 ...Removing server
2019/09/29 23:07:55 ...Removing docker image volume
2019/09/29 23:07:55 SUCCESS: removed cluster [kbk-cluster-e4e6544d]
Deleting database resources.
Wiping cluster state file.
Done.
```

#### `status`

Display the status of the current managed cluster.

```sh
kbk status
```

```sh
$ kbk status
{
  "clusterName": "kbk-cluster-e4e6544d",
  "bundleRoot": "/Users/dn/Documents/logs/tickets/konvoy-debian/bundle-20190918T002524",
  "dataDirectory": "/Users/dn/Documents/logs/tickets/konvoy-debian/bundle-20190918T002524/10.0.194.19/api-resources/.kbk",
  "datebaseFile": "/Users/dn/Documents/logs/tickets/konvoy-debian/bundle-20190918T002524/10.0.194.19/api-resources/.kbk/db/state.db",
  "kubeconfigFile": "/Users/dn/.config/k3d/kbk-cluster-e4e6544d/kubeconfig.yaml",
  "lastUpdated": "2019-09-29T22:57:58Z"
}
```

#### `kubeconfig`

Display the kubeconfig file for the current kbk cluster.

```sh
kbk kubeconfig
```

```sh
$ kbk kubecconfig
Current KUBECONFIG file: /Users/dn/.config/k3d/kbk-cluster-604fb608/kubeconfig.yaml
For cluster access:
export KUBECONFIG="/Users/dn/.config/k3d/kbk-cluster-604fb608/kubeconfig.yaml"
```

<!-- #### `cluster`

Display cluster information without the need for provisioning a cluster with `up`.

##### `summary`

Print an overview of each node in the cluster.

```sh
kbk cluster summary
```

```sh
$ kbk cluster summary
NODE                                        IP            OS-VERSION       KERNEL-VERSION             MEM(MB)      CPU
ip-10-0-194-111.us-west-2.compute.internal  10.0.194.111  CentOS 7.6.1810  3.10.0-957.1.3.el7.x86_64  3996/7719    2
ip-10-0-192-13.us-west-2.compute.internal   10.0.192.13   CentOS 7.6.1810  3.10.0-957.1.3.el7.x86_64  4204/7719    2
ip-10-0-194-161.us-west-2.compute.internal  10.0.194.161  CentOS 7.6.1810  3.10.0-957.1.3.el7.x86_64  4103/7719    2
ip-10-0-128-250.us-west-2.compute.internal  10.0.128.250  CentOS 7.6.1810  3.10.0-957.1.3.el7.x86_64  7518/15699   4
ip-10-0-129-156.us-west-2.compute.internal  10.0.129.156  CentOS 7.6.1810  3.10.0-957.1.3.el7.x86_64  9470/15699   4
ip-10-0-129-135.us-west-2.compute.internal  10.0.129.135  CentOS 7.6.1810  3.10.0-957.1.3.el7.x86_64  11402/15699  4
ip-10-0-128-132.us-west-2.compute.internal  10.0.128.132  CentOS 7.6.1810  3.10.0-957.1.3.el7.x86_64  8689/15699   4
```

##### `leaders`

Print information regarding the `kube-scheduler` and `kube-controller-manager` leaders.

```sh
kbk cluster leaders
```

```sh
kube-scheduler leader information:
{
  "holderIdentity": "ip-10-0-195-100.us-west-2.compute.internal_36204542-c86e-4d99-a5e1-b28cad471b5e",
  "leaseDurationSeconds": 15,
  "acquireTime": "2019-08-18T18:12:09Z",
  "renewTime": "2019-08-21T17:42:42Z",
  "leaderTransitions": 1
}
kube-controller-manager leader information:
{
  "holderIdentity": "ip-10-0-194-246.us-west-2.compute.internal_ba039c6a-416e-4584-bf16-14f35d614760",
  "leaseDurationSeconds": 15,
  "acquireTime": "2019-08-18T18:11:51Z",
  "renewTime": "2019-08-21T17:42:42Z",
  "leaderTransitions": 1
}
``` -->

### Viewing Logs

#### `logs`

View the logs for a specific pod.

```sh
kbk logs <namespace> <pod-name>
```

### Check for Issues

#### `checks`

Run checks against the bundle to find errors, misconfigurations, and more. The checks currently available are:

- Pods with containers not in a ready state
- `componentstatuses` not reporting healthy
- Nodes not in a ready state
- Nodes with an unsupported host OS
- Nodes with an unsupported host kernel
- Nodes with disk usage exceeding 90% for a particular mount
- Nodes with swap enabled
- Nodes without containerd service in a running state
- Nodes without kubelet service in a running state
- Nodes with AppArmor enabled
- Nodes with processes oom-killed
- Nodes encountering a known kmem leak bug

Check results are indicated as follows:

```sh
 + Passed check
 X Failed check
```

 <!-- - Skipped check (due to the requisite file not being present or check not being applicable) -->

```sh
kbk checks
```

```sh
$ kbk checks
 + No pods not in a ready state.
 + No nodes not in a ready state.
 X Detected kubelet not running on the following nodes:
   IP           KUBELET-STATUS
   10.0.192.13  (dead)
 + No unsupported OS found.
 X Detected an unsupported kernel on the following node(s):
   NODE                                       IP           KERNEL-VERSION
   ip-10-0-192-13.us-west-2.compute.internal  10.0.192.13  3.12.0-957.1.3.el7.x86_64
 X Detected high disk space usage the following node(s):
   NODE                                       IP           MOUNT  DISK-FREE  DEVICE
   ip-10-0-192-13.us-west-2.compute.internal  10.0.192.13  /      9% (7 GB)  /dev/nvme0n1p1
 X Detected swap enabled on the following nodes:
   NODE                                       IP           SWAP-ENABLED  SWAP-SIZE
   ip-10-0-192-13.us-west-2.compute.internal  10.0.192.13  true          2132
 X Detected containerd not running on the following nodes:
   IP           CONTAINERD-STATUS
   10.0.192.13  (dead)
 X Detected AppArmor enabled on the following nodes:
   NODE                                       IP           APPARMOR-STATUS
   ip-10-0-192-13.us-west-2.compute.internal  10.0.192.13  enabled
 X Detected kmem events on the following nodes:
   EVENTS  NODE
   5       10.0.128.250
   1       10.0.129.156
   3       10.0.192.13
 X Detected processes oom-killed on the following nodes:
   EVENTS  NODE          PROCESS
   5       10.0.129.156  (java)
   2       10.0.129.156  (python)
   1       10.0.192.13   (etcd)
```

### Miscellaneous

#### `extract`

Extracts a compressed bundle to a directory. By default, bundles will be extracted to `$HOME/Documents/logs/tickets/<specified-name>`. To change this, you can set the `KBK_TICKETS_DIR` [environment variable](#environment-variables).

```sh
kbk extract <bundle-name>.tar.gz
```

```sh
$ kbk extract 20190815T002039.tar.gz
Ticket number: 12345
Extracting bundle to /Users/dn/Documents/logs/tickets/12345/bundle-20190815T002039...
Extracting nodes...
Finished extracting bundle to /Users/dn/Documents/logs/tickets/12345/bundle-20190815T002039
```

## Troubleshooting with `kbk`

A good place to start when troubleshooting is running [`kbk checks`](#checks) to check for any common errors, misconfigurations, etc.

Another good resource is `kubectl get events`, which will provide a high level overview of the events in the cluster. Kubernetes events are a resource type in Kubernetes that are automatically created when other resources have state changes, errors, or other messages that should be broadcast to the system.

Given the issue you are observing, you may want to focus on either the cluster (and its underlying infrastructure) or application itself.

### Clusters

The first thing to debug in your cluster is if your nodes are all registered correctly.

```sh
kubectl get nodes
```

And verify that all of the nodes you expect to see are present and that they are all in the `Ready` state.

You may also want to view the logs associated with Kubernetes components. 

<!-- Note that you can use `kbk cluster leaders` and `kbk get pods` to assist in identifying leaders and pod names. -->

You can check the current leaders using `kubectl`:

- Controller Manager: `kubectl -n kube-system get endpoints kube-controller-manager -o jsonpath='{.metadata.annotations.control-plane\.alpha\.kubernetes\.io/leader}'`
- Scheduler: `kubectl -n kube-system get endpoints kube-scheduler -o jsonpath='{.metadata.annotations.control-plane\.alpha\.kubernetes\.io/leader}'`

Master only:

|Component|Log Location|Description|
|---|---|---|
|kube-apiserver|`kbk logs kube-system <kube-apiserver-pod-name>`|API Server, responsible for serving the API|
|kube-scheduler|`kbk logs kube-system <kube-scheduler-leader-pod-name>`|Scheduler, responsible for making scheduling decisions|
|kube-controller-manager|`kbk logs kube-system <kube-controller-manager-leader-pod-name>`|Controller that manages replication controllers|

All nodes:

|Component|Log Location|Description|
|---|---|---|
|kubelet|`less <node-ip>/kubelet.service.log`|Kubelet, responsible for running containers on the node|
|kube-proxy|`kbk logs kube-system <kube-proxy-pod-name>`|Kube Proxy, responsible for service load balancing|

#### Specific scenarios

- `kube-apiserver` crashing or host is offline
  - Unable to stop, update, or start new pods, services, replication controller
  - Existing pods and services should continue to work normally, unless they depend on the Kubernetes API
- `kube-apiserver` backing storage lost
  - `kube-apiserver` should fail to come up
  - Kubelets will not be able to reach it but will continue to run the same pods and provide the same service proxying
  - Manual recovery or recreation of apiserver state necessary before apiserver is restarted
- Supporting services (node controller, replication controller manager, scheduler, etc.) shutdown or crashing
  - Currently these are colocated with the apiserver and their unavailability has similar consequences to that of the apiserver.
- Individual node shutdown
  - Pods on that node stop running
- Network partition
  - Partition A thinks the nodes in partition B are down; partition B thinks the apiserver is down. (Assuming the master node ends up in partition A)
- Kubelet software fault
  - Crashing kubelet cannot start new pods on the node
  - Kubelet might delete pods
  - Node marked unhealthy
  - Replication controllers start new pods elsewhere

### Applications

The first step in troubleshooting is triage. What is the problem? Is it your Pods, your Replication Controller or your Service?

#### Debugging Pods

The first step in debugging a Pod is taking a look at it. Check the current state of the Pod and recent events with the following command:

```sh
kubectl describe pod <pod-name> -n <namespace>
```

Look at the state of the containers in the pod. Are they all `Running`? Have there been recent restarts? What do the events tell you?

##### My pod stays pending

If a Pod is stuck in `Pending` it means that it can not be scheduled onto a node. Generally this is because there are insufficient resources of one type or another that prevent scheduling. Look at the output of the `kubectl describe ...` command above. There should be messages from the scheduler about why it can not schedule your pod. Reasons include:

- You don’t have enough resources: You may have exhausted the supply of CPU or Memory in your cluster, in this case you need to delete Pods, adjust resource requests, or add new nodes to your cluster.
- You are using hostPort: When you bind a Pod to a hostPort there are a limited number of places that pod can be scheduled. In most cases, hostPort is unnecessary, try using a Service object to expose your Pod. If you do require hostPort then you can only schedule as many Pods as there are nodes in your Kubernetes cluster.

##### My pod stays waiting

If a Pod is stuck in the `Waiting` state, then it has been scheduled to a worker node, but it can’t run on that machine. Again, the information from `kubectl describe ...` should be informative. The most common cause of `Waiting` pods is a failure to pull the image. In that case, there are three things to check:

- Make sure that you have the name of the image correct.
- Have you pushed the image to the repository?
- Run a manual `docker pull <image>` on your machine to see if the image can be pulled.

##### My pod is crashing or otherwise unhealthy

Take a look at the logs of the current container:

```sh
kbk logs <namespace> <pod-name>
```

You may also want to check the Kubelet and kube-scheduler logs (See cluster troubleshooting section above).

#### Debugging Replication Controllers

Replication controllers are fairly straightforward. They can either create Pods or they can’t. If they can’t create pods, then please refer to the instructions above to debug your pods.

You can also use `kubectl describe rc <controller-name> -n <namespace>` to inspect events related to the replication controller.

#### Debugging Services

Services provide load balancing across a set of pods. There are several common problems that can make Services not work properly. The following instructions should help debug Service problems.

First, verify that there are endpoints for the service. For every Service object, the apiserver makes an `endpoints` resource available.

You can view this resource with:

```sh
kubectl get endpoints -A
```

Make sure that the endpoints match up with the number of containers that you expect to be a member of your service. For example, if your Service is for an nginx container with 3 replicas, you would expect to see three different IP addresses in the Service’s endpoints.

##### My service is missing endpoints

If you are missing endpoints, try listing pods using the labels that Service uses. Imagine that you have a Service where the labels are:

```yaml
...
spec:
  - selector:
     name: nginx
     type: frontend
```

You can then check the pods that match this selector, verifying that the list matches the Pods that you expect to provide your Service.

If the list of pods matches expectations, but your endpoints are still empty, it’s possible that you don’t have the right ports exposed. If your service has a `containerPort` specified, but the Pods that are selected don’t have that port listed, then they won’t be added to the endpoints list.

Verify that the pod’s `containerPort` matches up with the Service’s `containerPort`.

##### Network traffic is not forwarded

If you can connect to the service, but the connection is immediately dropped, and there are endpoints in the endpoints list, it’s likely that the proxy can’t contact your pods.

There are three things to check:

- Are your pods working correctly? Look for restart count, and debug pods.
- Can you connect to your pods directly? Get the IP address for the Pod, and try to connect directly to that IP.
- Is your application serving on the port that you configured? Kubernetes doesn’t do port remapping, so if your application serves on 8080, the `containerPort` field needs to be 8080.
