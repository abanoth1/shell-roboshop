#!/bin/bash
# WORKING WITH COLORS IN SHELL SCRIPTING AND ADDING COLORS TO OUTPUT  AND ALSO USING FUNCTIONS AND LOOPS
# THIS SCRIPT IS TO INSTALL USER SERVICE

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

# nodejs installation steps
dnf module disable nodejs -y &>> $LOGS_FILE
VALIDATE $? "Disabling Nodejs Module"

dnf module enable nodejs:20 -y &>> $LOGS_FILE
VALIDATE $? "Enabling Nodejs:20"

dnf install nodejs -y &>> $LOGS_FILE
VALIDATE $? " Installing Nodejs"

# check if the roboshop user is present, if not create the user, unfornately the useradd command throws error if the user is already present
# i forgot to declare id and log file redirection

id roboshop &>> $LOGS_FILE 
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOGS_FILE
VALIDATE $? "creating system user"
else
    echo -e "roboshop user is already present .... $Y skipped $N"
fi

mkdir -p /app
VALIDATE $? "Creating Application Directory"

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>> $LOGS_FILE
VALIDATE $? "Downloading Cart App Content"

cd /app
VALIDATE $? "Changing Directory to /app"

rm -rf /app/* # remove old content if any
VALIDATE $? "Removing Old Content"

unzip /tmp/cart.zip &>> $LOGS_FILE
VALIDATE $? "Extracting Cart App Content"

npm install &>> $LOGS_FILE
VALIDATE $? "Installing Nodejs Dependencies"

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service
VALIDATE $? "Copying cart Service File" # copying cart service file


systemctl daemon-reload
systemctl enable cart &>> $LOGS_FILE
VALIDATE $? "Enabling Cart Service" # enabling cart service

# cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service
# VALIDATE $? "Copy cart service" # copying cart service file       
# dnf install mongodb-mongosh -y &>> $LOGS_FILE
# VALIDATE $? "Installing Mongodb Shell Client"

# INDEX=$(mongosh mongodb.daws86s.me --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
# if [ $INDEX -le 0 ]; then
#     mongosh --host $MONGODB_HOST </app/db/master-data.js &>> $LOGS_FILE
#     VALIDATE $? "Loading Catalogue Schema to Mongodb"
# else
#     echo -e "Catalogue Schema is already present in Mongodb .... $Y skipped $N"
# fi

systemctl restart cart
VALIDATE $? "Restarting cart Service"


## Cart service and route 53 record for cart is also created by using the aws cli in the shell-scripting 