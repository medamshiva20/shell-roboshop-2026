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


cp mongo.repo /etc/yum.repos.d/mongo.repo 
VALIDATE $? "Copying mongo repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Installing MongoDB Server"

systemctl enable mongod
VALIDATE $? "Enable MongoDB"

systemctl start mongod
VALIDATE $? "Start MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connections"

systemctl restart mongod
VALIDATE "Restarted MongoDB"