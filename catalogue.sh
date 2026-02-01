#!/bin/bash

USERID=$(id -u)
LOGS_DIR="/var/log/shell-roboshop"
LOG_FILE="$LOGS_DIR/$0.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"

if [ $USERID -ne 0 ] ;
then 
    echo -e "$R Please run this script with root user $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ] ;
    then
        echo -e "$2...$R FAILURE $N"
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

dnf module disable nodejs -y 
VALIDATE $? "Disabling NodeJS Default version"

dnf module enable nodejs:20 -y 
VALIDATE $? "Enabling NodeJS 20"

dnf install nodejs -y 
VALIDATE $? "Install NodeJS"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "Creating system user"

mkdir /app
VALIDATE $? "Creating app directory"
