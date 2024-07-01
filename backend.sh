#!/bin/bash

userid=$(id -u)
timestamp=$(date +%F-%H-%M-%S)
scriptname=$(echo $0 | cut -d "." -f1)
logfile=/tmp/$scriptname-$$timestamp.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "please enter db password:"
read mysql_root_password

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

mkdir /app &>>$logfile
validate $? "crating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip 
validate $? "downloding backend code"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>$logfile
validate $? "extracted backend code"

npm install &>>$logfile
validate $? "installing nodejs dependecies"

cp /home/ec2-user/shell/backend.service /etc/systemd/system/backend.service &>>$logfile
validate $? "copied backend service"

systemctl daemon-reload &>>$logfile
systemctl start backend &>>$logfile
systemctl enable backend &>>$logfile
validate $? "backend start and enabled"

dnf install mysql -y &>>$logfile
validate $? "installing mysql client"

mysql -h db.jasdevops.cloud -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$logfile
validate $? "schema loading"

systemctl restart backend &>>$logfile