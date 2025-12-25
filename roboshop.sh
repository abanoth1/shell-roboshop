#!/bin/bash
# CREATING THE INSTANCE IN AWS USING SHELL SCRIPTING AND AWS CLI DYNAMICALLY

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-05699f53cbbd17753"

for instance in "$@"
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

    # GET THE PUBLIC IP ADDRESS OF THE INSTANCE CREATED
    if [ $instance != "frontend" ]; then
        IP =$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
    else
          IP =$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    fi
    echo "$instance: $IP"
done