#!/bin/sh
set -e
# GitHub Actions inputs are passed as environment variables with INPUT_ prefix and uppercase
if [ -z "$AWS_S3_BUCKET" ]; then
  echo "Error: aws_s3_bucket input is not set. Quitting."
  exit 1
fi
# Use the input values from GitHub Actions
AWS_S3_BUCKET="$AWS_S3_BUCKET"
SOURCE_DIR="${INPUT_SOURCE_DIR:-.}"   # Default to current directory if not set
DEST_DIR="${INPUT_DEST_DIR}"          # Can be empty
ARGS="${INPUT_ARGS}"                  # Additional aws s3 sync args
# Default AWS region if not set in environment
if [ -z "$AWS_REGION" ]; then
  AWS_REGION="ap-south-1"
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
# Create a temporary script to properly handle arguments
cat > /tmp/sync_script.sh << EOF
#!/bin/sh
aws s3 sync "$SOURCE_DIR" "$S3_DEST" --region "$AWS_REGION" --no-progress $ARGS
EOF
chmod +x /tmp/sync_script.sh
echo "Executing sync command..."
/tmp/sync_script.sh
