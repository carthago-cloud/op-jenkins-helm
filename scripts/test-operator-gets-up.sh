#!/bin/bash
#
# Verify that the Operator gets both Running and Ready within 3 minutes.
# Requires namespace the Operator should be in as a positional argument.

if [ $# -eq 0 ]; then
    echo "You have to provide Operator namespace as a positional argument."
    exit 1
fi

readonly OPERATOR_NAMESPACE=$1
readonly NUMBER_OF_RETRIES=90
readonly CHECK_INTERVAL=2

if [[ -z $(kubectl get namespace "$OPERATOR_NAMESPACE" --ignore-not-found) ]]; then
  echo "Namespace $OPERATOR_NAMESPACE doesn't exist."
  exit 1
fi

for (( i = 0; i <= NUMBER_OF_RETRIES; i++)); do
  sleep $CHECK_INTERVAL

  PHASE=$(kubectl get pod -n "$OPERATOR_NAMESPACE" -l app.kubernetes.io/name=carthago-op-jenkins -o jsonpath="{.items[0].status.phase}" --ignore-not-found)
  READY=$(kubectl get pod -n "$OPERATOR_NAMESPACE" -l app.kubernetes.io/name=carthago-op-jenkins -o jsonpath="{.items[0].status.containerStatuses[0].ready}" --ignore-not-found)

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
  kubectl logs -n operator -l app.kubernetes.io/name=carthago-op-jenkins
else
  echo "Operator didn't get Running and Ready within 3 minutes. Good luck with troubleshooting."

  echo "Here are the logs from Operator pod:"
  kubectl logs -n operator -l app.kubernetes.io/name=carthago-op-jenkins

  echo "Here are the events from Operator namespace:"
  kubectl get events -n "$OPERATOR_NAMESPACE" --sort-by='.lastTimestamp'

  echo "Here are the events from default namespace:"
  kubectl get events --sort-by='.lastTimestamp'

  exit 1
fi
