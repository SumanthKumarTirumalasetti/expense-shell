#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/expense-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIME_STAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIME_STAMP.log"


validate() {

    if [ $? -ne 0 ]
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}


CHECK_ROOT() {

    if [ $USERID -ne 0 ]
    then
        echo "ERROR:: You must have sudo access to execute this script"
        exit 1
    fi
}


mkdir -p /var/log/expense-logs
validate $? "Expense-logs directory creation"

echo "Script started executing at: $TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_ROOT

dnf install nginx -y &>>$LOG_FILE_NAME
validate $? "Installing nginx server"

systemctl enable nginx &>>$LOG_FILE_NAME
validate $? "enable nginx server"

systemctl start nginx &>>$LOG_FILE_NAME
validate $? "Starting nginx server"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE_NAME
validate $? "Removing existing version of codes"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE_NAME
validate $? "Downloading latest code in /tmp"

cd /usr/share/nginx/html &>>$LOG_FILE_NAME
validate $? "Moving to HTML directory"

unzip /tmp/frontend.zip &>>$LOG_FILE_NAME
validate $? "Unzipping frontend code"

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf &>>$LOG_FILE_NAME
validate $? "Copying expense.conf to default.d directory"

systemctl restart nginx &>>$LOG_FILE_NAME
validate $? "Restarting nginx server"

