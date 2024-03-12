import pandas as pd
import numpy as np
import random

# Load data
df = pd.read_csv('./data/customer_support_tickets.csv')

# Function to better randomize results
def random_values(df_length, values):
    result = []
    for i in range(0, df_length):
        random.shuffle(values)
        result.append(values[np.random.randint(1,len(values))])
        random.shuffle(values)
    return result


# Calculate random token value to be the product of ticket description word count and the average tokens to generate a word
df['Tokens Used'] = (df['Ticket Description'].str.count(' ') + 1) * 0.75

# Generate conversation experience score
df['Conversation Experience Score'] = random_values(len(df), [i for i in range(1,100)])

# Assign random sentiment
df['Sentiment'] = random_values(len(df), ['neutral', 'negative', 'positive'])

# E-commerce terms for tags
df['Tags'] = random_values(len(df), ["complaint", "refund", "warehouse", "brand", "bundling", "BOPIS", "BORIS", "cart", "payment", "loyalty", "EGC", "PGC", "POS", "upsell"])

# AutoQA results
df['AutoQA Results'] = random_values(len(df), ['Poor', 'Average', 'Good', 'Great'])

# Integration types used
df['Integration Type Used'] = random_values(len(df), ['Shopify', 'Recharge', 'Klavyio', 'Clutch', 'Adyen', 'Paypal', 'CRM', 'Salesforce'])

# Actions taken
df['Action Taken'] = random_values(len(df), ['Cancel Order', 'Update Address', 'Refund', 'Cancel Item', 'Return', 'None'])

# Action results
df['Action Result'] = random_values(len(df), ['successful', 'In progress', 'Failed'])

# Knowledge source
df['Knowledge Source'] = random_values(len(df), ['website content', 'product catalogues', 'google sheets', 'google docs', 'confluence'])

# Ticket channels
df['Ticket Channel'] = random_values(len(df), ['phonecall', 'whatsapp', 'facebook dm', 'live chat', 'email'])

# Response types
df["Response Types"] = random_values(len(df), ['internal note', 'live response'])

# User feedback
df['User Feedback'] = random_values(len(df), ['positive', 'negative'])

df.to_csv('./data/complete_customer_support_tickets.csv', index=False)
