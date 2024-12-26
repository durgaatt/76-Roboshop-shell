#!/bin/bash

uid=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOG_FILE="output.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

validate() {
    if [ $1 -eq 0 ]; then
        echo -e "$G $2 successfully $N"
        echo "$DATE $2 successfully" &>> "$LOG_FILE"
    else
        echo -e "$R $2  failed $N"
        echo "$DATE $2  failed" &>> "$LOG_FILE"
    fi
}

if [ $uid -ne 0 ]; then
    echo -e "$R Please run the script as root user. Current UID: $uid $N"
    exit 1
else
    echo -e "$G You are running this script as root user. UID: $uid $N"
    echo "$DATE Running script as root. UID: $uid" >> "$LOG_FILE"
fi

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> "$LOG_FILE"

dnf install mongodb-org -y &>> "$LOG_FILE"
validate $? "mongodb Install" 

systemctl enable mongod &>> "$LOG_FILE" 
validate $? "Service enable" 

systemctl start mongod &>> "$LOG_FILE"
validate $? "Service start"

sudo sed -i 's/127\.0\.0\.1/0.0.0.0/g' /etc/mongod.conf &>> "$LOG_FILE"

systemctl restart mongod &>> "$LOG_FILE"
validate $? "Service restart"