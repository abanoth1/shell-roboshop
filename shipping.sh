#!/bin/bash
# WORKING WITH COLORS IN SHELL SCRIPTING AND ADDING COLORS TO OUTPUT  AND ALSO USING FUNCTIONS AND LOOPS
# THIS SCRIPT IS TO INSTALL SHIPPING SERVICE

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
MYSQL_HOST="mysql.daws86s.me"
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

dnf install maven -y &>> $LOGS_FILE
VALIDATE $? " Installing Maven"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "User already exist ... $Y SKIPPING $N"
fi

mkdir -p /app
VALIDATE $? "Creating app directory"

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading shipping application"

cd /app 
VALIDATE $? "Changing to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "unzip shipping application"

mvn clean package &>>$LOG_FILE
mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service &>>$LOG_FILE
VALIDATE $? "Copying shipping service file"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Reloading systemd daemon"

systemctl enable shipping &>>$LOG_FILE
VALIDATE $? "Enabling shipping service"

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installing mysql client"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities'  &>>$LOG_FILE
if [ $? -ne 0 ]; then
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOG_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOG_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOG_FILE
else
    echo -e "shipping database is already present ... $Y SKIPPING $N"
fi    
# Here we are checking if the database is already present, if not only then we are creating the database
# This is to avoid the error while running the script multiple times

systemctl restart shipping &>>$LOG_FILE
VALIDATE $? "Starting shipping service"

# shipping service is dependent on mongodb so we need to install mongodb client