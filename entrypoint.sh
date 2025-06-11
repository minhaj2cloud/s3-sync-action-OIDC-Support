#!/bin/sh
set -e

if [ -z "$aws_s3_bucket" ]; then
  echo "aws_s3_bucket input is not set. Quitting."
  exit 1
fi

# Default to us-east-1 if AWS_REGION not set.
if [ -z "$AWS_REGION" ]; then
  AWS_REGION="us-east-1"
fi

# Override default AWS endpoint if user sets AWS_S3_ENDPOINT.
if [ -n "$AWS_S3_ENDPOINT" ]; then
  ENDPOINT_APPEND="--endpoint-url $AWS_S3_ENDPOINT"
fi

SOURCE_DIR="${source_dir:-.}"
DEST_DIR="${dest_dir}"

echo "Syncing $SOURCE_DIR to s3://$aws_s3_bucket/$DEST_DIR"

# All credentials are expected to be set by the OIDC workflow step.
sh -c "aws s3 sync $SOURCE_DIR s3://$aws_s3_bucket/$DEST_DIR \
              --region $AWS_REGION \
              --no-progress \
              $ENDPOINT_APPEND $args"
