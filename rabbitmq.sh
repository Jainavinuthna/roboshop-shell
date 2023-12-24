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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash  &>> $LOGFILE

VALIDATE $? "Downloading erlang script"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash  &>> $LOGFILE

VALIDATE $? "Downloading rabbitmq script"

dnf install rabbitmq-server -y  &>> $LOGFILE

VALIDATE $? "Installing rabbitmq server"

systemctl enable rabbitmq-server  &>> $LOGFILE

VALIDATE $? "Enabling rabbitmq server"

systemctl start rabbitmq-server  &>> $LOGFILE

VALIDATE $? "starting rabbitmq server"

rabbitmqctl add_user roboshop roboshop123  &>> $LOGFILE

VALIDATE $? "Creating user"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"  &>> $LOGFILE

VALIDATE $? "setting permission"
