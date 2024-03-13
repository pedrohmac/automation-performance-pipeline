import os
import boto3
import base64
from urllib.parse import parse_qs

# Initialize the S3 client
s3 = boto3.client('s3')

def handler(event, context):
    try:
        # Parse the POST data. The data comes in the 'body' key and is URL-encoded
        csv_content = parse_qs(event['body'])
        
        # Specify your S3 bucket name and the key (filename) under which to save the file
        bucket_name = os.environ['bucket_name']
        file_key = '/data/complete_customer_support_tickets.csv'
        
        # Upload the file to S3
        response = s3.put_object(Body=csv_content, Bucket=bucket_name, Key=file_key)
        
        return {
            'statusCode': 200,
            'body': 'File uploaded successfully'
        }
    except Exception as e:
        print(e)
        return {
            'statusCode': 500,
            'body': 'Error uploading the file'
        }
