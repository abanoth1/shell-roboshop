#!/bin/bash
# CREATING THE INSTANCE DYNAMICALLY IN AWS USING SHELL SCRIPTING AND AWS CLI 

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-05699f53cbbd17753"
ZONE_ID="Z0643845MTWJNN2ZJCER"
DOMAIN_NAME="daws86s.me"

for instance in "$@"
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

    # GET THE PUBLIC IP ADDRESS OF THE INSTANCE CREATED
    if [ $instance != "frontend" ]; then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
        RECORD_NAME="$instance.$DOMAIN_NAME" # private ip for backend and database, creating record name
        # CREATING THE RECORD IN ROUTE53 FOR PRIVATE IP ADDRESS
    else
          IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
          RECORD_NAME="$DOMAIN_NAME" # public ip for frontend, creating record name
          # CREATING THE RECORD IN ROUTE53 FOR PUBLIC IP ADDRESS
    fi

 echo "$instance: $IP"


    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Updating record set"
        ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$RECORD_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP'"
            }]
        }
        }]
    }
    '

done