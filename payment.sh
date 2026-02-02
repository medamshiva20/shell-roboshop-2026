#!/bin/bash 

USERID=$(id -u)
LOGS_DIR="/var/log/shell-roboshop"
LOG_FILE="$LOGS_DIR/$0.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

mkdir -p $LOGS_DIR

if [ $USERID -ne 0 ] ;
then 
    echo -e "$R Please run this script with root user $N"
    exit 1
fi 

VALIDATE(){
    if [ $1 -ne 0 ] ;
    then 
        echo -e "$2 ...$R FAILURE $N"
        exit 1
    else 
        echo -e "$2 ...$G SUCCESS $N"
    fi
}



dnf install python3 gcc python3-devel -y &>>$LOG_FILE
VALIDATE $? "Installing Python"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ] ;
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating system user"
else 
   echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi

mkdir -p /app
VALIDATE $? "Creating app directory"

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip  &>>$LOG_FILE
VALIDATE $? "Downloading payment code"

cd /app 
VALIDATE $? "Moving to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "Uzip payment code"

pip3 install -r requirements.txt &>>$LOG_FILE
VALIDATE $? "Installing dependencies"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
VALIDATE $? "Created systemctl service"

systemctl daemon-reload
systemctl enable paymen &>>$LOG_FILE
systemctl start payment
VALIDATE $? "Enabled and started payment"