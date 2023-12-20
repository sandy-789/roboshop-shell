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

VALIDATE $? "Installing Node-Js:18" 

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

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip

VALIDATE $? "download cart" &>>$LOGFILE

cd /app 

unzip -o /tmp/cart.zip &>>$LOGFILE


VALIDATE $? "unzipping file" &>>$LOGFILE

npm install &>>$LOGFILE

VALIDATE $? "installing dependencies" &>>$LOGFILE

cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service

VALIDATE $? "Copying cart service file"

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "deamon reload" 

systemctl enable cart  &>>$LOGFILE

VALIDATE $? "enabling cart" 

systemctl start cart &>>$LOGFILE

VALIDATE $? "starting cart" 

