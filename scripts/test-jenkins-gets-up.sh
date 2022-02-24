#!/bin/bash
#
# Verify that Jenkins gets both Running and Ready within 5 minutes.
# Requires namespace the Jenkins should be in as a positional argument.

if [ $# -eq 0 ]; then
    echo "You have to provide Jenkins namespace as a positional argument."
    exit 1
fi

readonly JENKINS_NAMESPACE=$1
readonly NUMBER_OF_RETRIES=60
readonly CHECK_INTERVAL=5

if [[ -z $(kubectl get namespace "$JENKINS_NAMESPACE" --ignore-not-found) ]]; then
  echo "Namespace $JENKINS_NAMESPACE doesn't exist."
  exit 1
fi

for (( i = 0; i <= NUMBER_OF_RETRIES; i++)); do
  sleep $CHECK_INTERVAL

  PHASE=$(kubectl get pod -n "$JENKINS_NAMESPACE" -l carthago.com/kind=Jenkins -o jsonpath="{.items[0].status.phase}" --ignore-not-found)
  READY=$(kubectl get pod -n "$JENKINS_NAMESPACE" -l carthago.com/kind=Jenkins -o jsonpath="{.items[0].status.containerStatuses[0].ready}" --ignore-not-found)

  if [ -z "$PHASE" ]; then
    echo "Jenkins pod hasn't yet been created, waiting another 5 secs"
  else
    echo "Jenkins pod phase: $PHASE"
    echo -e "Jenkins is ready: $READY\n"
  fi

  if [[ $PHASE == Running && $READY == true ]]; then
    break
  fi
done

if [[ $PHASE == Running && $READY == true ]]; then
  echo "Jenkins should be fully up and running! Here are the logs from Jenkins pod:"
  kubectl logs -n "$JENKINS_NAMESPACE" -l carthago.com/kind=Jenkins
else
  echo "Jenkins didn't get Running and Ready within 5 minutes. Good luck with troubleshooting."

  echo "Here are the logs from Jenkins pod:"
  kubectl logs -n "$JENKINS_NAMESPACE" -l carthago.com/kind=Jenkins

  echo "Here are the logs from initial-config container:"
  kubectl logs -n "$JENKINS_NAMESPACE" -l carthago.com/kind=Jenkins -c initial-config

  echo "Here are the logs from jenkins-controller container:"
  kubectl logs -n "$JENKINS_NAMESPACE" -l carthago.com/kind=Jenkins -c jenkins-controller

  echo "Here are the logs from operator:"
  kubectl logs -n operator -l app.kubernetes.io/name=op-svc-jenkins

  echo "Here are the events from Jenkins namespace:"
  kubectl get events -n "$JENKINS_NAMESPACE" --sort-by='.lastTimestamp'

  echo "Here are the events from Operator namespace:"
  kubectl get events -n "$OPERATOR_NAMESPACE" --sort-by='.lastTimestamp'

  echo "Here are the events from default namespace:"
  kubectl get events --sort-by='.lastTimestamp'

  exit 1
fi
