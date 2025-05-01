#!/bin/bash

STUDENT_ID="018320835"
INPUT_BUCKET="cs218-final-input-bucket-${STUDENT_ID}"
OUTPUT_BUCKET="cs218-final-output-bucket-${STUDENT_ID}"
QUEUE_NAME="cs218-final-processing-queue"
TMP_DIR="./tmp"
SCHEMA="ID,Name,Value"
REGION="us-west-2"

# Create temp directory
mkdir -p $TMP_DIR

# Get Queue URL
QUEUE_URL=$(aws sqs get-queue-url --queue-name $QUEUE_NAME --region $REGION --query "QueueUrl" --output text)

# List all JSON.gz files in the S3 input bucket
aws s3 ls s3://$INPUT_BUCKET/AWSDynamoDB/ --recursive | grep ".json.gz" | awk '{print $4}' | while read FILE_KEY; do
  OUTPUT_KEY="converted/$(basename $FILE_KEY .json.gz).csv"

  # Send message to SQS
  aws sqs send-message --queue-url $QUEUE_URL --region $REGION \
    --message-body "{
      \"json_path\": \"$FILE_KEY\",
      \"input_bucket\": \"$INPUT_BUCKET\",
      \"output_bucket\": \"$OUTPUT_BUCKET\",
      \"output_key\": \"$OUTPUT_KEY\"
    }"
done

echo "🕐 Waiting 30 seconds for Lambda to finish processing..."
sleep 30

echo "📥 Downloading converted CSV files from S3..."
aws s3 ls s3://$OUTPUT_BUCKET/converted/ --recursive | grep ".csv" | awk '{print $4}' | while read CSV_KEY; do
  aws s3 cp s3://$OUTPUT_BUCKET/$CSV_KEY "$TMP_DIR/$(basename $CSV_KEY)"
done

echo "📎 Collating CSV files into final_output.csv..."
OUTPUT_FILE="$TMP_DIR/final_output.csv"
echo $SCHEMA > $OUTPUT_FILE

for f in $TMP_DIR/*.csv; do
  if [[ $f != *final_output.csv ]]; then
    tail -n +2 "$f" >> $OUTPUT_FILE
  fi
done

echo "✅ Collation complete. Final file: $OUTPUT_FILE"
