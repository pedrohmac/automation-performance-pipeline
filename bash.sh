echo "Creating environment variables"

source env.sh

echo "Generating data"

python3 ./scripts/generate_data_source.py 

echo "Uploading source data to S3"

aws s3 cp ./data/complete_customer_support_tickets.csv s3://$BUCKET/data/

echo "Uploading scripts to S3"

aws s3 cp ./scripts/etl.py s3://$BUCKET/scripts/