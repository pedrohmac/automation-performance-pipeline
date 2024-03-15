CREATE SCHEMA IF NOT EXISTS support_data;

CREATE TABLE support_data.dim_customer (
    id INT IDENTITY(1,1) PRIMARY KEY,
    customer_name VARCHAR(255),
    customer_email VARCHAR(255),
    customer_age INT,
    customer_gender VARCHAR(50)
);

CREATE TABLE support_data.dim_product (
    id INT IDENTITY(1,1) PRIMARY KEY,
    product_purchased VARCHAR(255)
);

CREATE TABLE support_data.dim_subject (
    id INT IDENTITY(1,1) PRIMARY KEY,
    ticket_subject VARCHAR(255),
);

CREATE TABLE support_data.dim_sentiment (
    id INT IDENTITY(1,1) PRIMARY KEY,
    sentiment VARCHAR(50)
);

CREATE TABLE support_data.dim_tag (
    id INT IDENTITY(1,1) PRIMARY KEY,
    tag VARCHAR(50)
);

CREATE TABLE support_data.dim_auto_qa_results (
    id INT IDENTITY(1,1) PRIMARY KEY,
    auto_qa_results VARCHAR(50)
);

CREATE TABLE support_data.dim_integration_type_used (
    id INT IDENTITY(1,1) PRIMARY KEY,
    integration_type_used VARCHAR(50)
);

CREATE TABLE support_data.dim_action_taken (
    id INT IDENTITY(1,1) PRIMARY KEY,
    action_taken VARCHAR(50)
);

CREATE TABLE support_data.dim_action_result (
    id INT IDENTITY(1,1) PRIMARY KEY,
    action_result VARCHAR(50)
);

CREATE TABLE support_data.dim_knowledge_source (
    id INT IDENTITY(1,1) PRIMARY KEY,
    knowledge_source VARCHAR(50)
);

CREATE TABLE support_data.dim_response_types (
    id INT IDENTITY(1,1) PRIMARY KEY,
    response_types VARCHAR(50)
);

CREATE TABLE support_data.dim_ticket_type (
    id INT IDENTITY(1,1) PRIMARY KEY,
    ticket_type VARCHAR(50)
);

CREATE TABLE support_data.dim_ticket_priority (
    id INT IDENTITY(1,1) PRIMARY KEY,
    ticket_priority VARCHAR(50)
);

CREATE TABLE support_data.dim_ticket_channel (
    id INT IDENTITY(1,1) PRIMARY KEY,
    ticket_channel VARCHAR(50)
);


CREATE TABLE support_data.dim_ticket_status (
    id INT IDENTITY(1,1) PRIMARY KEY,
    ticket_status VARCHAR(50)
);

CREATE TABLE support_data.dim_resolution (
    id INT IDENTITY(1,1) PRIMARY KEY,
    resolution VARCHAR(50)
);

CREATE TABLE support_data.fact_support_tickets (
    ticket_id INT PRIMARY KEY,
    customer_id INT REFERENCES support_data.dim_customer(customer_id),
    product_id INT REFERENCES support_data.dim_product(product_id),
    ticket_type_id INT REFERENCES support_data.dim_ticket_type(ticket_type_id),
    subject_id INT REFERENCES support_data.dim_subject(subject_id),
    sentiment_id INT REFERENCES support_data.dim_sentiment(sentiment_id),
    tag_id INT REFERENCES support_data.dim_tag(tag_id),
    auto_qa_results_id INT REFERENCES support_data.dim_ticket_subject(auto_qa_results_id),
    integration_type_used_id INT REFERENCES support_data.dim_integration_type_used(integration_type_used_id),
    action_taken_id INT REFERENCES support_data.dim_action_taken(action_taken_id),
    action_result_id INT REFERENCES support_data.dim_action_result(action_result_id),
    knowledge_source_id INT REFERENCES support_data.dim_knowledge_source(knowledge_source_id),
    response_types_id INT REFERENCES support_data.dim_response_types(response_types_id),
    ticket_priority_id INT REFERENCES support_data.dim_ticket_priority(ticket_priority_id),
    ticket_channel_id INT REFERENCES support_data.dim_ticket_channel(ticket_channel_id),
    ticket_status_id INT REFERENCES support_data.dim_ticket_status(ticket_status_id),
    resolution_id INT REFERENCES support_data.dim_resolution(resolution_id),
    purchase_date DATE,
    first_response_time TIMESTAMP, 
    time_to_resolution TIMESTAMP, 
    customer_satisfaction_rating DECIMAL,
    conversation_experience_score SMALLINT,
    tokens_used DECIMAL
);
