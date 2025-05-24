WITH guest_totals AS (
  SELECT 
    r.guest_id,
    g.first_name || ' ' || g.last_name AS guest_name,
    r.booking_source,
    SUM(r.total_amount) AS total_spent
  FROM 
    Reservations r
  JOIN 
    Guests g ON r.guest_id = g.guest_id
  GROUP BY 
    r.guest_id, g.first_name, g.last_name, r.booking_source
)

SELECT 
  guest_id,
  guest_name,
  booking_source,
  total_spent,
  RANK() OVER (PARTITION BY booking_source ORDER BY total_spent DESC) AS rank_in_source
FROM 
  guest_totals
ORDER BY 
  booking_source, rank_in_source;
