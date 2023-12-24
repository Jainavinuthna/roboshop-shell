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

dnf install python36 gcc python3-devel -y

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

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip

cd /app 

unzip -o /tmp/payment.zip

cd /app 

pip3.6 install -r requirements.txt

cp /home/centos/roboshop-shell/payment.service/etc/systemd/system/payment.service

systemctl daemon-reload

systemctl enable payment 

systemctl start payment
