SELECT
    f.ticket_id,
    c.customer_name,
    c.customer_email,
    c.customer_age,
    c.customer_gender,
    p.product_purchased,
    s.ticket_subject,
    se.sentiment,
    t.tag,
    aq.auto_qa_results,
    i.integration_type_used,
    act.action_taken,
    ar.action_result,
    ks.knowledge_source,
    rt.response_types,
    tt.ticket_type,
    tp.ticket_priority,
    tc.ticket_channel,
    ts.ticket_status,
    r.resolution,
    f.purchase_date,
    f.first_response_time,
    f.time_to_resolution,
    f.customer_satisfaction_rating,
    f.conversation_experience_score,
    f.tokens_used
FROM
    support_data.fact_support_tickets f
INNER JOIN support_data.dim_customer c ON f.customer_id = c.id
INNER JOIN support_data.dim_product p ON f.product_id = p.id
INNER JOIN support_data.dim_subject s ON f.subject_id = s.id
INNER JOIN support_data.dim_sentiment se ON f.sentiment_id = se.id
INNER JOIN support_data.dim_tag t ON f.tag_id = t.id
INNER JOIN support_data.dim_auto_qa_results aq ON f.auto_qa_results_id = aq.id
INNER JOIN support_data.dim_integration_type_used i ON f.integration_type_used_id = i.id
INNER JOIN support_data.dim_action_taken act ON f.action_taken_id = act.id
INNER JOIN support_data.dim_action_result ar ON f.action_result_id = ar.id 
INNER JOIN support_data.dim_knowledge_source ks ON f.knowledge_source_id = ks.id
INNER JOIN support_data.dim_response_types rt ON f.response_types_id = rt.id
INNER JOIN support_data.dim_ticket_type tt ON f.ticket_type_id = tt.id
INNER JOIN support_data.dim_ticket_priority tp ON f.ticket_priority_id = tp.id
INNER JOIN support_data.dim_ticket_channel tc ON f.ticket_channel_id = tc.id
INNER JOIN support_data.dim_ticket_status ts ON f.ticket_status_id = ts.id
INNER JOIN support_data.dim_resolution r ON f.resolution_id = r.id;