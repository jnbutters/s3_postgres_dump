#!/bin/bash
set -e

# Set current directory
DIR=`pwd`

# Import config file
source $DIR/config

# Vars
NOW=$(date +"%Y-%m-%d-at-%H-%M-%S")

# List S3 Objects
aws s3api list-objects --bucket $S3_BUCKET --query 'Contents[].{Key: Key, Size: Size}'

