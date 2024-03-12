CREATE SCHEMA IF NOT EXISTS support_data;

CREATE TABLE support_data.dim_customer (
    customer_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_name VARCHAR(255),
    customer_email VARCHAR(255),
    customer_age INT,
    customer_gender VARCHAR(50)
);

CREATE TABLE support_data.dim_product (
    product_id INT IDENTITY(1,1) PRIMARY KEY,
    product_purchased VARCHAR(255)
);

CREATE TABLE support_data.dim_ticket_type (
    ticket_type_id INT IDENTITY(1,1) PRIMARY KEY,
    ticket_type VARCHAR(255),
    ticket_priority VARCHAR(50),
    ticket_channel VARCHAR(50),
    ticket_status VARCHAR(50),
    resolution VARCHAR(255)
);

CREATE TABLE support_data.dim_date (
    date_id INT IDENTITY(1,1) PRIMARY KEY,
    purchase_date DATE
);

CREATE TABLE support_data.dim_ticket_detail (
    ticket_detail_id INT IDENTITY(1,1) PRIMARY KEY,
    ticket_subject VARCHAR(255),
    ticket_description TEXT,
    sentiment VARCHAR(50),
    tags TEXT,
    auto_qa_results VARCHAR(50),
    integration_type_used VARCHAR(50),
    action_taken VARCHAR(255),
    action_result VARCHAR(50),
    knowledge_source VARCHAR(255),
    response_types VARCHAR(50)
);

CREATE TABLE support_data.fact_support_tickets (
    ticket_id INT PRIMARY KEY,
    customer_id INT REFERENCES support_data.dim_customer(customer_id),
    product_id INT REFERENCES support_data.dim_product(product_id),
    ticket_type_id INT REFERENCES support_data.dim_ticket_type(ticket_type_id),
    date_id INT REFERENCES support_data.dim_date(date_id),
    ticket_detail_id INT REFERENCES support_data.dim_ticket_detail(ticket_detail_id),
    FirstResponseTime VARCHAR(50), 
    TimeToResolution VARCHAR(50), 
    CustomerSatisfactionRating DECIMAL,
    ConversationExperienceScore SMALLINT,
    tokens_used DECIMAL
);
