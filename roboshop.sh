#!/bin/bash 

SG_ID="sg-0e952a919361d18ab"
AMID_ID="ami-0220d79f3f480ecf5"
SUBNET_ID="subnet-0e2d2a34508988aa6"
ZONE_ID="Z08856813FAW6FVTNI33W"
DOMAIN_NAME="sivadevops.site"


for instance in $@
do
  INSTANCE_ID=$( aws ec2 run-instances \
    --image-id ami-0220d79f3f480ecf5 \
    --instance-type "t2.micro" \
    --subnet-id subnet-0e2d2a34508988aa6 \
    --security-group-ids sg-0e952a919361d18ab \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text )
if [ $instance == "frontend" ] ;
then
    IP=$( aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PublicIpAddress' \
            --output text
        )
        RECORD_NAME="$DOMAIN_NAME"
else
    IP=$( aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PrivateIpAddress' \
            --output text
        )
        RECORD_NAME="$instance.$DOMAIN_NAME"
fi
    echo "IP Address:$IP"
  aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Updating record",
        "Changes": [
            {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "'$RECORD_NAME'",
                "Type": "A",
                "TTL": 1,
                "ResourceRecords": [
                {
                    "Value": "'$IP'"
                }
                ]
            }
            }
        ]
    }
    '
    echo "record updated for $instance"
done