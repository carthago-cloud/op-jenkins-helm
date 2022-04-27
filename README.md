# carthago-op-jenkins-helm
Carthago Operator for Jenkins – Helm chart

## Install Operator and Jenkins from the chart
### Prerequisites
* a Kubernetes cluster with 2 namespaces: one for Carthago Operator, and one for Jenkins
* Helm
### Installation process
First, add this Helm chart repository to your list of chart repositories:
```bash
$ helm repo add carthago https://carthago-cloud.github.io/op-jenkins-helm/
```
Then, `helm install` the Operator:
```bash
$ helm install carthago-operator carthago/carthago-op-jenkins -n <operator-namespace>
```
Finally, `helm install` Jenkins:
```bash
$ helm install jenkins carthago/carthago-op-jenkins -n <jenkins-namespace>
```

### Customize your installation with values.yaml
You can customize installations of Operator and Jenkins (along with other Custom Resources related to Jenkins) using `values.yaml`
files for their respective charts: `carthago-op-jenkins` and `carthago-op-jenkins-crs`.
You can find those files in charts/carthago-op-jenkins and charts/carthago-op-jenkins-crs directories here on this repository,
and also in the documentation for Carthago Operator for Jenkins.

To customize Operator or Jenkins and other Custom Resources this way, edit the `values.yaml` file and pass it to `helm install`
by appending `-f <path-to-values.yaml-file>` to your `helm install` command.

## Turn on debug mode
Add: --debug=true in charts/carthago-op-jenkins/values.yaml

```yaml
  args:
    - --leader-elect=true
    - --debug=true
```