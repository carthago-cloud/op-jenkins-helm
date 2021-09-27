# op-svc-jenkins-helm
Operator Service for Jenkins – helm chart

### Turn on debug mode
Add: --debug=true in chart/op-svc-jenkins/values.yaml

```yaml
  args:
    - --leader-elect=true
    - --debug=true
```