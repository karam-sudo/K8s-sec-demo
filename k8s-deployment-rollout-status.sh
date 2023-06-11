#!/bin/bash

#k8s-deployment-rollout-status.sh

sleep 1800s

if [[ $(kubectl -n default rollout status deployment ${deploymentName} --timeout 5s) != *"successfully rolled out"* ]]; 
then     
	echo "Deployment ${deploymentName} Rollout has Failed"
    kubectl -n default rollout undo deployment ${deploymentName}
    exit 1;
else
	echo "Deployment ${deploymentName} Rollout is Success"
fi