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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "Copied mongo DB Repo"

dnf install mongodb-org -y 

VALIDATE $? "Installing mongodb" &>> $LOGFILE

systemctl enable mongod

systemctl start mongod &>> $LOGFILE

VALIDATE $? "starting mongodb" &>> $LOGFILE

sed -i 's/127.0.0.1/0.0.0/g' /etc/mongod.conf &>> $LOGFILE

VALIDATE $? "REMOTE acess to mondogb"

systemctl restart mongod &>> $LOGFILE

VALIDATE $? "Restart mondogb" $LOGFILE