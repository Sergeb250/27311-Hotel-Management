--  Parameterized Procedure to fetching guest reservation using cursor

CREATE OR REPLACE PROCEDURE fetch_guest_reservations(p_guest_id INT)
LANGUAGE plpgsql
AS $$
DECLARE
  rec RECORD;
  cur CURSOR FOR
    SELECT r.reservation_id, r.hotel_id, r.booking_date, r.status, r.total_amount
    FROM Reservations r
    WHERE r.guest_id = p_guest_id;
BEGIN
  OPEN cur;

  LOOP
    FETCH cur INTO rec;
    EXIT WHEN NOT FOUND;

    RAISE NOTICE 'Reservation ID: %, Hotel ID: %, Booking Date: %, Status: %, Total Amount: %',
                 rec.reservation_id, rec.hotel_id, rec.booking_date, rec.status, rec.total_amount;
  END LOOP;

  CLOSE cur;
EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING 'Error fetching reservations for guest ID %: %', p_guest_id, SQLERRM;
END;
$$;

CALL fetch_guest_reservations(1);



--Function to Calculate Total Amount Spent by a Guest
CREATE OR REPLACE FUNCTION get_total_spent_by_guest(p_guest_id INT)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
  v_total NUMERIC := 0;
BEGIN
  SELECT COALESCE(SUM(total_amount), 0) INTO v_total
  FROM Reservations
  WHERE guest_id = p_guest_id;

  RETURN v_total;

EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING 'Error calculating total spent for guest ID %: %', p_guest_id, SQLERRM;
    RETURN NULL;
END;
$$;


SELECT get_total_spent_by_guest(2);


-- Package Equivalent in PostgreSQL: Use a Schema and Group Functions/Procedures
CREATE SCHEMA hotel_analytics;

-- Procedure inside schema
CREATE OR REPLACE PROCEDURE hotel_analytics.fetch_reservations_by_guest(p_guest_id INT)
LANGUAGE plpgsql AS $$
DECLARE
  rec RECORD;
  cur CURSOR FOR
    SELECT reservation_id, hotel_id, booking_date, status, total_amount
    FROM Reservations
    WHERE guest_id = p_guest_id;
BEGIN
  OPEN cur;

  LOOP
    FETCH cur INTO rec;
    EXIT WHEN NOT FOUND;

    RAISE NOTICE 'Reservation ID: %, Hotel ID: %, Booking Date: %, Status: %, Total Amount: %',
                 rec.reservation_id, rec.hotel_id, rec.booking_date, rec.status, rec.total_amount;
  END LOOP;

  CLOSE cur;
EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING 'Error fetching reservations for guest ID %: %', p_guest_id, SQLERRM;
END;
$$;

-- Function inside schema
CREATE OR REPLACE FUNCTION hotel_analytics.get_total_spent(p_guest_id INT)
RETURNS NUMERIC
LANGUAGE plpgsql AS $$
DECLARE
  v_total NUMERIC := 0;
BEGIN
  SELECT COALESCE(SUM(total_amount), 0) INTO v_total
  FROM Reservations
  WHERE guest_id = p_guest_id;

  RETURN v_total;

EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING 'Error calculating total spent for guest ID %: %', p_guest_id, SQLERRM;
    RETURN NULL;
END;
$$;




CALL hotel_analytics.fetch_reservations_by_guest(3);

SELECT hotel_analytics.get_total_spent(3);





