#!/bin/sh
set -e

# GitHub Actions inputs are passed as environment variables with INPUT_ prefix and uppercase
if [ -z "$INPUT_AWS_S3_BUCKET" ]; then
  echo "Error: aws_s3_bucket input is not set. Quitting."
  exit 1
fi

# Use the input values from GitHub Actions
AWS_S3_BUCKET="$INPUT_AWS_S3_BUCKET"
SOURCE_DIR="${INPUT_SOURCE_DIR:-.}"   # Default to current directory if not set
DEST_DIR="${INPUT_DEST_DIR}"          # Can be empty
ARGS="${INPUT_ARGS}"                  # Additional aws s3 sync args

# Default AWS region if not set in environment
if [ -z "$AWS_REGION" ]; then
  AWS_REGION="ap-south-1"
fi

# Optional: override AWS S3 endpoint if set
if [ -n "$AWS_S3_ENDPOINT" ]; then
  ENDPOINT_APPEND="--endpoint-url $AWS_S3_ENDPOINT"
fi

echo "Syncing directory '$SOURCE_DIR' to s3://$AWS_S3_BUCKET/$DEST_DIR"
echo "Using AWS Region: $AWS_REGION"

# Run the AWS S3 sync command
aws s3 sync "$SOURCE_DIR" "s3://$AWS_S3_BUCKET/$DEST_DIR" \
  --region "$AWS_REGION" \
  --no-progress \
  $ENDPOINT_APPEND $ARGS

