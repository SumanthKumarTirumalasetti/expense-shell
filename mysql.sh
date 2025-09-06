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

echo "Script started executing at: $TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_ROOT


dnf install mysql-server -y &>>$LOG_FILE_NAME
validate $? "Installing MySQL Server"

systemctl enable mysqld &>>$LOG_FILE_NAME
validate $? "Enabling MySQL Server"

systemctl start mysqld &>>$LOG_FILE_NAME
validate $? "Starting MySQL Server"

#mysql_secure_installation --set-root-pass ExpenseApp@1 -e 'show databases;'

mysql -h mysql.rigelstar.online -u root -pExpenseApp@1 -e 'show databases;'&>>$LOG_FILE_NAME

if [ $? -ne 0 ]
then
    echo "MySQL Root password not setup" &>>$LOG_FILE_NAME
    mysql_secure_installation --set-root-pass ExpenseApp@1 
    validate $? "Setting Root Password"
else
    echo -e "MySQL Root password already setup ... $G SKIPPING $N"
fi

