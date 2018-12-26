#!/bin/bash

function success() {
    if [ $? -eq 0 ]; then
        echo "OK."
    else
        echo "FAIL."
        exit 1
    fi
}

# Calculate a date timestamp for the backup name
TIMESTAMP=$(date +%F.%H-%m-%S)

# Where to log the backup activity
# Use the server log
LOG="/home/ec2-user/minecraft/logs/latest.log"

echo "####################" | tee -a ${LOG}
echo "### SERVER AUTO-BACKUP STARTED @ $(date +%F\ %T)..." | tee -a ${LOG}

# Wipe out any old local backups
# We don't have space to maintain local backups
echo -n "### CLEANING ANY LOCAL BACKUPS..." | tee -a ${LOG}
rm -rf /home/ec2-user/backups/*
success | tee -a ${LOG}

# tar up the whole server
# MUST BE RUN FROM /home/ec2-user/
# AND zip path given in the form ./minecraft/*, or the /home/ec2-user/ path will be added to the tar
echo "### COMPRESSING WORLD..." | tee -a ${LOG}
cd /home/ec2-user/
tar -czf /home/ec2-user/backups/${TIMESTAMP}.tar.gz --exclude=*.jar ./minecraft/*

# Don't success check after the compression.
# Tar will give non-zero status code when the world changes while compressing
# If the backup really fails, the next success check will stop if from causing any damage
# success | tee -a ${LOG}

# Send up to S3
# Historical backups
echo -n "### UPLOADING BACKUP TO ARCHIVE..." | tee -a ${LOG}
aws s3 cp /home/ec2-user/backups/${TIMESTAMP}.tar.gz s3://mc-ryanallen-ninja/backups/history/
success | tee -a ${LOG}

# Quick access to latest backup
echo -n "### UPLOADING BACKUP FOR QUICK-RESTORE..." | tee -a ${LOG}
aws s3 cp /home/ec2-user/backups/${TIMESTAMP}.tar.gz s3://mc-ryanallen-ninja/backups/latest.tar.gz
success | tee -a ${LOG}

echo "### BACKUP COMPLETE." | tee -a ${LOG}
echo "####################" | tee -a ${LOG}