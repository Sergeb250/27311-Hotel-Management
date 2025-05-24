select * from guests;

ALTER TABLE guests ADD COLUMN newsletter_subscribed BOOLEAN DEFAULT FALSE;

UPDATE Guests
SET phone = '+1-555-9999'
WHERE email = 'james.anderson@email.com';

UPDATE Guests
SET newsletter_subscribed = TRUE
WHERE nationality = 'American';

DELETE FROM Guests
WHERE date_of_birth < '1988-01-01';



