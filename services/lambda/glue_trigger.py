import boto3

def handler(event, context):
    # Get the bucket name and object key from the S3 event
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    object_key = event['Records'][0]['s3']['object']['key']
    
    # Start a Glue job
    glue = boto3.client('glue')
    job_name = 'automation-performance-pipeline'
    
    try:
        response = glue.start_job_run(JobName=job_name, 
                                      Arguments={
                                          '--s3_input_bucket': bucket_name,
                                          '--s3_input_key': object_key
                                      })
        job_run_id = response['JobRunId']
        print(f"Glue job '{job_name}' started with run ID: {job_run_id}")
        return {
            'statusCode': 200,
            'body': f"Glue job '{job_name}' started with run ID: {job_run_id}"
        }
    except Exception as e:
        print(f"Error starting Glue job '{job_name}': {e}")
        return {
            'statusCode': 500,
            'body': f"Error starting Glue job '{job_name}': {e}"
        }
