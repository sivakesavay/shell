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

dnf install mysql-server -y &>>$logfile
validate $? "installing mysql server"

systemctl enable mysqld &>>$logfile
validate $? "enabling mysql server"

systemctl start mysqld &>>logfile
validate $? "starting my sql server"

mysql_secure_installation --set-root-pass ExpenseApp@1 &>>logfile
validate $? "settingup root password"

