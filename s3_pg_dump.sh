#!/bin/sh
set -e

# Set current directory
DIR=`pwd`

# Import config file
source $DIR/config

# Vars
NOW=$(date +"%Y-%m-%d-at-%H-%M-%S")

PG_PASSWORD=`aws secretsmanager get-secret-value --secret-id ${SEC_ID}| jq --raw-output '.SecretString' | jq -r .pg_password`
#echo $PGPASSWORD

PG_USER=`aws secretsmanager get-secret-value --secret-id ${SEC_ID}| jq --raw-output '.SecretString' | jq -r .pg_user`
#echo $PG_USER

PG_HOST=`aws secretsmanager get-secret-value --secret-id ${SEC_ID}| jq --raw-output '.SecretString' | jq -r .pg_host`
#echo $PG_HOST

PG_PORT=`aws secretsmanager get-secret-value --secret-id ${SEC_ID}| jq --raw-output '.SecretString' | jq -r .pg_port`
#echo $PG_PORT

db=`aws secretsmanager get-secret-value --secret-id ${SEC_ID}| jq --raw-output '.SecretString' | jq -r .pg_database`
#echo $db

echo " * Backup in progress.,.";

FILENAME="$NOW"_"$db"


echo "   -> backing up $db..."

# Dump database
export PGPASSWORD=$PG_PASSWORD
pg_dump -Fc -h $PG_HOST -U $PG_USER -p $PG_PORT $db > /tmp/"$FILENAME".dump

# Copy to S3
aws s3 cp /tmp/"$FILENAME".dump s3://$S3_PATH/"$FILENAME".dump --storage-class STANDARD_IA

# Delete local file
rm /tmp/"$FILENAME".dump

echo "      ...database $db has been backed up"

