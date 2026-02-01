#!/bin/bash 

USERID=$(id -u)
LOGS_DIR="/var/log/shell-roboshop"
LOG_FILE="$LOGS_DIR/$0.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ] ;
then 
    echo -e "$R Please run this script with root user $N" | tee -a $LOG_FILE
    exit 1
fi

mkdir -p $LOGS_DIR

VALIDATE(){
    if [ $1 -ne 0 ] ;
    then 
        echo -e "$2...$R FAILURE $N" | tee -a $LOG_FILE
    else
        echo -e "$2...$G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling NodeJS Default version"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling NodeJS 20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Install NodeJS"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
VALIDATE $? "Creating system user"

mkdir /app &>>$LOG_FILE
VALIDATE $? "Creating app directory"
