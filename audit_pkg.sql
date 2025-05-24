CREATE SCHEMA IF NOT EXISTS audit_pkg;

CREATE OR REPLACE FUNCTION audit_pkg.log_action(
    p_user_id VARCHAR,
    p_operation VARCHAR,
    p_table_name VARCHAR,
    p_status VARCHAR,
    p_details TEXT
) RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO audit_log(user_id, operation, table_name, status, details)
    VALUES (p_user_id, p_operation, p_table_name, p_status, p_details);
END;
$$;
