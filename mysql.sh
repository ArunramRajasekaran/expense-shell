#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shellscript-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMETAMP=$(date +%Y-%m-%d-%H-%M)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

VALIDATE(){
if [ $1 -ne 0 ]
    then
        echo -e "$2.... $R Failure $N"
        exit 1
    else
        echo -e "$2....$G Success $N"
    fi
}

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo "ERROR:: YOu must have sudo access to execute this script"
        exit 1
    fi
}

echo "Script started executing at; $TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_ROOT
dnf install mysql-server -y &>>LOG_FILE_NAME
VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld &>>LOG_FILE_NAME
VALIDATE $? "Enabling MySQL Server"

systemctl start mysqld &>>LOG_FILE_NAME
VALIDATE $? "Starting MySQL Server"

mysql_secure_installation --set-root-password ExpenseApp@1 &>>$LOG_FILE_NAME
VALIDATE $? "Setting Root Password"

if [ $? -ne 0 ]
then
    echo "mysql root password not setup" &>>$LOG_FILE_NAME
    mysql_secure_installation --set-root-password ExpenseApp@1
    VALIDATE $? "Setting Root Password"
else
    echo -e "MySQL Root Password already setup.... $Y SKIPPING $N"
fi

