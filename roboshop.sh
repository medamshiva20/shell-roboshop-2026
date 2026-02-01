#!/bin/bash 

SG_ID="sg-0e952a919361d18ab"
AMID_ID="ami-0220d79f3f480ecf5"
SUBNET_ID="subnet-0e2d2a34508988aa6"


for instance in $@
do
INSTANCE_ID=aws ec2 run-instances \
    --image-id $AMID_ID
    --instance-type "t2.micro" \
    --subnet-id $SUBNET_ID \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_ID}]" \
    --query 'Instances[0].InstanceId' \
    --output text
    if [ $INSTANCE_ID == "frontend" ] ;
    then 
         IP=$(aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PublicIpAddress' \
            --output text)
    else
         IP=$(aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PrivateIpAddress' \
            --output text)
    fi
    echo "IP Address"

done