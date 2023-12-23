#!bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST=mongodb.nkvj.cloud
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started excuted at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
if [ $1 -ne 0 ]
then 
echo -e "$2..installation $R FAILED $N"
else
echo -e "$2..installation $G SUCESS $N"
fi
}

if [ $ID -ne 0 ]
then
echo -e "$R Error:please run with root user $N"
exit 1
else
echo -e "you are $G root user $N"
fi

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disabling current Nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enable Nodejs:18"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing Nodejs:18" 

id roboshop 
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILE

VALIDATE $? "Creating app directory"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip

VALIDATE $? "Downloading user app"

cd /app &>> $LOGFILE

unzip -o /tmp/user.zip &>> $LOGFILE

VALIDATE $? "unzipping user"

npm install &>> $LOGFILE

VALIDATE $? "install dependencies"

cp /home/centos/roboshop-shell/user.serivce /etc/systemd/system/user.service

VALIDATE $? "copying user service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "user daemon reload"

systemctl enable user &>> $LOGFILE

VALIDATE $? "Enable user"

systemctl start user &>> $LOGFILE

VALIDATE $? "starting user"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "copying mongo.repo"

dnf install mongodb-org-shell -y

VALIDATE $? "installing mongodb client"

mongo --host $MONGODB_HOST </app/schema/user.js

VALIDATE $? "Loading user data into mongodb"