-- Create user_credits table
CREATE TABLE IF NOT EXISTS user_credits (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    account_id UUID NOT NULL REFERENCES basejump.accounts(id) ON DELETE CASCADE,
    credits INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Trigger to update updated_at
CREATE TRIGGER update_user_credits_updated_at
    BEFORE UPDATE ON user_credits
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS
ALTER TABLE user_credits ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY user_credits_select_policy ON user_credits
    FOR SELECT
    USING (
        auth.uid() = user_id
        OR basejump.has_role_on_account(account_id)
    );

CREATE POLICY user_credits_insert_policy ON user_credits
    FOR INSERT
    WITH CHECK (
        auth.uid() = user_id
        OR basejump.has_role_on_account(account_id)
    );

CREATE POLICY user_credits_update_policy ON user_credits
    FOR UPDATE
    USING (
        auth.uid() = user_id
        OR basejump.has_role_on_account(account_id)
    );

-- Indexes
CREATE INDEX idx_user_credits_account_id ON user_credits(account_id);
CREATE INDEX idx_user_credits_credits ON user_credits(credits);

-- Grant permissions
GRANT ALL PRIVILEGES ON TABLE user_credits TO authenticated, service_role;
GRANT SELECT ON TABLE user_credits TO anon;
