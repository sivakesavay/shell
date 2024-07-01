#!/bin/bash

userid=$(id -u)
timestamp=$(date +%F-%H-%M-%S)
scriptname=$(echo $0 | cut -d "." -f1)
logfile=/tmp/$scriptname-$$timestamp.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


validate(){
    if [$1 -ne 0]
    then
        echo -e "$2..$R failure $N"
        exit1
    else
        echo -e "$2..$G success $N"
    fi
}

if [$userid -ne 0]
then
    echo "run this script with root user"
    exit 1
else
    echo "you are super user"
fi


dnf module disable nodejs -y &>>$logfile
validate $? "disabling nodejs"

dnf module enable nodejs:20 -y &>>$logfile
validate $? "enable nodejs"

dnf install nodejs -y &>>$logfile
validate $? "install nodejs"

id expense &>>$logfile
if [$? -ne 0]
then
    useradd expense &>>$logfile
    validate $? "creating user expense"
else
    echo -e "expense user already created...$Y skipping...$N"
fi

