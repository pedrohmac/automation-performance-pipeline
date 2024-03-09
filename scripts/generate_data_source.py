import pandas as pd
import numpy as np

# Load data
df = pd.read_csv('./data/customer_support_tickets.csv')

# Generate conversation experience score
df['Conversation Experience Score'] = np.random.randint(1, 100, len(df))

# Calculate random token value to be the product of ticket description word count and the average tokens to generate a word
df['Tokens Used'] = (df['Ticket Description'].str.count(' ') + 1) * 0.75

# Assign random sentiment
sentiments = ['neutral', 'negative', 'positive']
df['Sentiment'] = np.random.choice(sentiments, len(df))

# E-commerce terms for tags
terms = ["complaint", "refund", "warehouse", "brand", "bundling", "BOPIS", "BORIS", "cart", "payment", "loyalty", "EGC", "PGC", "POS", "upsell"]

# Generate tags
df['Tags'] = df.apply(lambda _: ", ".join(np.random.choice(terms, np.random.randint(1, 5), replace=False)), axis=1)

# AutoQA results
autoqa_results = ['Poor', 'Average', 'Good', 'Great']
df['AutoQA Results'] = np.random.choice(autoqa_results, len(df))

# Integration types used
integration_types = ['Shopify', 'Recharge', 'Klavyio', 'Clutch', 'Adyen', 'Paypal', 'CRM', 'Salesforce']
df['Integration Type Used'] = np.random.choice(integration_types, len(df))

# Actions taken
actions_taken = ['Cancel Order', 'Update Address', 'Refund', 'Cancel Item', 'Return', 'None']
df['Action Taken'] = np.random.choice(actions_taken, len(df))

# Action results
action_results = ['successful', 'In progrress', 'Failed']
df['Action Result'] = np.random.choice(action_results, len(df))

# Knowledge source
knowledge_sources = ['website content', 'product catalogues', 'google sheets', 'google docs', 'confluence']
df['Knowledge Source'] = np.random.choice(knowledge_sources, len(df))

# Ticket channels
ticket_channels = ['phonecall', 'whatsapp', 'facebook dm', 'live chat', 'email']
df['Ticket Channel'] = np.random.choice(ticket_channels, len(df))

# Response types
response_types = ['internal note', 'live response']
df['Response Types'] = np.random.choice(response_types, len(df))

df.to_csv('./data/complete_customer_support_tickets.csv', index=False)
