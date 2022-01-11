#!/bin/zsh

echo "start"

READY=false
while [[ $READY == false ]]; do
  READY=$(kubectl get pods -n operator --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | \
    kubectl get pod -n operator -o custom-columns=":status.containerStatuses[0].ready") | tr -d '\n'

  echo $READY
done

echo "Operator got ready!"