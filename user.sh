#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOG_FILE="$LOGS_FOLDER/$0.log"
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.sivadevops.site

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


if [ $USERID -ne 0 ] ;
then 
    echo -e "$R Please run this script with root user $N" | tee -a $LOG_FILE
    exit 1
fi 


mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ] ;
    then 
        echo -e "$2 ...$R FAILURE $N"
        exit 1
    else 
        echo -e "$2 ...$G SUCCESS $N"
    fi
}


dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling NodeJS Default version"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling NodeJS 20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Install NodeJS"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ] ;
then 
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi

mkdir -p /app
VALIDATE "Creating app directory"

curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip  &>>$LOG_FILE
VALIDATE $? "Downloading user code"

cd /app
VALIDATE $? "Moving to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/user.zip &>>$LOG_FILE
VALIDATE $? "Uzip user code"

npm install &>>$LOG_FILE
VALIDATE $? "Installing dependencies"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
VALIDATE $? "Created systemctl service"

systemctl daemon-reload 
systemctl enable user &>>$LOG_FILE
systemctl start user
VALIDATE $? "Starting and enabling user"
