import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
  
sc = SparkContext.getOrCreate()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)

#  Get default_arguments for this Glue Job
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

# Tracks state of various Glue features
job.init(args['JOB_NAME'], args)

# Create dynamic frame from S3 object
source_dyf = glueContext.create_dynamic_frame_from_options(
    connection_type="s3",
    format="csv",
    connection_options={
        "paths": [f"s3://automation-performance-dev-0-siena/data/complete_customer_support_tickets.csv"]
    },
    format_options={
        "withHeader": True,
        "separator": ","
    })

# Rename fields to match table schema
renamed_dyf = source_dyf.rename_field("Ticket ID", "ticket_id")\
.rename_field("Customer Name", "customer_name")\
.rename_field("Customer Email", "customer_email")\
.rename_field("Customer Age", "customer_age")\
.rename_field("Customer Gender", "customer_gender")\
.rename_field("Product Purchased", "product_purchased")\
.rename_field("Date of Purchase", "purchase_date")\
.rename_field("Ticket Type", "ticket_type")\
.rename_field("Ticket Subject", "ticket_subject")\
.rename_field("Ticket Status", "ticket_status")\
.rename_field("Ticket Description", "ticket_description")\
.rename_field("Resolution", "resolution")\
.rename_field("Ticket Priority", "ticket_priority")\
.rename_field("User Feedback", "user_feedback")\
.rename_field("Ticket Channel", "ticket_channel")\
.rename_field("First Response Time", "first_response_time")\
.rename_field("Time to Resolution", "time_to_resolution")\
.rename_field("Customer Satisfaction Rating", "customer_satisfaction_rating")\
.rename_field("Conversation Experience Score", "conversation_experience_score")\
.rename_field("Tokens Used", "tokens_used")\
.rename_field("Sentiment", "sentiment")\
.rename_field("Tags", "tags")\
.rename_field("AutoQA Results", "auto_qa_results")\
.rename_field("Integration Type Used", "integration_type_used")\
.rename_field("Action Taken", "action_taken")\
.rename_field("Action Result", "action_result")\
.rename_field("Knowledge Source", "knowledge_source")\
.rename_field("Response Types", "response_types")

# Cast types to match table schema
updated_dyf = renamed_dyf.resolveChoice(specs=[
    ("ticket_id", "cast:integer"),
    ("customer_age", "cast:integer"),
    ("purchase_date", "cast:date"),
    ("first_response_time", "cast:timestamp"),
    ("time_to_resolution", "cast:timestamp"),
    ("customer_satisfaction_rating", "cast:double"),
    ("conversation_experience_score", "cast:integer"),
    ("tokens_used", "cast:float")
    ]
)

# Drop unused field 
# (The data contained in this column would be useful only after proper processing)
reduced_dyf = updated_dyf.drop_fields(["ticket_description"])

# Write Dynamic Frame into Redshift
glueContext.write_dynamic_frame.from_jdbc_conf(
    frame = reduced_dyf,
    catalog_connection = "redshift_connection",
    connection_options = {"dbtable": "support_data.tickets", "database": 'automation_pipeline_db', "preactions": "CREATE TABLE IF NOT EXISTS support_data.tickets (ticket_id VARCHAR, customer_name VARCHAR, customer_email VARCHAR, customer_age VARCHAR, customer_gender VARCHAR, product_purchased VARCHAR, purchase_date DATE, ticket_type VARCHAR, ticket_subject VARCHAR, ticket_status VARCHAR, resolution VARCHAR, ticket_priority VARCHAR, ticket_channel VARCHAR, first_response_time DATE, time_to_resolution DATE, customer_satisfaction_rating REAL, tokens_used REAL, conversation_experience_score VARCHAR, sentiment VARCHAR, tags VARCHAR, auto_qa_results VARCHAR, integration_type_used VARCHAR, action_taken VARCHAR, action_result VARCHAR, knowledge_source VARCHAR, response_types VARCHAR, user_feedback VARCHAR);"},
    redshift_tmp_dir = f"s3://automation-performance-dev-0-siena/",
    transformation_ctx = "write_dynamic_frame"
)

# Finalize the job object
job.commit()