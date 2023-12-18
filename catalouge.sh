#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script stareted executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 # you can give other than 0
else
    echo "You are root user"
fi # fi means reverse of if, indicating condition end

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disable nodejs" 

dnf module enable nodejs:18 -y &>>$LOGFILE

VALIDATE $? "Enable nodejs:18" 
 
dnf install nodejs -y &>>$LOGFILE

VALIDATE $? "Installing node-js" 

id roboshop #if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGFILE

VALIDATE $? "creating app directory" 

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

VALIDATE $? "download catalouge" &>>$LOGFILE

cd /app 

unzip -o /tmp/catalogue.zip &>>$LOGFILE


VALIDATE $? "unzipping file" 

npm install &>>$LOGFILE

VALIDATE $? "installing dependencies" 

cp /users/sandeep_vadla/devops/repos/roboshop-shell/catalouge.service /etc/systemd/system/catalouge.service

VALIDATE $? "Copying catalouge service file" &>>$LOGFILE

systemctl daemon-reload

VALIDATE $? "deamon reload" &>>$LOGFILE

systemctl enable catalogue

VALIDATE $? "enabling catalouge" &>>$LOGFILE

systemctl start catalogue &>>$LOGFILE

VALIDATE $? "starting catalouge" &>>$LOGFILE

cp /users/sandeep_vadla/devops/repos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "Copying mongodb repo

dnf install mongodb-org-shell -y

mongo --host mongodb.prorb.online </app/schema/catalogue.js



