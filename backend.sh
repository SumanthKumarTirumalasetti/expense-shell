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

echo "Script started executing at: $TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_ROOT

mkdir -p /var/log/expense-logs
validate $? "Expense-logs directory creation"

dnf module disable nodejs -y &>>$LOG_FILE_NAME
validate $? "Disabling existing default nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
validate $? "Enabling nodejs:20"

dnf install nodejs -y &>>$LOG_FILE_NAME
validate $? "Installing NodeJS"

useradd expense &>>$LOG_FILE_NAME
validate $? "Adding expense user"

mkdir /app &>>$LOG_FILE_NAME
validate $? "Creating app directory" &>>$LOG_FILE_NAME

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
validate $? "Download the application code"

cd /app &>>$LOG_FILE_NAME

unzip /tmp/backend.zip &>>$LOG_FILE_NAME
validate $? "Extracting backend.zip in app directory"

npm install &>>$LOG_FILE_NAME
validate $? "Installing dependencies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service &>>$LOG_FILE_NAME
validate $? "Copying backend.service to /etc/systemd/system location"

dnf install mysql -y &>>$LOG_FILE_NAME
validate $? "Installing mysql client"

mysql -h mysql.rigelstar.online -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE_NAME
validate $? "Setting up the transactions schema and tables"

systemctl daemon-reload &>>$LOG_FILE_NAME
validate $? "daemon-reload"

systemctl start backned &>>$LOG_FILE_NAME
validate $? "Restarting backend"

systemctl enable backend &>>$LOG_FILE_NAME
validate $? "Enabling backend"
