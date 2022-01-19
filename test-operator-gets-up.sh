#!/bin/bash
#
# Verify that the Operator gets both Running and Ready within 3 minutes.
# Requires namespace the Operator should be in as a positional argument.

if [ $# -eq 0 ]; then
    echo "You have to provide Jenkins namespace as a positional argument."
    exit 1
fi

readonly OPERATOR_NAMESPACE=$1

for _ in {0..90}
do
  sleep 2

  PHASE=$(kubectl get pod -n "$OPERATOR_NAMESPACE" -l app.kubernetes.io/name=op-svc-jenkins -o jsonpath="{.items[0].status.phase}" --ignore-not-found)
  READY=$(kubectl get pod -n "$OPERATOR_NAMESPACE" -l app.kubernetes.io/name=op-svc-jenkins -o jsonpath="{.items[0].status.containerStatuses[0].ready}" --ignore-not-found)

  if [ -z "$PHASE" ]; then
    echo "Operator pod hasn't yet been created, waiting another 2 secs"
  else
    echo "Operator pod phase: $PHASE"
    echo -e "Operator pod ready: $READY\n"
  fi

  if [[ $PHASE == Running && $READY == true ]]; then
    break
  fi
done

if [[ $PHASE == Running && $READY == true ]]; then
  echo "Operator should be fully up and running! Here are the logs from the Operator pod:"
  kubectl logs -n operator -l app.kubernetes.io/name=op-svc-jenkins
else
  echo "Operator didn't get Running and Ready within 3 minutes. Good luck with troubleshooting."

  echo "Here are the logs from Operator pod:"
  kubectl logs -n operator -l app.kubernetes.io/name=op-svc-jenkins

  echo "Here are the events from Operator namespace:"
  kubectl get events -n "$OPERATOR_NAMESPACE" --sort-by='.lastTimestamp'

  echo "Here are the events from default namespace:"
  kubectl get events --sort-by='.lastTimestamp'

  exit 1
fi
