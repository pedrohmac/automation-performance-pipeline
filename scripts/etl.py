import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

## @params: [JOB_NAME]
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Define source and target locations
source_location = "s3://automation-performance-dev-0-siena/raw-data/"
target_location = "s3://automation-performance-dev-0-siena/processed-data/"

# Catalog: database and table name
db_name = "your_database_name"
tbl_name = "your_table_name"

# Read data from S3 using a Glue DynamicFrame
datasource = glueContext.create_dynamic_frame.from_catalog(database=db_name, table_name=tbl_name)

# Apply transformations: For example, drop null fields
transformed_datasource = DropNullFields.apply(frame = datasource)

# Write the data back to S3 (in this example, as parquet for efficiency)
glueContext.write_dynamic_frame.from_options(
    frame = transformed_datasource,
    connection_type = "s3",
    connection_options = {"path": target_location},
    format = "parquet"
)

job.commit()
