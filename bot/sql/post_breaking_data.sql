CREATE TABLE IF NOT EXISTS post_breaking_data (
    id SERIAL,
    ts TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    changelog_id INTEGER
)
