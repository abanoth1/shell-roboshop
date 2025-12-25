#!/bin/bash
# WORKING WITH COLORS IN SHELL SCRIPTING AND ADDING COLORS TO OUTPUT  AND ALSO USING FUNCTIONS AND LOOPS

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

USERID=$(id -u)
if [ "$USERID" -ne 0 ]; then
    echo "Error: Please run this script as root user or using sudo."
    exit 1 # failure is indicated by non-zero exit status
fi

VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "$2 .... $R failure $N"
        exit 1
    else
        echo -e "$2 .... $G success $N"

        # HERE $1 is the exit status of the last executed command
        # and $2 is the name of the package
        # addingn colors to the output
        # adding loops to install multiple packages
    fi
}

# $@ is used to get all the arguments passed to the script
for PACKAGE in "$@"
do
 # Check if package is installed
 dnf list installed $PACKAGE &>> $LOGS_FILE

 # if the exit status is not zero then install the package, else skip the installation
 if [ $? -ne 0 ]; then
     dnf install $PACKAGE -y &>> $LOGS_FILE
     VALIDATE $? "$PACKAGE"
else
    echo -e "$PACKAGE is already installed .... $Y skipped $N"
fi
done

cp mongodb.repo /etc/yum.repos.d/mongodb.repo
VALIDATE $? "Mongodb Repo"

dnf install mongodb-org -y &>> $LOGS_FILE
VALIDATE $? "Mongodb"

systemctl enable mongod &>> $LOGS_FILE
VALIDATE $? "Mongodb Enable"

systemctl start mongod &>> $LOGS_FILE
VALIDATE $? "Mongodb Start"