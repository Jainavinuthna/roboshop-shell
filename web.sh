#!bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)

LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started excuted at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
if [ $1 -ne 0 ]
then 
echo -e "$2..installation $R FAILED $N"
exit 1
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

dnf install nginx -y &>> $LOGFILE

VALIDATE $? "Install nginx"

systemctl enable nginx &>> $LOGFILE

VALIDATE $? "enable nginx"

systemctl start nginx &>> $LOGFILE

VALIDATE $? "starting nginx"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE

VALIDATE $? "removed default website"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE

VALIDATE $? "Downloaded web application"

cd /usr/share/nginx/html &>> $LOGFILE

VALIDATE $? "Moving ngnix html directory"

unzip -o /tmp/web.zip &>> $LOGFILE

VALIDATE $? "unzipping web"

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE

VALIDATE $? "copied roboshop reverse proxy config"

systemctl restart nginx &>> $LOGFILE

VALIDATE $? "restarted nginx"