#!/bin/sh
set -e

# GitHub Actions inputs are passed as environment variables with INPUT_ prefix and uppercase
if [ -z "$INPUT_AWS_S3_BUCKET" ]; then
  echo "Error: aws_s3_bucket input is not set. Quitting."
  exit 1
fi

# Use the input values from GitHub Actions
AWS_S3_BUCKET="$INPUT_AWS_S3_BUCKET"

# Debug: Print bucket name (first few characters only for security)
echo "Bucket name length: ${#AWS_S3_BUCKET}"
echo "Bucket name (first 10 chars): ${AWS_S3_BUCKET:0:10}..."

# Clean the bucket name - remove any potential whitespace
AWS_S3_BUCKET=$(echo "$AWS_S3_BUCKET" | tr -d '[:space:]')

# Validate bucket name format
if ! echo "$AWS_S3_BUCKET" | grep -qE '^[a-zA-Z0-9.\-_]{1,255}$'; then
  echo "Error: Invalid bucket name format. Bucket name can only contain letters, numbers, dots, hyphens, and underscores."
  echo "Bucket name: '$AWS_S3_BUCKET'"
  exit 1
fi

SOURCE_DIR="${INPUT_SOURCE_DIR:-.}"   # Default to current directory if not set
DEST_DIR="${INPUT_DEST_DIR}"          # Can be empty
ARGS="${INPUT_ARGS}"                  # Additional aws s3 sync args

# Default AWS region if not set in environment
if [ -z "$AWS_REGION" ]; then
  AWS_REGION="us-east-1"
fi

# Override default AWS endpoint if user sets AWS_S3_ENDPOINT.
if [ -n "$AWS_S3_ENDPOINT" ]; then
  ENDPOINT_APPEND="--endpoint-url $AWS_S3_ENDPOINT"
fi

# Construct S3 destination path properly
if [ -n "$DEST_DIR" ]; then
  S3_DEST="s3://$AWS_S3_BUCKET/$DEST_DIR"
else
  S3_DEST="s3://$AWS_S3_BUCKET"
fi

echo "Syncing directory '$SOURCE_DIR' to $S3_DEST"
echo "Using AWS Region: $AWS_REGION"
echo "Arguments: $ARGS"

# Check if this is a metadata sync (check for metadata flag)
if [ "$INPUT_METADATA_SYNC" = "true" ]; then
  echo "Performing metadata sync..."
  
  # For metadata sync, we need to sync files without extensions and set content-type to text/html
  # Remove any existing content-type and exclude *.* args to set them properly
  CLEAN_ARGS=$(echo "$ARGS" | sed 's/--content-type[[:space:]]*[^[:space:]]*//' | sed "s/--exclude[[:space:]]*['\"][*][.][*]['\"]//")
  
  echo "Executing metadata sync command..."
  aws s3 sync "$SOURCE_DIR" "$S3_DEST" \
    --region "$AWS_REGION" \
    --no-progress \
    --content-type 'text/html' \
    --exclude '*.*' \
    $CLEAN_ARGS $ENDPOINT_APPEND && echo "Metadata sync completed"
  
else
  echo "Performing regular sync..."
  
  echo "Executing sync command..."
  aws s3 sync "$SOURCE_DIR" "$S3_DEST" --region "$AWS_REGION" --no-progress $ARGS $ENDPOINT_APPEND
fi

echo "Sync operation completed successfully!"
