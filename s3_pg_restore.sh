#!/bin/bash
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

DUMP=$1

# Download backup from s3
aws s3 cp s3://$S3_PATH/$DUMP /tmp/$DUMP

# Create database if not exists
export PGPASSWORD=$PG_PASSWORD
DB_EXISTS=$(psql -h $PG_HOST -p $PG_PORT -U $PG_USER -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$db'")
if [ "$DB_EXISTS" = "1" ]
then
    echo "Database $db already exists, skipping creation"
    # Restore database
    pg_restore -h $PG_HOST -U $PG_USER -p $PG_PORT -d $db -Fc -v --clean /tmp/$DUMP 1> ./logs/${db}_restore_${NOW}.log 2>&1
fi

# Remove backup file
rm /tmp/$DUMP

echo "$DUMP restored to database $db"
