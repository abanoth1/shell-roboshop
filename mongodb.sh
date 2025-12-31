#!/bin/bash
# WORKING WITH COLORS IN SHELL SCRIPTING AND ADDING COLORS TO OUTPUT  AND ALSO USING FUNCTIONS AND LOOPS
# THIS SCRIPT IS TO INSTALL MONGODB DATABASE

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
LOGS_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
# log file path /var/log/shell-roboshop/16-logs.log

mkdir -p $LOGS_FOLDER
echo "script execution started at : $(date)" | tee -a $LOGS_FILE


if [ "$USERID" -ne 0 ]; then
    echo "Error: Please run this script as root user or using sudo."
    exit 1 # failure is indicated by non-zero exit status
fi

VALIDATE() {
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

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? " Adding Mongo Repo"

dnf install mongodb-org -y &>> $LOGS_FILE
VALIDATE $? "installing Mongodb"

systemctl enable mongod &>> $LOGS_FILE
VALIDATE $? "Mongodb Enable"

systemctl start mongod &>> $LOGS_FILE
VALIDATE $? "Mongodb Start"

# Here i'm using the sed command to replace the bindIp value from
# 127.0.0.1 to 0.0.0.0 in the mongod.conf file
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connections in Mongodb"

systemctl restart mongod &>> $LOGS_FILE
VALIDATE $? "Restarting Mongodb"
# Mongodb is installed and configured to allow remote connections