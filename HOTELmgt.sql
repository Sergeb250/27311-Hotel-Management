-- ========================================
-- HOTEL MANAGEMENT SYSTEM - PostgreSQL Implementation
-- ========================================


-- Drop existing tables if they exist (in correct order due to foreign keys)
DROP TABLE IF EXISTS Service_Bookings CASCADE;
DROP TABLE IF EXISTS Payments CASCADE;
DROP TABLE IF EXISTS Reservation_Details CASCADE;
DROP TABLE IF EXISTS Services CASCADE;
DROP TABLE IF EXISTS Reservations CASCADE;
DROP TABLE IF EXISTS Guests CASCADE;
DROP TABLE IF EXISTS Rooms CASCADE;
DROP TABLE IF EXISTS Room_Types CASCADE;
DROP TABLE IF EXISTS Staff CASCADE;
DROP TABLE IF EXISTS Hotels CASCADE;

-- Create sequence for auto-incrementing IDs
CREATE SEQUENCE hotel_id_seq START 1;
CREATE SEQUENCE staff_id_seq START 1;
CREATE SEQUENCE room_type_id_seq START 1;
CREATE SEQUENCE room_id_seq START 1;
CREATE SEQUENCE guest_id_seq START 1;
CREATE SEQUENCE reservation_id_seq START 1;
CREATE SEQUENCE reservation_detail_id_seq START 1;
CREATE SEQUENCE service_id_seq START 1;
CREATE SEQUENCE service_booking_id_seq START 1;
CREATE SEQUENCE payment_id_seq START 1;

-- ========================================
-- TABLE CREATION WITH CONSTRAINTS
-- ========================================

-- Hotels Table
CREATE TABLE Hotels (
    hotel_id INTEGER PRIMARY KEY DEFAULT nextval('hotel_id_seq'),
    hotel_name VARCHAR(100) NOT NULL,
    address VARCHAR(200) NOT NULL,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    star_rating INTEGER CHECK (star_rating BETWEEN 1 AND 5),
    registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
    
    CONSTRAINT chk_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Staff Table
CREATE TABLE Staff (
    staff_id INTEGER PRIMARY KEY DEFAULT nextval('staff_id_seq'),
    hotel_id INTEGER NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    position VARCHAR(50) NOT NULL,
    department VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    hire_date DATE NOT NULL DEFAULT CURRENT_DATE,
    
    CONSTRAINT fk_staff_hotel FOREIGN KEY (hotel_id) REFERENCES Hotels(hotel_id) ON DELETE CASCADE,
    CONSTRAINT chk_staff_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_hire_date CHECK (hire_date <= CURRENT_DATE)
);

-- Room Types Table
CREATE TABLE Room_Types (
    room_type_id INTEGER PRIMARY KEY DEFAULT nextval('room_type_id_seq'),
    hotel_id INTEGER NOT NULL,
    type_name VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    base_price DECIMAL(10,2) NOT NULL CHECK (base_price > 0),
    capacity INTEGER NOT NULL CHECK (capacity > 0 AND capacity <= 10),
    
    CONSTRAINT fk_room_type_hotel FOREIGN KEY (hotel_id) REFERENCES Hotels(hotel_id) ON DELETE CASCADE,
    CONSTRAINT uk_hotel_room_type UNIQUE (hotel_id, type_name)
);

-- Rooms Table
CREATE TABLE Rooms (
    room_id INTEGER PRIMARY KEY DEFAULT nextval('room_id_seq'),
    hotel_id INTEGER NOT NULL,
    room_type_id INTEGER NOT NULL,
    room_number VARCHAR(10) NOT NULL,
    floor INTEGER NOT NULL CHECK (floor >= 0),
    status VARCHAR(50) NOT NULL DEFAULT 'Available',
    is_smoking CHAR(1) NOT NULL DEFAULT 'N' CHECK (is_smoking IN ('Y', 'N')),
    
    CONSTRAINT fk_room_hotel FOREIGN KEY (hotel_id) REFERENCES Hotels(hotel_id) ON DELETE CASCADE,
    CONSTRAINT fk_room_type FOREIGN KEY (room_type_id) REFERENCES Room_Types(room_type_id) ON DELETE RESTRICT,
    CONSTRAINT uk_hotel_room_number UNIQUE (hotel_id, room_number),
    CONSTRAINT chk_room_status CHECK (status IN ('Available', 'Occupied', 'Maintenance', 'Out of Order'))
);

-- Guests Table
CREATE TABLE Guests (
    guest_id INTEGER PRIMARY KEY DEFAULT nextval('guest_id_seq'),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    address VARCHAR(200),
    date_of_birth DATE,
    nationality VARCHAR(50),
    id_type VARCHAR(50) NOT NULL,
    id_number VARCHAR(50) NOT NULL,
    registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
    
    CONSTRAINT chk_guest_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_dob CHECK (date_of_birth < CURRENT_DATE),
    CONSTRAINT chk_age CHECK (EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) >= 18),
    CONSTRAINT uk_id_number UNIQUE (id_type, id_number)
);

-- Reservations Table
CREATE TABLE Reservations (
    reservation_id INTEGER PRIMARY KEY DEFAULT nextval('reservation_id_seq'),
    guest_id INTEGER NOT NULL,
    hotel_id INTEGER NOT NULL,
    booking_date DATE NOT NULL DEFAULT CURRENT_DATE,
    status VARCHAR(50) NOT NULL DEFAULT 'Confirmed',
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
    payment_status VARCHAR(50) NOT NULL DEFAULT 'Pending',
    booking_source VARCHAR(100) DEFAULT 'Direct',
    special_requests TEXT,
    
    CONSTRAINT fk_reservation_guest FOREIGN KEY (guest_id) REFERENCES Guests(guest_id) ON DELETE CASCADE,
    CONSTRAINT fk_reservation_hotel FOREIGN KEY (hotel_id) REFERENCES Hotels(hotel_id) ON DELETE CASCADE,
    CONSTRAINT chk_reservation_dates CHECK (check_out_date > check_in_date),
    CONSTRAINT chk_reservation_status CHECK (status IN ('Confirmed', 'Cancelled', 'Completed', 'No-Show')),
    CONSTRAINT chk_payment_status CHECK (payment_status IN ('Pending', 'Paid', 'Partial', 'Refunded'))
);

-- Reservation Details Table
CREATE TABLE Reservation_Details (
    reservation_detail_id INTEGER PRIMARY KEY DEFAULT nextval('reservation_detail_id_seq'),
    reservation_id INTEGER NOT NULL,
    room_id INTEGER NOT NULL,
    adults INTEGER NOT NULL DEFAULT 1 CHECK (adults > 0),
    children INTEGER NOT NULL DEFAULT 0 CHECK (children >= 0),
    room_price DECIMAL(10,2) NOT NULL CHECK (room_price > 0),
    
    CONSTRAINT fk_res_detail_reservation FOREIGN KEY (reservation_id) REFERENCES Reservations(reservation_id) ON DELETE CASCADE,
    CONSTRAINT fk_res_detail_room FOREIGN KEY (room_id) REFERENCES Rooms(room_id) ON DELETE RESTRICT,
    CONSTRAINT uk_reservation_room UNIQUE (reservation_id, room_id)
);

-- Services Table
CREATE TABLE Services (
    service_id INTEGER PRIMARY KEY DEFAULT nextval('service_id_seq'),
    hotel_id INTEGER NOT NULL,
    service_name VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    service_category VARCHAR(100) NOT NULL,
    
    CONSTRAINT fk_service_hotel FOREIGN KEY (hotel_id) REFERENCES Hotels(hotel_id) ON DELETE CASCADE,
    CONSTRAINT uk_hotel_service UNIQUE (hotel_id, service_name)
);

-- Service Bookings Table
CREATE TABLE Service_Bookings (
    service_booking_id INTEGER PRIMARY KEY DEFAULT nextval('service_booking_id_seq'),
    reservation_id INTEGER NOT NULL,
    service_id INTEGER NOT NULL,
    service_date DATE NOT NULL DEFAULT CURRENT_DATE,
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    total_price DECIMAL(10,2) NOT NULL CHECK (total_price >= 0),
    status VARCHAR(50) NOT NULL DEFAULT 'Booked',
    
    CONSTRAINT fk_service_booking_reservation FOREIGN KEY (reservation_id) REFERENCES Reservations(reservation_id) ON DELETE CASCADE,
    CONSTRAINT fk_service_booking_service FOREIGN KEY (service_id) REFERENCES Services(service_id) ON DELETE RESTRICT,
    CONSTRAINT chk_service_booking_status CHECK (status IN ('Booked', 'Completed', 'Cancelled'))
);

-- Payments Table
CREATE TABLE Payments (
    payment_id INTEGER PRIMARY KEY DEFAULT nextval('payment_id_seq'),
    reservation_id INTEGER NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    payment_method VARCHAR(50) NOT NULL,
    transaction_id VARCHAR(50) UNIQUE,
    status VARCHAR(50) NOT NULL DEFAULT 'Completed',
    
    CONSTRAINT fk_payment_reservation FOREIGN KEY (reservation_id) REFERENCES Reservations(reservation_id) ON DELETE CASCADE,
    CONSTRAINT chk_payment_method CHECK (payment_method IN ('Cash', 'Credit Card', 'Debit Card', 'Bank Transfer', 'Online Payment')),
    CONSTRAINT chk_payment_status CHECK (status IN ('Pending', 'Completed', 'Failed', 'Refunded'))
);

-- ========================================
-- DATA INSERTION
-- ========================================

-- Insert Hotels
INSERT INTO Hotels (hotel_name, address, city, country, phone, email, star_rating) VALUES
('Grand Plaza Hotel', '123 Main Street', 'New York', 'USA', '+1-212-555-0101', 'info@grandplaza.com', 5),
('Ocean View Resort', '456 Beach Boulevard', 'Miami', 'USA', '+1-305-555-0102', 'reservations@oceanview.com', 4),
('Mountain Lodge', '789 Alpine Way', 'Denver', 'USA', '+1-303-555-0103', 'contact@mountainlodge.com', 3),
('City Center Inn', '321 Downtown Ave', 'Chicago', 'USA', '+1-312-555-0104', 'bookings@citycenter.com', 4),
('Sunset Paradise', '654 Coastal Drive', 'San Diego', 'USA', '+1-619-555-0105', 'info@sunsetparadise.com', 5);

-- Insert Staff
INSERT INTO Staff (hotel_id, first_name, last_name, position, department, email, phone, hire_date) VALUES
(1, 'John', 'Smith', 'Manager', 'Administration', 'j.smith@grandplaza.com', '+1-212-555-1001', '2023-01-15'),
(1, 'Sarah', 'Johnson', 'Front Desk Agent', 'Reception', 's.johnson@grandplaza.com', '+1-212-555-1002', '2023-03-20'),
(1, 'Mike', 'Wilson', 'Housekeeping Supervisor', 'Housekeeping', 'm.wilson@grandplaza.com', '+1-212-555-1003', '2023-02-10'),
(2, 'Emily', 'Davis', 'Manager', 'Administration', 'e.davis@oceanview.com', '+1-305-555-2001', '2023-01-10'),
(2, 'Robert', 'Brown', 'Concierge', 'Guest Services', 'r.brown@oceanview.com', '+1-305-555-2002', '2023-04-05'),
(3, 'Lisa', 'Martinez', 'Manager', 'Administration', 'l.martinez@mountainlodge.com', '+1-303-555-3001', '2023-02-01'),
(4, 'David', 'Lee', 'Manager', 'Administration', 'd.lee@citycenter.com', '+1-312-555-4001', '2023-01-25'),
(5, 'Jennifer', 'Taylor', 'Manager', 'Administration', 'j.taylor@sunsetparadise.com', '+1-619-555-5001', '2023-03-01');

-- Insert Room Types
INSERT INTO Room_Types (hotel_id, type_name, description, base_price, capacity) VALUES
(1, 'Standard Single', 'Comfortable single room with city view', 150.00, 1),
(1, 'Deluxe Double', 'Spacious double room with premium amenities', 220.00, 2),
(1, 'Executive Suite', 'Luxurious suite with separate living area', 450.00, 4),
(2, 'Ocean View Single', 'Single room with ocean view', 180.00, 1),
(2, 'Ocean View Double', 'Double room with stunning ocean view', 280.00, 2),
(2, 'Presidential Suite', 'Ultimate luxury suite with panoramic ocean view', 800.00, 6),
(3, 'Mountain Cabin', 'Cozy cabin with mountain view', 120.00, 2),
(3, 'Family Lodge', 'Large family room with fireplace', 200.00, 6),
(4, 'Business Single', 'Modern single room for business travelers', 140.00, 1),
(4, 'Business Double', 'Double room with work desk and WiFi', 190.00, 2),
(5, 'Sunset Single', 'Single room with sunset view', 200.00, 1),
(5, 'Sunset Suite', 'Luxury suite with private balcony', 500.00, 4);

-- Insert Rooms
INSERT INTO Rooms (hotel_id, room_type_id, room_number, floor, status, is_smoking) VALUES
-- Grand Plaza Hotel (hotel_id: 1)
(1, 1, '101', 1, 'Available', 'N'),
(1, 1, '102', 1, 'Available', 'Y'),
(1, 2, '201', 2, 'Available', 'N'),
(1, 2, '202', 2, 'Occupied', 'N'),
(1, 3, '301', 3, 'Available', 'N'),
-- Ocean View Resort (hotel_id: 2)
(2, 4, '101', 1, 'Available', 'N'),
(2, 5, '201', 2, 'Available', 'N'),
(2, 6, '401', 4, 'Available', 'N'),
-- Mountain Lodge (hotel_id: 3)
(3, 7, 'C01', 1, 'Available', 'N'),
(3, 8, 'L01', 1, 'Available', 'N'),
-- City Center Inn (hotel_id: 4)
(4, 9, '101', 1, 'Available', 'N'),
(4, 10, '201', 2, 'Available', 'N'),
-- Sunset Paradise (hotel_id: 5)
(5, 11, '101', 1, 'Available', 'N'),
(5, 12, '401', 4, 'Available', 'N');

-- Insert Guests
INSERT INTO Guests (first_name, last_name, email, phone, address, date_of_birth, nationality, id_type, id_number) VALUES
('James', 'Anderson', 'james.anderson@email.com', '+1-555-0001', '123 Oak Street, Boston, MA', '1985-06-15', 'American', 'Passport', 'US123456789'),
('Maria', 'Garcia', 'maria.garcia@email.com', '+1-555-0002', '456 Pine Avenue, Los Angeles, CA', '1990-03-22', 'American', 'Driver License', 'CA987654321'),
('William', 'Chen', 'william.chen@email.com', '+1-555-0003', '789 Maple Drive, Seattle, WA', '1988-11-08', 'American', 'Passport', 'US987654321'),
('Sophie', 'Mueller', 'sophie.mueller@email.com', '+49-555-0004', '321 Berlin Street, Berlin, Germany', '1992-07-12', 'German', 'Passport', 'DE456789123'),
('Akiko', 'Tanaka', 'akiko.tanaka@email.com', '+81-555-0005', '654 Tokyo Boulevard, Tokyo, Japan', '1987-09-30', 'Japanese', 'Passport', 'JP789123456'),
('Carlos', 'Rodriguez', 'carlos.rodriguez@email.com', '+34-555-0006', '987 Madrid Avenue, Madrid, Spain', '1991-05-18', 'Spanish', 'Passport', 'ES321654987'),
('Emma', 'Thompson', 'emma.thompson@email.com', '+44-555-0007', '147 London Road, London, UK', '1989-12-03', 'British', 'Passport', 'GB654987321'),
('Pierre', 'Dubois', 'pierre.dubois@email.com', '+33-555-0008', '258 Paris Street, Paris, France', '1986-04-25', 'French', 'Passport', 'FR159753486');

-- Insert Reservations
INSERT INTO Reservations (guest_id, hotel_id, booking_date, status, check_in_date, check_out_date, total_amount, payment_status, booking_source) VALUES
(1, 1, '2024-01-15', 'Completed', '2024-02-01', '2024-02-05', 880.00, 'Paid', 'Direct'),
(2, 2, '2024-01-20', 'Confirmed', '2024-03-15', '2024-03-20', 1400.00, 'Paid', 'Online'),
(3, 3, '2024-02-01', 'Confirmed', '2024-04-10', '2024-04-12', 240.00, 'Pending', 'Travel Agency'),
(4, 1, '2024-02-05', 'Cancelled', '2024-03-01', '2024-03-03', 440.00, 'Refunded', 'Direct'),
(5, 5, '2024-02-10', 'Confirmed', '2024-05-01', '2024-05-07', 1200.00, 'Partial', 'Online'),
(6, 4, '2024-02-15', 'Confirmed', '2024-06-15', '2024-06-18', 570.00, 'Paid', 'Phone'),
(7, 2, '2024-02-20', 'Completed', '2024-03-01', '2024-03-05', 1120.00, 'Paid', 'Direct'),
(8, 3, '2024-02-25', 'Confirmed', '2024-07-20', '2024-07-25', 1000.00, 'Pending', 'Online');

-- Insert Reservation Details
INSERT INTO Reservation_Details (reservation_id, room_id, adults, children, room_price) VALUES
(1, 3, 2, 0, 220.00), -- Grand Plaza Deluxe Double for 4 nights
(2, 7, 2, 1, 280.00), -- Ocean View Double for 5 nights
(3, 9, 2, 0, 120.00), -- Mountain Cabin for 2 nights
(4, 3, 2, 0, 220.00), -- Grand Plaza Deluxe Double (cancelled)
(5, 13, 1, 0, 200.00), -- Sunset Single for 6 nights
(6, 12, 2, 1, 190.00), -- City Center Business Double for 3 nights
(7, 8, 4, 2, 280.00), -- Ocean View Double for 4 nights
(8, 10, 4, 2, 200.00); -- Mountain Family Lodge for 5 nights

-- Insert Services
INSERT INTO Services (hotel_id, service_name, description, price, service_category) VALUES
(1, 'Room Service', '24/7 in-room dining service', 15.00, 'Food & Beverage'),
(1, 'Laundry Service', 'Professional laundry and dry cleaning', 25.00, 'Housekeeping'),
(1, 'Spa Treatment', 'Relaxing spa and massage services', 120.00, 'Wellness'),
(1, 'Airport Transfer', 'Private airport transportation', 50.00, 'Transportation'),
(2, 'Beach Equipment Rental', 'Umbrellas, chairs, and water sports equipment', 30.00, 'Recreation'),
(2, 'Sunset Cruise', 'Romantic sunset cruise experience', 85.00, 'Entertainment'),
(2, 'Scuba Diving', 'Professional scuba diving lessons and tours', 150.00, 'Adventure'),
(3, 'Hiking Guide', 'Professional mountain hiking guide', 75.00, 'Adventure'),
(3, 'Equipment Rental', 'Hiking and camping equipment rental', 40.00, 'Recreation'),
(4, 'Business Center', 'Meeting rooms and office services', 35.00, 'Business'),
(4, 'City Tour', 'Guided city sightseeing tour', 45.00, 'Entertainment'),
(5, 'Yoga Classes', 'Morning yoga sessions on the beach', 25.00, 'Wellness'),
(5, 'Wine Tasting', 'Premium wine tasting experience', 95.00, 'Food & Beverage');

-- Insert Service Bookings
INSERT INTO Service_Bookings (reservation_id, service_id, service_date, quantity, total_price, status) VALUES
(1, 1, '2024-02-02', 2, 30.00, 'Completed'),
(1, 3, '2024-02-03', 1, 120.00, 'Completed'),
(2, 5, '2024-03-16', 1, 30.00, 'Booked'),
(2, 6, '2024-03-18', 2, 170.00, 'Booked'),
(5, 12, '2024-05-02', 3, 75.00, 'Booked'),
(5, 13, '2024-05-05', 2, 190.00, 'Booked'),
(6, 10, '2024-06-16', 1, 35.00, 'Booked'),
(7, 7, '2024-03-03', 2, 300.00, 'Completed'),
(8, 8, '2024-07-22', 1, 75.00, 'Booked');

-- Insert Payments
INSERT INTO Payments (reservation_id, amount, payment_date, payment_method, transaction_id, status) VALUES
(1, 880.00, '2024-01-15', 'Credit Card', 'TXN001234567', 'Completed'),
(2, 1400.00, '2024-01-20', 'Online Payment', 'TXN001234568', 'Completed'),
(4, -440.00, '2024-02-06', 'Credit Card', 'TXN001234569', 'Refunded'),
(5, 600.00, '2024-02-10', 'Credit Card', 'TXN001234570', 'Completed'),
(6, 570.00, '2024-02-15', 'Bank Transfer', 'TXN001234571', 'Completed'),
(7, 1120.00, '2024-02-20', 'Credit Card', 'TXN001234572', 'Completed');

-- ========================================
-- CREATE INDEXES FOR PERFORMANCE
-- ========================================

CREATE INDEX idx_reservations_dates ON Reservations(check_in_date, check_out_date);
CREATE INDEX idx_reservations_status ON Reservations(status);
CREATE INDEX idx_rooms_status ON Rooms(status);
CREATE INDEX idx_guests_email ON Guests(email);
CREATE INDEX idx_payments_date ON Payments(payment_date);
CREATE INDEX idx_service_bookings_date ON Service_Bookings(service_date);

-- ========================================
-- VIEWS FOR COMMON QUERIES
-- ========================================

-- View for available rooms
CREATE VIEW available_rooms AS
SELECT 
    h.hotel_name,
    r.room_number,
    rt.type_name,
    rt.base_price,
    rt.capacity,
    r.floor,
    r.is_smoking
FROM Rooms r
JOIN Hotels h ON r.hotel_id = h.hotel_id
JOIN Room_Types rt ON r.room_type_id = rt.room_type_id
WHERE r.status = 'Available';

-- View for current reservations
CREATE VIEW current_reservations AS
SELECT 
    res.reservation_id,
    g.first_name || ' ' || g.last_name AS guest_name,
    h.hotel_name,
    res.check_in_date,
    res.check_out_date,
    res.total_amount,
    res.payment_status
FROM Reservations res
JOIN Guests g ON res.guest_id = g.guest_id
JOIN Hotels h ON res.hotel_id = h.hotel_id
WHERE res.status = 'Confirmed' 
   OR (res.status = 'Completed' AND res.check_out_date >= CURRENT_DATE);

-- View for hotel revenue summary
CREATE VIEW hotel_revenue_summary AS
SELECT 
    h.hotel_name,
    COUNT(res.reservation_id) as total_reservations,
    SUM(res.total_amount) as total_revenue,
    AVG(res.total_amount) as avg_reservation_value,
    COUNT(CASE WHEN res.status = 'Completed' THEN 1 END) as completed_reservations
FROM Hotels h
LEFT JOIN Reservations res ON h.hotel_id = res.hotel_id
GROUP BY h.hotel_id, h.hotel_name;




-- STORED PROCEDURES


-- Procedure to get hotel occupancy rate with cursor and exception handling
CREATE OR REPLACE FUNCTION get_hotel_occupancy(
    p_hotel_id INTEGER,
    p_start_date DATE DEFAULT CURRENT_DATE,
    p_end_date DATE DEFAULT CURRENT_DATE + INTERVAL '30 days'
)
RETURNS TABLE(
    hotel_name VARCHAR(100),
    total_rooms INTEGER,
    occupied_rooms INTEGER,
    occupancy_rate DECIMAL(5,2),
    analysis_period VARCHAR(50)
) AS $
DECLARE
    room_cursor CURSOR FOR 
        SELECT r.room_id, r.room_number, r.status
        FROM Rooms r 
        WHERE r.hotel_id = p_hotel_id;
    
    reservation_cursor CURSOR FOR
        SELECT DISTINCT rd.room_id
        FROM Reservation_Details rd
        JOIN Reservations res ON rd.reservation_id = res.reservation_id
        WHERE res.hotel_id = p_hotel_id
          AND res.status IN ('Confirmed', 'Completed')
          AND res.check_in_date <= p_end_date
          AND res.check_out_date >= p_start_date;
    
    v_hotel_name VARCHAR(100);
    v_total_rooms INTEGER := 0;
    v_occupied_rooms INTEGER := 0;
    v_room_record RECORD;
    v_reservation_record RECORD;
    occupied_room_ids INTEGER[];
BEGIN
    -- Exception handling
    BEGIN
        -- Get hotel name
        SELECT h.hotel_name INTO STRICT v_hotel_name
        FROM Hotels h WHERE h.hotel_id = p_hotel_id;
        
        -- Count total rooms using cursor
        FOR v_room_record IN room_cursor LOOP
            v_total_rooms := v_total_rooms + 1;
        END LOOP;
        
        -- Get occupied rooms using cursor
        FOR v_reservation_record IN reservation_cursor LOOP
            occupied_room_ids := array_append(occupied_room_ids, v_reservation_record.room_id);
        END LOOP;
        
        v_occupied_rooms := array_length(occupied_room_ids, 1);
        IF v_occupied_rooms IS NULL THEN
            v_occupied_rooms := 0;
        END IF;
        
        -- Return results
        RETURN QUERY SELECT 
            v_hotel_name,
            v_total_rooms,
            v_occupied_rooms,
            CASE 
                WHEN v_total_rooms > 0 THEN ROUND((v_occupied_rooms::DECIMAL / v_total_rooms * 100), 2)
                ELSE 0.00
            END,
            p_start_date::VARCHAR || ' to ' || p_end_date::VARCHAR;
            
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE EXCEPTION 'Hotel with ID % not found', p_hotel_id;
        WHEN OTHERS THEN
            RAISE EXCEPTION 'Error calculating occupancy: %', SQLERRM;
    END;
END;


-- Procedure to process reservation with parameters and exception handling
CREATE OR REPLACE FUNCTION process_reservation(
    p_guest_id INTEGER,
    p_hotel_id INTEGER,
    p_room_type_id INTEGER,
    p_check_in DATE,
    p_check_out DATE,
    p_adults INTEGER DEFAULT 1,
    p_children INTEGER DEFAULT 0,
    p_special_requests TEXT DEFAULT NULL
)
RETURNS INTEGER AS $
DECLARE
    v_reservation_id INTEGER;
    v_room_id INTEGER;
    v_room_price DECIMAL(10,2);
    v_total_nights INTEGER;
    v_total_amount DECIMAL(10,2);
    v_available_room_cursor CURSOR FOR
        SELECT r.room_id
        FROM Rooms r
        JOIN Room_Types rt ON r.room_type_id = rt.room_type_id
        WHERE r.hotel_id = p_hotel_id
          AND r.room_type_id = p_room_type_id
          AND r.status = 'Available'
          AND r.room_id NOT IN (
              SELECT rd.room_id
              FROM Reservation_Details rd
              JOIN Reservations res ON rd.reservation_id = res.reservation_id
              WHERE res.status IN ('Confirmed', 'Completed')
                AND res.check_in_date < p_check_out
                AND res.check_out_date > p_check_in
          )
        LIMIT 1;
    v_room_record RECORD;
BEGIN
    -- Input validation and exception handling
    BEGIN
        -- Validate dates
        IF p_check_in >= p_check_out THEN
            RAISE EXCEPTION 'Check-in date must be before check-out date';
        END IF;
        
        IF p_check_in < CURRENT_DATE THEN
            RAISE EXCEPTION 'Check-in date cannot be in the past';
        END IF;
        
        -- Get room price and calculate total
        SELECT rt.base_price INTO STRICT v_room_price
        FROM Room_Types rt
        WHERE rt.room_type_id = p_room_type_id AND rt.hotel_id = p_hotel_id;
        
        v_total_nights := p_check_out - p_check_in;
        v_total_amount := v_room_price * v_total_nights;
        
        -- Find available room using cursor
        OPEN v_available_room_cursor;
        FETCH v_available_room_cursor INTO v_room_record;
        
        IF NOT FOUND THEN
            CLOSE v_available_room_cursor;
            RAISE EXCEPTION 'No available rooms of the requested type for the specified dates';
        END IF;
        
        v_room_id := v_room_record.room_id;
        CLOSE v_available_room_cursor;
        
        -- Create reservation
        INSERT INTO Reservations (
            guest_id, hotel_id, check_in_date, check_out_date, 
            total_amount, special_requests
        )
        VALUES (
            p_guest_id, p_hotel_id, p_check_in, p_check_out,
            v_total_amount, p_special_requests
        )
        RETURNING reservation_id INTO v_reservation_id;
        
        -- Create reservation details
        INSERT INTO Reservation_Details (
            reservation_id, room_id, adults, children, room_price
        )
        VALUES (
            v_reservation_id, v_room_id, p_adults, p_children, v_room_price
        );
        
        -- Update room status
        UPDATE Rooms SET status = 'Occupied' WHERE room_id = v_room_id;
        
        RETURN v_reservation_id;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE EXCEPTION 'Invalid hotel or room type specified';
        WHEN OTHERS THEN
            RAISE EXCEPTION 'Error processing reservation: %', SQLERRM;
    END;
END;


-- Procedure to cancel reservation with refund calculation
CREATE OR REPLACE FUNCTION cancel_reservation(
    p_reservation_id INTEGER,
    p_cancellation_reason TEXT DEFAULT 'Customer Request'
)
RETURNS TABLE(
    reservation_id INTEGER,
    refund_amount DECIMAL(10,2),
    cancellation_fee DECIMAL(10,2),
    status VARCHAR(50)
) AS $
DECLARE
    v_reservation RECORD;
    v_days_until_checkin INTEGER;
    v_refund_amount DECIMAL(10,2);
    v_cancellation_fee DECIMAL(10,2);
    room_cursor CURSOR FOR
        SELECT rd.room_id
        FROM Reservation_Details rd
        WHERE rd.reservation_id = p_reservation_id;
    v_room_record RECORD;
BEGIN
    BEGIN
        -- Get reservation details
        SELECT res.*, res.check_in_date, res.total_amount
        INTO STRICT v_reservation
        FROM Reservations res
        WHERE res.reservation_id = p_reservation_id
          AND res.status = 'Confirmed';
        
        -- Calculate days until check-in
        v_days_until_checkin := v_reservation.check_in_date - CURRENT_DATE;
        
        -- Calculate refund based on cancellation policy
        IF v_days_until_checkin >= 7 THEN
            v_cancellation_fee := 0.00;
            v_refund_amount := v_reservation.total_amount;
        ELSIF v_days_until_checkin >= 3 THEN
            v_cancellation_fee := v_reservation.total_amount * 0.25;
            v_refund_amount := v_reservation.total_amount * 0.75;
        ELSIF v_days_until_checkin >= 1 THEN
            v_cancellation_fee := v_reservation.total_amount * 0.50;
            v_refund_amount := v_reservation.total_amount * 0.50;
        ELSE
            v_cancellation_fee := v_reservation.total_amount;
            v_refund_amount := 0.00;
        END IF;
        
        -- Update reservation status
        UPDATE Reservations 
        SET status = 'Cancelled', 
            payment_status = CASE 
                WHEN v_refund_amount > 0 THEN 'Refunded'
                ELSE 'Paid'
            END
        WHERE reservation_id = p_reservation_id;
        
        -- Free up rooms using cursor
        FOR v_room_record IN room_cursor LOOP
            UPDATE Rooms 
            SET status = 'Available' 
            WHERE room_id = v_room_record.room_id;
        END LOOP;
        
        -- Record refund payment if applicable
        IF v_refund_amount > 0 THEN
            INSERT INTO Payments (
                reservation_id, amount, payment_method, 
                transaction_id, status
            )
            VALUES (
                p_reservation_id, -v_refund_amount, 'Refund',
                'REF' || p_reservation_id || '_' || EXTRACT(EPOCH FROM NOW())::INTEGER,
                'Completed'
            );
        END IF;
        
        RETURN QUERY SELECT 
            p_reservation_id,
            v_refund_amount,
            v_cancellation_fee,
            'Cancelled'::VARCHAR(50);
            
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE EXCEPTION 'Reservation % not found or already cancelled', p_reservation_id;
        WHEN OTHERS THEN
            RAISE EXCEPTION 'Error cancelling reservation: %', SQLERRM;
    END;
END;


-- ========================================
-- ANALYTICAL FUNCTIONS WITH WINDOW FUNCTIONS
-- ========================================

-- Function to analyze hotel performance with ranking and analytics
CREATE OR REPLACE FUNCTION analyze_hotel_performance(
    p_start_date DATE DEFAULT CURRENT_DATE - INTERVAL '12 months',
    p_end_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE(
    hotel_name VARCHAR(100),
    total_revenue DECIMAL(12,2),
    total_reservations INTEGER,
    avg_reservation_value DECIMAL(10,2),
    revenue_rank INTEGER,
    revenue_percentile DECIMAL(5,2),
    month_over_month_growth DECIMAL(5,2),
    performance_category VARCHAR(20)
) AS $
BEGIN
    RETURN QUERY
    WITH hotel_metrics AS (
        SELECT 
            h.hotel_name,
            SUM(res.total_amount) as total_revenue,
            COUNT(res.reservation_id) as total_reservations,
            AVG(res.total_amount) as avg_reservation_value,
            LAG(SUM(res.total_amount)) OVER (
                PARTITION BY h.hotel_id 
                ORDER BY DATE_TRUNC('month', res.booking_date)
            ) as prev_month_revenue
        FROM Hotels h
        LEFT JOIN Reservations res ON h.hotel_id = res.hotel_id
        WHERE res.booking_date BETWEEN p_start_date AND p_end_date
          AND res.status IN ('Confirmed', 'Completed')
        GROUP BY h.hotel_id, h.hotel_name, DATE_TRUNC('month', res.booking_date)
    ),
    aggregated_metrics AS (
        SELECT 
            hotel_name,
            SUM(total_revenue) as total_revenue,
            SUM(total_reservations) as total_reservations,
            AVG(avg_reservation_value) as avg_reservation_value,
            AVG(CASE 
                WHEN prev_month_revenue > 0 THEN 
                    ((total_revenue - prev_month_revenue) / prev_month_revenue * 100)
                ELSE 0
            END) as month_over_month_growth
        FROM hotel_metrics
        WHERE total_revenue IS NOT NULL
        GROUP BY hotel_name
    )
    SELECT 
        am.hotel_name,
        COALESCE(am.total_revenue, 0.00) as total_revenue,
        COALESCE(am.total_reservations, 0) as total_reservations,
        COALESCE(am.avg_reservation_value, 0.00) as avg_reservation_value,
        RANK() OVER (ORDER BY am.total_revenue DESC) as revenue_rank,
        ROUND(
            PERCENT_RANK() OVER (ORDER BY am.total_revenue) * 100, 2
        ) as revenue_percentile,
        COALESCE(ROUND(am.month_over_month_growth, 2), 0.00) as month_over_month_growth,
        CASE 
            WHEN RANK() OVER (ORDER BY am.total_revenue DESC) <= 2 THEN 'Top Performer'
            WHEN PERCENT_RANK() OVER (ORDER BY am.total_revenue) >= 0.6 THEN 'Good'
            WHEN PERCENT_RANK() OVER (ORDER BY am.total_revenue) >= 0.3 THEN 'Average'
            ELSE 'Needs Improvement'
        END as performance_category
    FROM aggregated_metrics am
    ORDER BY am.total_revenue DESC;
END;


-- Function to analyze guest booking patterns with window functions
CREATE OR REPLACE FUNCTION analyze_guest_patterns()
RETURNS TABLE(
    guest_name VARCHAR(201),
    total_reservations INTEGER,
    total_spent DECIMAL(12,2),
    avg_stay_duration DECIMAL(5,2),
    favorite_hotel VARCHAR(100),
    guest_tier VARCHAR(20),
    last_booking_date DATE,
    days_since_last_booking INTEGER
) AS $
BEGIN
    RETURN QUERY
    WITH guest_stats AS (
        SELECT 
            g.guest_id,
            g.first_name || ' ' || g.last_name as guest_name,
            COUNT(res.reservation_id) as total_reservations,
            COALESCE(SUM(res.total_amount), 0) as total_spent,
            AVG(res.check_out_date - res.check_in_date) as avg_stay_duration,
            MAX(res.booking_date) as last_booking_date,
            CURRENT_DATE - MAX(res.booking_date) as days_since_last_booking
        FROM Guests g
        LEFT JOIN Reservations res ON g.guest_id = res.guest_id
        WHERE res.status IN ('Confirmed', 'Completed')
        GROUP BY g.guest_id, g.first_name, g.last_name
    ),
    favorite_hotels AS (
        SELECT DISTINCT ON (g.guest_id)
            g.guest_id,
            h.hotel_name,
            COUNT(*) OVER (PARTITION BY g.guest_id, h.hotel_id) as visit_count
        FROM Guests g
        JOIN Reservations res ON g.guest_id = res.guest_id
        JOIN Hotels h ON res.hotel_id = h.hotel_id
        WHERE res.status IN ('Confirmed', 'Completed')
        ORDER BY g.guest_id, visit_count DESC
    )
    SELECT 
        gs.guest_name,
        gs.total_reservations,
        gs.total_spent,
        ROUND(gs.avg_stay_duration, 2) as avg_stay_duration,
        COALESCE(fh.hotel_name, 'N/A') as favorite_hotel,
        CASE 
            WHEN gs.total_spent >= 2000 THEN 'Platinum'
            WHEN gs.total_spent >= 1000 THEN 'Gold'
            WHEN gs.total_spent >= 500 THEN 'Silver'
            ELSE 'Bronze'
        END as guest_tier,
        gs.last_booking_date,
        gs.days_since_last_booking
    FROM guest_stats gs
    LEFT JOIN favorite_hotels fh ON gs.guest_id = fh.guest_id
    WHERE gs.total_reservations > 0
    ORDER BY gs.total_spent DESC;
END;


-- ========================================
-- PACKAGES (PostgreSQL Schema-based organization)
-- ========================================

-- Create schemas to organize functions into logical packages
CREATE SCHEMA IF NOT EXISTS reservation_pkg;
CREATE SCHEMA IF NOT EXISTS analytics_pkg;
CREATE SCHEMA IF NOT EXISTS guest_pkg;

-- Move reservation functions to reservation package
CREATE OR REPLACE FUNCTION reservation_pkg.create_reservation(
    p_guest_id INTEGER,
    p_hotel_id INTEGER,
    p_room_type_id INTEGER,
    p_check_in DATE,
    p_check_out DATE,
    p_adults INTEGER DEFAULT 1,
    p_children INTEGER DEFAULT 0,
    p_special_requests TEXT DEFAULT NULL
)
RETURNS INTEGER AS $
BEGIN
    RETURN process_reservation(
        p_guest_id, p_hotel_id, p_room_type_id, 
        p_check_in, p_check_out, p_adults, p_children, p_special_requests
    );
END;


CREATE OR REPLACE FUNCTION reservation_pkg.cancel_reservation(
    p_reservation_id INTEGER,
    p_reason TEXT DEFAULT 'Customer Request'
)
RETURNS TABLE(
    reservation_id INTEGER,
    refund_amount DECIMAL(10,2),
    cancellation_fee DECIMAL(10,2),
    status VARCHAR(50)
) AS $
BEGIN
    RETURN QUERY SELECT * FROM cancel_reservation(p_reservation_id, p_reason);
END;


-- Move analytics functions to analytics package
CREATE OR REPLACE FUNCTION analytics_pkg.hotel_performance_report(
    p_start_date DATE DEFAULT CURRENT_DATE - INTERVAL '12 months',
    p_end_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE(
    hotel_name VARCHAR(100),
    total_revenue DECIMAL(12,2),
    total_reservations INTEGER,
    avg_reservation_value DECIMAL(10,2),
    revenue_rank INTEGER,
    revenue_percentile DECIMAL(5,2),
    month_over_month_growth DECIMAL(5,2),
    performance_category VARCHAR(20)
) AS $
BEGIN
    RETURN QUERY SELECT * FROM analyze_hotel_performance(p_start_date, p_end_date);
END;


CREATE OR REPLACE FUNCTION analytics_pkg.occupancy_analysis(
    p_hotel_id INTEGER,
    p_start_date DATE DEFAULT CURRENT_DATE,
    p_end_date DATE DEFAULT CURRENT_DATE + INTERVAL '30 days'
)
RETURNS TABLE(
    hotel_name VARCHAR(100),
    total_rooms INTEGER,
    occupied_rooms INTEGER,
    occupancy_rate DECIMAL(5,2),
    analysis_period VARCHAR(50)
) AS $
BEGIN
    RETURN QUERY SELECT * FROM get_hotel_occupancy(p_hotel_id, p_start_date, p_end_date);
END;
-- Move guest functions to guest package
CREATE OR REPLACE FUNCTION guest_pkg.guest_profile_analysis()
RETURNS TABLE(
    guest_name VARCHAR(201),
    total_reservations INTEGER,
    total_spent DECIMAL(12,2),
    avg_stay_duration DECIMAL(5,2),
    favorite_hotel VARCHAR(100),
    guest_tier VARCHAR(20),
    last_booking_date DATE,
    days_since_last_booking INTEGER
) AS $
BEGIN
    RETURN QUERY SELECT * FROM analyze_guest_patterns();
END;


CREATE OR REPLACE FUNCTION guest_pkg.get_guest_history(
    p_guest_id INTEGER
)
RETURNS TABLE(
    reservation_id INTEGER,
    hotel_name VARCHAR(100),
    check_in_date DATE,
    check_out_date DATE,
    total_amount DECIMAL(10,2),
    status VARCHAR(50)
) AS $
DECLARE
    guest_cursor CURSOR FOR
        SELECT res.reservation_id, h.hotel_name, res.check_in_date, 
               res.check_out_date, res.total_amount, res.status
        FROM Reservations res
        JOIN Hotels h ON res.hotel_id = h.hotel_id
        WHERE res.guest_id = p_guest_id
        ORDER BY res.booking_date DESC;
    v_record RECORD;
BEGIN
    FOR v_record IN guest_cursor LOOP
        RETURN QUERY SELECT 
            v_record.reservation_id,
            v_record.hotel_name,
            v_record.check_in_date,
            v_record.check_out_date,
            v_record.total_amount,
            v_record.status;
    END LOOP;
END;


-- ========================================
-- TESTING PROCEDURES AND FUNCTIONS
-- ========================================

-- Test function to validate all procedures work correctly
CREATE OR REPLACE FUNCTION test_hotel_system()
RETURNS TEXT AS $
DECLARE
    v_result TEXT := '';
    v_test_reservation_id INTEGER;
    v_test_guest_id INTEGER := 1;
    v_test_hotel_id INTEGER := 1;
    v_test_room_type_id INTEGER := 1;
BEGIN
    v_result := 'Hotel Management System Test Results:' || CHR(10);
    
    -- Test 1: Hotel Occupancy Analysis
    BEGIN
        v_result := v_result || '1. Testing Hotel Occupancy Analysis... ';
        PERFORM * FROM analytics_pkg.occupancy_analysis(1);
        v_result := v_result || 'PASSED' || CHR(10);
    EXCEPTION
        WHEN OTHERS THEN
            v_result := v_result || 'FAILED: ' || SQLERRM || CHR(10);
    END;
    
    -- Test 2: Guest Pattern Analysis
    BEGIN
        v_result := v_result || '2. Testing Guest Pattern Analysis... ';
        PERFORM * FROM guest_pkg.guest_profile_analysis();
        v_result := v_result || 'PASSED' || CHR(10);
    EXCEPTION
        WHEN OTHERS THEN
            v_result := v_result || 'FAILED: ' || SQLERRM || CHR(10);
    END;
    
    -- Test 3: Hotel Performance Report
    BEGIN
        v_result := v_result || '3. Testing Hotel Performance Report... ';
        PERFORM * FROM analytics_pkg.hotel_performance_report();
        v_result := v_result || 'PASSED' || CHR(10);
    EXCEPTION
        WHEN OTHERS THEN
            v_result := v_result || 'FAILED: ' || SQLERRM || CHR(10);
    END;
    
    -- Test 4: Guest History
    BEGIN
        v_result := v_result || '4. Testing Guest History... ';
        PERFORM * FROM guest_pkg.get_guest_history(1);
        v_result := v_result || 'PASSED' || CHR(10);
    EXCEPTION
        WHEN OTHERS THEN
            v_result := v_result || 'FAILED: ' || SQLERRM || CHR(10);
    END;
    
    v_result := v_result || CHR(10) || 'All core functions tested successfully!';
    RETURN v_result;
END;




COMMIT;