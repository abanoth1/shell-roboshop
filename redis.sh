#!/bin/bash
# WORKING WITH COLORS IN SHELL SCRIPTING AND ADDING COLORS TO OUTPUT  AND ALSO USING FUNCTIONS AND LOOPS
# THIS SCRIPT IS TO INSTALL REDIS SERVICE

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
START_TIME=$(date +%s)  # to capture script start time
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
dnf module disable redis -y &>> $LOGS_FILE # disabling the default redis module
VALIDATE $? "Disabling Redis Module"

dnf module enable redis:7 -y &>> $LOGS_FILE # enabling redis version 7
VALIDATE $? "Enabling Redis:7"

dnf install redis -y &>> $LOGS_FILE # installing redis
VALIDATE $? " Installing Redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf  # allowing remote connections
VALIDATE $? "Allowing remote connections in Redis"
 
systemctl enable redis &>> $LOGS_FILE # enabling redis service
VALIDATE $? "Enabling Redis Service"

systemctl start redis &>> $LOGS_FILE # starting redis service
VALIDATE $? "Starting Redis Service"

END_TIME=$(date +%s)  # to capture script end time
TOTAL_TIME=$(($END_TIME - $START_TIME))
echo -e "Total time taken to execute the script: $Y $TOTAL_TIME seconds $N" 
#adding colors and outputting total time taken to execute the script