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

dnf install nginx -y

VALIDATE $? "Install nginx"

systemctl enable nginx

VALIDATE $? "enable nginx"

systemctl start nginx

VALIDATE $? "starting nginx"

rm -rf /usr/share/nginx/html/*

VALIDATE $? "removed default website"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip

VALIDATE $? "Downloaded web application"

cd /usr/share/nginx/html

VALIDATE $? "Moving ngnix html directory"

unzip -o /tmp/web.zip

VALIDATE $? "unzipping web"

cp /home/centos/roboshop-shell/roboshop.confg /etc/nginx/default.d/roboshop.conf

VALIDATE $? "copied roboshop reverse proxy config"

systemctl restart nginx 

VALIDATE $? "restarted nginx"