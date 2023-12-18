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

dnf module disable nodejs -y

VALIDATE $? "Disable nodejs" &>> $LOGFILE

dnf module enable nodejs:18 -y

VALIDATE $? "Enable nodejs:18" &>>$LOGFILE
 
dnf install nodejs -y

VALIDATE $? "Installing node-js" &>>$LOGFILE

useradd roboshop

VALIDATE $? "CReate roboshop user"

mkdir /app

VALIDATE $? "creating app directory" &>>$LOGFILE

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

VALIDATE $? "download catalouge" &>>$LOGFILE

cd /app 

unzip /tmp/catalogue.zip


VALIDATE $? "unzipping file" &>>$LOGFILE

npm install 

VALIDATE $? "installing dependencies" &>>$LOGFILE

cp /c/users/sandeep_vadla/devops/repos/roboshop-shell/catalouge.service /etc/systemd/system/catalouge.service

VALIDATE $? "Copying catalouge service file" &>>$LOGFILE

systemctl daemon-reload

VALIDATE $? "deamon reload" &>>$LOGFILE

systemctl enable catalogue

VALIDATE $? "enabling catalouge" &>>$LOGFILE

systemctl start catalogue &>>$LOGFILE

VALIDATE $? "starting catalouge" &>>$LOGFILE

cp /c/users/sandeep_vadla/devops/repos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "Copying mongodb repo

dnf install mongodb-org-shell -y

mongo --host mongodb.prorb.online </app/schema/catalogue.js



