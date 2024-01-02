#!/bin/bash
INSTANCES_NAME=("mongodb" "mysql" "redis" "catalogue" "user" "cart" "shipping" "payments" "rabbitmq" "dispatch" "web")
INSTANCE_TYPE=""
DOMAIN_PATH="nkvj.cloud"
HOSTED_ZONE_ID="Z02466321SAZ9GUL48B63"

for i in "${INSTANCES_NAME[@]}"
do
    if [[ $i == "mongodb" || $i == "mysql" || $i == "shipping" ]]; then
    INSTANCE_TYPE="t2.small"
    else
        INSTANCE_TYPE="t2.micro"
    fi

    PRIVATE_IPADDRESS=$(aws ec2 run-instances \
                    --image-id ami-03265a0778a880afb \
                    --count 1 \
                    --instance-type "$INSTANCE_TYPE" \
                    --security-group-ids sg-0b8353fdc352a1089 \
                    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" \
                    --query 'Instances[0].PrivateIpAddress' \
                    --output text)
    echo "$i : $PRIVATE_IPADDRESS" 
    aws route53 change-resource-record-sets \
    --hosted-zone-id "$HOSTED_ZONE_ID" \
    --change-batch "{
        \"Changes\": [{
            \"Action\": \"UPSERT\",
            \"ResourceRecordSet\": {
                \"Name\": \"$i.$DOMAIN_PATH\",
                \"Type\": \"A\",
                \"TTL\": 1,
                \"ResourceRecords\": [{\"Value\": \"$PRIVATE_IPADDRESS\"}]
            }
        }]
    }"
    echo "record created successfully for $i : $i.$DOMAIN_PATH"
done