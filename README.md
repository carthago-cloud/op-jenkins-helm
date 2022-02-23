# op-svc-jenkins-helm
Carthago Operator for Jenkins – helm chart

### Turn on debug mode
Add: --debug=true in chart/carthago-op-jenkins/values.yaml

```yaml
  args:
    - --leader-elect=true
    - --debug=true
```

### Helm 3.7.0
A few major changes were made to the experimental OCI feature:

- `helm chart export` has been removed
- `helm chart list` has been removed
- `helm chart pull` has been replaced with `helm pull`
- `helm chart push` has been replaced with `helm push`
- `helm chart remove` has been removed
- `helm chart save` has been replaced `with helm package`

To pull helm chart from OCI registry you need to provide `--version <version>`
```bash
helm pull oci://operatorservice.azurece.io/charts/op-svc-jenkins --version 0.1.2
```