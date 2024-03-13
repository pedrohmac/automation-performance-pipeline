import sys
import csv
import boto3
import psycopg2
import numpy as np
from awsglue.utils import getResolvedOptions
from psycopg2.extras import execute_batch

args = getResolvedOptions(sys.argv,
                          ['JOB_NAME',
                           'database_user',
                           'database_password',
                           'database_host',
                           'bucket_name',
                           'file_name'])

# Initialize global variables for the connection and cursor
conn = None
cursor = None

CUSTOMER_DATA_COLUMNS = ('Customer Name', 'Customer Email', 'Customer Age', 'Customer Gender')
FACT_COLUMNS = ('Ticket ID',  'First Response Time', 'Time to Resolution', 'Customer Satisfaction Rating', 
                'Tokens Used', 'Conversation Experience Score', 'Date of Purchase')
DIMENSION_COLUMNS = ('Product Purchased', 'Ticket Type', 'Ticket Subject', 'Ticket Status','Resolution', 
                     'Ticket Priority', 'Ticket Channel', 'AutoQA Results', 'Integration Type Used', 
                     'Action Taken', 'Action Result', 'Knowledge Source', 'Response Types', 'User Feedback')
REDSHIFT_SCHEMA = ("ticket_id","customer_id","product_id","ticket_type_id","subject_id","sentiment_id","tag_id","auto_qa_results_id","integration_type_useds_id","action_taken_id","knowledge_source_id","response_types_id","ticket_priority_id","ticket_channel_id","ticket_status_id","resolution_id","purchase_date","first_response_time","time_to_resolution","customer_satisfaction_rating","conversation_experience_score","tokens_used")


def handler():

    # Retrieve csv data from S3 in a dictionary - example: {'column_name': ['value1', 'value2'...]}
    csv_data = get_csv_data_from_s3(args['bucket_name'], args['file_name'])

    # Mapping to rename columns to match database schema
    mapping = map_tables()
    
    # Variable to store data after database lookup
    normalized_data = {}

    cursor = get_cursor()

    # Rename columns to match database, and search/insert values on dimension tables
    for key, value in csv_data.items():
        if any([key in FACT_COLUMNS, key in CUSTOMER_DATA_COLUMNS]):
            new_column_name = mapping[key]
            normalized_data[new_column_name] = value
        elif key in DIMENSION_COLUMNS:
            new_column_name = mapping[key]
            normalized_data[new_column_name] = lookup(cursor, new_column_name, value)

    # Search/insert customers based on email
    normalized_data['customer'] = lookup_customers(
        cursor,
        normalized_data['customer_name'],
        normalized_data['customer_email'],
        normalized_data['customer_gender'],
        normalized_data['customer_age']
    )

    # Placing normalized data in the correct order of the fact table for database insertion
    matrix = [normalized_data[column] for column in REDSHIFT_SCHEMA]

    # Transpose data so that each index of the tuple represents one row to be inserted on the database
    transposed_data = transpose(matrix)

    query = f"INSERT INTO support_data.fact_support_tickets ({[column for column in REDSHIFT_SCHEMA]}) VALUES (%s)"
    values =  [row for row in transposed_data]
    result = execute_batch(cursor, query, values)

    print(result)

    # Once all queries are done
    close_connection()


def lookup(cur, column_name, words_list):
    unique_words = set(words_list)

    # Query existing IDs
    placeholders = ','.join(['%s'] * len(unique_words))
    query = f"SELECT {column_name}, id FROM support_data.dim_{column_name} WHERE {column_name} IN ({placeholders})"
    cur.execute(query, list(unique_words))
    existing_ids = cur.fetchall()
    existing_words = {word for word, _ in existing_ids}
    
    # Cache the results for existing words
    id_cache = {word: id for word, id in existing_ids}
    
    # Determine missing words and insert them
    missing_words = unique_words - existing_words
    if missing_words:
        insert_query = "INSERT INTO support_data.dim_{column_name} ({column_name}) VALUES (%s) RETURNING {column_name}, id"
        # Using execute_batch for efficiency
        execute_batch(cur, insert_query, [(word,) for word in missing_words])
        new_ids = cur.fetchall()
        # Update the cache with new IDs
        id_cache.update({word: id for word, id in new_ids})
    
    # Replace strings in the original list
    replaced_list = [id_cache[word] for word in words_list]
    
    return replaced_list

def lookup_customers(cur, customer_name, customer_email, customer_gender, customer_age):
    unique_emails = set(customer_email)
    
    # Query existing IDs
    placeholders = ','.join(['%s'] * len(unique_emails))
    query = f"SELECT customer_email, id FROM support_data.dim_customer WHERE customer_email IN ({placeholders})"
    cur.execute(query, list(unique_emails))
    existing_ids = cur.fetchall()
    existing_emails = {email for email, _ in existing_ids}

    # Cache the results for existing emails
    id_cache = {email: id for email, id in existing_ids}

    missing_emails = unique_emails - existing_emails
    if missing_emails:
        insert_query = "INSERT INTO support_data.dim_customer (customer_name, customer_email, customer_age, customer_gender) VALUES (%s) RETURNING customer_email, id"
         # Using execute_batch for efficiency
        execute_batch(cur, insert_query, [(
            customer_name[customer_email.index(email)], 
            email, 
            customer_age[customer_email.index(email)], 
            customer_gender[customer_email.index(email)],
                            ) for email in missing_emails])
        new_ids = cur.fetchall()
        # Update the cache with new IDs
        id_cache.update({email: id for email, id in new_ids})

    # Replace strings in the original list
    replaced_list = [id_cache[email] for email in customer_email]

    return replaced_list

def transpose(lists):
    # Convert the list of lists into a NumPy array and then transpose it
    array = np.array(lists)
    transposed_array = array.T
    # Convert the transposed array back into a list of tuples
    return map(tuple, transposed_array)

def get_csv_data_from_s3(bucket_name, file_key):
    s3_client = boto3.client('s3')

    # Retrieve the CSV file from S3
    response = s3_client.get_object(Bucket=bucket_name, Key=file_key)
    
    # Ensure the text is decoded correctly based on your file's encoding
    lines = response['Body'].read().decode('utf-8').splitlines()
    
    # Create a CSV reader object
    reader = csv.reader(lines)
    
    # Extract headers (first row)
    headers = next(reader)
    
    # Initialize a dictionary to hold column data
    column_data = {header: [] for header in headers}
    
    # Iterate over the remaining rows and fill the column_data dictionary
    for row in reader:
        for header, value in zip(headers, row):
            column_data[header].append(value)
    
    return column_data

def map_tables():
    return {
        'Ticket ID': 'ticket_id',
        'Customer Name': 'customer_name',
        'Customer Email': 'customer_email',
        'Customer Age': 'customer_age',
        'Customer Gender': 'customer_gender',
        'Product Purchased': 'product',
        'Date of Purchase': 'purchase_date',
        'Ticket Type': 'ticket_type',
        'Ticket Subject': 'ticket_subject',
        'Ticket Status': 'ticket_status',
        'Resolution': 'resolution',
        'Ticket Priority': 'ticket_priority',
        'Ticket Channel': 'ticket_channel',
        'AutoQA Results': 'auto_qa_results',
        'Integration Type Used': 'integration_type_used',
        'Action Taken': 'action_taken',
        'Action Result': 'action_result',
        'Knowledge Source': 'knowledge_source',
        'Response Types': 'response_types',
        'User Feedback': 'user_feedback',
        'First Response Time': 'first_response_time',
        'Time to Resolution': 'time_to_resolution',
        'Customer Satisfaction Rating': 'customer_satisfaction_rating',
        'Tokens Used': 'tokens_used',
        'Conversation Experience Score': 'conversation_experience_score',
        'Sentiment': 'sentiment',
        'Tags': 'tag'
    }

# Connection and Cursor functions
def get_connection():
    global conn
    if conn is None:
        try:
            conn = psycopg2.connect(
                dbname='automation_pipeline_db',
                user=args['database_user'],
                password=args['database_password'],
                host=args['database_host'],
                port='5439'  # Default Redshift port
            )
        except Exception as e:
            print(f"Error establishing connection to the database: {e}")
            sys.exit(1)
    return conn

def get_cursor():
    global cursor
    if cursor is None:
        cursor = get_connection().cursor()
    return cursor

def close_connection():
    global conn, cursor
    if cursor is not None:
        cursor.close()
        cursor = None
    if conn is not None:
        conn.close()
        conn = None

handler()
