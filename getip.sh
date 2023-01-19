#!/bin/bash
#sudo apt install jq -y
sleep 30

CLASTER_NAME="petclinic_ecs_cluster"
SERVICE_NAME="petclinic_service"

TASK_ARN=$(aws ecs list-tasks --cluster "$CLASTER_NAME" --service-name "$SERVICE_NAME" --query 'taskArns[0]' --output text)
TASK_DETAILS=$(aws ecs describe-tasks --cluster "$CLASTER_NAME"  --task "${TASK_ARN}" --query 'tasks[0].attachments[0].details')
ENI=$(echo $TASK_DETAILS | jq -r '.[] | select(.name=="networkInterfaceId").value')
IP=$(aws ec2 describe-network-interfaces --network-interface-ids "${ENI}" --query 'NetworkInterfaces[0].Association.PublicIp' --output text)

echo "$IP"