#!/bin/bash

# Update system
yum update -y

# Setup directories
mkdir /home/ec2-user/backups /home/ec2-user/scripts /home/ec2-user/bootstrap

# Download scripts from S3
aws s3 cp --recursive s3://mc-ryanallen-ninja/scripts/ /home/ec2-user/scripts/
### Allow execution of all scripts
chmod 700 /home/ec2-user/scripts/*

# Update DNS records
### Get instance public IPv4 address 
wget 169.254.169.254/latest/meta-data/public-ipv4 -O /home/ec2-user/bootstrap/public-ipv4

### Download update payload template from S3
aws s3 cp --recursive s3://mc-ryanallen-ninja/bootstrap/ /home/ec2-user/bootstrap/

### Update Route53 request payload
sed -i s/HOSTNAME/$(cat /home/ec2-user/bootstrap/public-ipv4)/ /home/ec2-user/bootstrap/mc-server-route53-update.json

### Send the Route53 update request
aws route53 change-resource-record-sets --hosted-zone-id "Z1CGTP4HXR2GMJ" --change-batch file:///home/ec2-user/bootstrap/mc-server-route53-update.json > /home/ec2-user/bootstrap/mc-server-route53-change-info.json

# Download world from S3
aws s3 cp s3://mc-ryanallen-ninja/backups/latest.tar.gz /home/ec2-user/

# Unpack the world
tar -C /home/ec2-user -xzf /home/ec2-user/latest.tar.gz

# Delete the world file to save some disk space
rm -f /home/ec2-user/latest.tar.gz

# Change perms to ec2-user
chown -R ec2-user:ec2-user /home/ec2-user/

# Start up server
su -c "cd /home/ec2-user/minecraft/;screen -dmS minecraft java -Xmx8G -Xms4G -jar /home/ec2-user/minecraft/minecraft_server.1.13.2.jar nogui" ec2-user
