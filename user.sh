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

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip

VALIDATE $? "download user" &>>$LOGFILE

cd /app 

unzip -o /tmp/user.zip &>>$LOGFILE


VALIDATE $? "unzipping file" &>>$LOGFILE

npm install &>>$LOGFILE

VALIDATE $? "installing dependencies" &>>$LOGFILE

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service

systemctl daemon-reload &>>$LOGFILE


VALIDATE $? "deamon reload" 

systemctl enable user  &>>$LOGFILE

VALIDATE $? "enabling user" 

systemctl start user &>>$LOGFILE

VALIDATE $? "starting user" 

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "Copying mongodb repo"

dnf install mongodb-org-shell -y &>>$LOGFILE

VALIDATE $? "Installing MongoDB client"

mongo --host $MONGDB_HOST </app/schema/user.js &>> $LOGFILE

VALIDATE $? "Loading user data into MongoDB"