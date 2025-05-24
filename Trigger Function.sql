CREATE OR REPLACE FUNCTION audit_pkg.restrict_dml()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    v_today DATE := CURRENT_DATE;
    v_day_of_week INTEGER := EXTRACT(ISODOW FROM v_today);  -- Monday=1, Sunday=7
    v_is_holiday BOOLEAN;
    v_user VARCHAR := current_user;  -- Or session_user or application user
    v_operation VARCHAR := TG_OP;
BEGIN
    -- Check if today is a public holiday
    SELECT EXISTS(SELECT 1 FROM public_holidays WHERE holiday_date = v_today) INTO v_is_holiday;

    -- Block if weekday (Mon-Fri) or holiday
    IF v_day_of_week BETWEEN 1 AND 5 OR v_is_holiday THEN
        PERFORM audit_pkg.log_action(
            v_user,
            v_operation,
            TG_TABLE_NAME,
            'Denied',
            'Attempted on restricted day: ' || v_today
        );
        RAISE EXCEPTION 'Data manipulation is not allowed on weekdays or public holidays.';
    ELSE
        -- Allow operation and log it
        PERFORM audit_pkg.log_action(
            v_user,
            v_operation,
            TG_TABLE_NAME,
            'Allowed',
            'Operation permitted on: ' || v_today
        );
    END IF;

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$;


CREATE TRIGGER trg_restrict_dml_reservations
BEFORE INSERT OR UPDATE OR DELETE ON Reservations
FOR EACH ROW
EXECUTE FUNCTION audit_pkg.restrict_dml();