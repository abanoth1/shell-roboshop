#!/bin/bash
# WORKING WITH COLORS IN SHELL SCRIPTING AND ADDING COLORS TO OUTPUT  AND ALSO USING FUNCTIONS AND LOOPS
# THIS SCRIPT IS TO INSTALL RABBITMQ SERVICE

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

VALIDATE() {  # function receives the inputs through aruments
    if [ $1 -ne 0 ]; then
        echo -e "$2 .... $R failure $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2 .... $G success $N" | tee -a $LOGS_FILE

        # HERE $1 is the exit status of the last executed command
        # and $2 is the name of the package
        # addingn colors to the output
        # adding loops to install multiple packages
    fi
}

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>> $LOGS_FILE
VALIDATE $? "Copying RabbitMQ Repo" # copying rabbitmq repo

dnf install rabbitmq-server -y &>> $LOGS_FILE
VALIDATE $? " Installing RabbitMQ Server" # installing rabbitmq server

systemctl enable rabbitmq-server &>> $LOGS_FILE
VALIDATE $? " Enabling RabbitMQ Service" # enabling rabbitmq service

systemctl start rabbitmq-server &>> $LOGS_FILE
VALIDATE $? " Starting RabbitMQ Service" # starting rabbitmq service

rabbitmqctl add_user roboshop roboshop123 &>> $LOGS_FILE
VALIDATE $? " Adding RabbitMQ Application User" # adding application user

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGS_FILE
VALIDATE $? " Setting RabbitMQ Application User Permissions" # setting application user permissions

