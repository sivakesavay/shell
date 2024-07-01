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

dnf install nginx -y &>>$logfile
validate $? "installing nginx"

systemctl enable nginx &>>$logfile
validate $? "enabling nginx"

systemctl start  &>>$logfile
validate $? "starting nginx"

rm -rf /usr/share/nginx/html/* &>>$logfile
validate $? "removing existing cotent"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$logfile
validate $? "downloding frontend code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$logfile
validate $? "extracting frontend code"

cp /home/ec2-user/shell/expense.conf /etc/nginx/default.d/expense.conf &>>$logfile
validate $? "coping expence conf"

systemctl restart nginx &>>$logfile