#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOG_FILE="$LOGS_FOLDER/$0.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ] ;
then 
    echo -e "$R Please run this script with root user $N" | tee -a $LOG_FILE
    exit 1
fi 



dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabling default redis version"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enable Redis:7"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Installed redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Allowing remote connections"

systemctl enable redis &>>$LOG_FILE
systemctl start redis 
VALIDATE "Enabled and started redis"