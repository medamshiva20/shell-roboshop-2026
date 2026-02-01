#!/bin/bash 

SG_ID="sg-0e952a919361d18ab"
AMID_ID="ami-0220d79f3f480ecf5"
SUBNET_ID="subnet-0e2d2a34508988aa6"


for instance in $@
do
  INSTANCE_ID=$( aws ec2 run-instances \
    --image-id ami-0220d79f3f480ecf5 \
    --instance-type t2.micro \
    --subnet-id subnet-0e2d2a34508988aa6 \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=$instance},{Key=Environment,Value=Test}]' 'ResourceType=volume,Tags=[{Key=Project,Value=Marketing}]' )
done