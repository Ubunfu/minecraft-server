#!/bin/bash

# Update system
sudo yum update -y

# Install dependencies
sudo yum install java -y

# Create fs structure
mkdir ~/minecraft

# Download mc server
wget https://launcher.mojang.com/v1/objects/3737db93722a9e39eeada7c27e7aca28b144ffa7/server.jar -O ~/minecraft/minecraft_server.1.13.2.jar

# Accept EULA
echo "eula=true" > ~/minecraft/eula.txt

# Set up scheduled backups
(crontab -l 2>/dev/null; echo "00 * * * * ~/scripts/backup.sh") | crontab -