#!/bin/bash
# WORKING WITH COLORS IN SHELL SCRIPTING AND ADDING COLORS TO OUTPUT  AND ALSO USING FUNCTIONS AND LOOPS
# THIS SCRIPT IS TO INSTALL CATALOGUE SERVICE

set -euo pipefail

trap 'echo "There is an error in $LINENO, Command is: $BASH_COMMAND"' ERR
# The above trap will catch errors and print the line number and command that caused the error
# This is useful for debugging

R='\e[31m' # RED COLOR
G='\e[32m' # GREEN COLOR
Y='\e[33m' # YELLOW COLOR
B='\e[34m' # BLUE COLOR
M='\e[35m' # MAGENTA COLOR
C='\e[36m' # CYAN COLOR
W='\e[37m' # WHITE COLOR
N='\e[0m'  # NO COLOR

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
SCRIPT_DIR=$PWD
MONGODB_HOST="mongodb.daws86s.me"

LOGS_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
# log file path /var/log/shell-roboshop/16-logs.log

mkdir -p $LOGS_FOLDER
echo "script execution started at : $(date)" | tee -a $LOGS_FILE

USERID=$(id -u)
if [ "$USERID" -ne 0 ]; then
    echo "Error: Please run this script as root user or using sudo."
    exit 1 # failure is indicated by non-zero exit status
fi

        # HERE $1 is the exit status of the last executed command
        # and $2 is the name of the package
        # addingn colors to the output
        # adding loops to install multiple packages

# nodejs installation steps
dnf module disable nodejs -y &>> $LOGS_FILE
dnf module enable nodejs:20 -y &>> $LOGS_FILE
dnf install nodejs -y &>> $LOGS_FILE
echo -e " Installing Nodejs .... $G success $N"
# -e enables interpretation of backslash escapes

# check if the roboshop user is present, if not create the user, unfornately the useradd command throws error if the user is already present
# i forgot to declare id and log file redirection

id roboshop &>> $LOGS_FILE 
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOGS_FILE

else
    echo -e "roboshop user is already present .... $Y skipped $N"
fi

mkdir -p /app
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>> $LOGS_FILE


cd /app
rm -rf /app/* # remove old content if any
unzip /tmp/catalogue.zip &>> $LOGS_FILE


npm install &>> $LOGS_FILE


cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service

systemctl daemon-reload
systemctl enable catalogue &>> $LOGS_FILE
echo -e "Enabling Catalogue Service .... $G success $N"
#

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongoshdbbdb -y &>> $LOGS_FILE
echo -e "Installing Mongodb Shell Client .... $G success $N"

INDEX=$(mongosh mongodb.daws86s.me --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>> $LOGS_FILE
   
else
    echo -e "Catalogue Schema is already present in Mongodb .... $Y skipped $N"
fi

systemctl restart catalogue
echo -e "Restarting Catalogue Service .... $G success $N"

## catalogue service and route 53 record for catalogue is also created by using the aws cli in the shell-scripting 