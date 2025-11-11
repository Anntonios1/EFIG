-- Ver estructura completa de n8n_chat_histories
SELECT column_name, data_type, character_maximum_length, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'n8n_chat_histories'
ORDER BY ordinal_position;

-- Ver algunos datos de n8n_chat_histories
SELECT * FROM n8n_chat_histories LIMIT 5;

-- Ver algunos datos de chat_history
SELECT * FROM chat_history ORDER BY id DESC LIMIT 10;
