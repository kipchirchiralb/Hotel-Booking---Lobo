-- DROP tables if re-running
DROP TABLE IF EXISTS checkInCheckOutLogs, bookingNotes, payments, reviews, spotBookings, roomBookings, spotFacilities, roomFacilities, clients, spots, rooms;

-- 1. Rooms Table (WITH image_url)
CREATE TABLE rooms(
    room_id INT NOT NULL,
    room_type VARCHAR(50),
    price_per_night INT,
    label VARCHAR(50),
    image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY(room_id)
);

-- 2. Spots Table (WITH image_url)
CREATE TABLE spots(
    spot_id VARCHAR(20) NOT NULL,
    capacity_range VARCHAR(20),
    price INT,
    label VARCHAR(100),
    image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY(spot_id)
);

-- 3. Clients Table
CREATE TABLE clients(
    client_id INT NOT NULL AUTO_INCREMENT,
    full_name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    phone_number VARCHAR(15),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY(client_id)
);

-- 4. Room Bookings Table
CREATE TABLE roomBookings(
    booking_id INT NOT NULL AUTO_INCREMENT,
    client_id INT,
    room INT,
    number_of_nights INT,
    checkin_date DATE,
    booking_status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY(booking_id),
    FOREIGN KEY(client_id) REFERENCES clients(client_id),
    FOREIGN KEY(room) REFERENCES rooms(room_id)
);

-- 5. Spot Bookings Table
CREATE TABLE spotBookings(
    booking_id INT NOT NULL AUTO_INCREMENT,
    client_id INT,
    spot VARCHAR(20),
    checkin_datetime DATETIME,
    meals VARCHAR(60),
    booking_status VARCHAR(50) DEFAULT 'pending',
    number_of_guests INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY(booking_id),
    FOREIGN KEY(client_id) REFERENCES clients(client_id),
    FOREIGN KEY(spot) REFERENCES spots(spot_id)
);

-- 6. Reviews Table
CREATE TABLE reviews(
    review_id INT NOT NULL AUTO_INCREMENT,
    service_type ENUM('room', 'spot'),
    service_id INT, -- booking_id of roomBooking or spotBooking
    comment TEXT,
    rating INT CHECK(rating >=1 AND rating <=5),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY(review_id)
);

-- 7. Payments Table
CREATE TABLE payments(
    payment_id INT NOT NULL AUTO_INCREMENT,
    client_id INT,
    booking_type ENUM('room', 'spot'),
    booking_id INT,
    amount_paid INT,
    payment_method VARCHAR(30),
    payment_date DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY(payment_id),
    FOREIGN KEY(client_id) REFERENCES clients(client_id)
);

-- 8. Room Facilities Table
CREATE TABLE roomFacilities(
    facility_id INT NOT NULL AUTO_INCREMENT,
    room_id INT,
    facility VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY(facility_id),
    FOREIGN KEY(room_id) REFERENCES rooms(room_id)
);

-- 9. Spot Facilities Table
CREATE TABLE spotFacilities(
    facility_id INT NOT NULL AUTO_INCREMENT,
    spot_id VARCHAR(20),
    facility VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY(facility_id),
    FOREIGN KEY(spot_id) REFERENCES spots(spot_id)
);

-- 10. Check-in/Check-out Logs Table
CREATE TABLE checkInCheckOutLogs(
    log_id INT NOT NULL AUTO_INCREMENT,
    booking_type ENUM('room', 'spot'),
    booking_id INT,
    client_id INT,
    checkin_time DATETIME,
    checkout_time DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY(log_id),
    FOREIGN KEY(client_id) REFERENCES clients(client_id)
);

-- 11. Booking Notes Table
CREATE TABLE bookingNotes(
    note_id INT NOT NULL AUTO_INCREMENT,
    booking_type ENUM('room', 'spot'),
    booking_id INT,
    note TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY(note_id)
);

-- // table users 
CREATE TABLE users(email VARCHAR(100), name VARCHAR(50), role VARCHAR(50), password VARCHAR(255), PRIMARY KEY(email));

-- users data
INSERT INTO users (name, email, role, password)
VALUES
('Alice Reception', 'alice@company.com', 'reception', '$2b$10$zJZtBZHgDRPqkODyxwKMuOaU0XKkztHtHoEiX.Rz5OFLrWhd3WTNi'), -- admin123

('Bob Manager', 'bob@company.com', 'manager', '$2b$10$zJZtBZHgDRPqkODyxwKMuOaU0XKkztHtHoEiX.Rz5OFLrWhd3WTNi'),     -- admin123

('Catherine Admin', 'cat@company.com', 'superadmin', '$2b$10$zJZtBZHgDRPqkODyxwKMuOaU0XKkztHtHoEiX.Rz5OFLrWhd3WTNi'); -- admin123


-- Insert Seed Data (WITH images)

-- Insert Rooms with Public Images
INSERT INTO rooms (room_id, room_type, price_per_night, label, image_url) VALUES
(4444, 'single', 8000, 'executive', 'https://cdn.pixabay.com/photo/2017/03/28/12/10/bedroom-2189522_960_720.jpg'),
(7777, 'double', 12000, 'deluxe', 'https://images.pexels.com/photos/271639/pexels-photo-271639.jpeg'),
(8888, 'single', 6000, 'regular', 'https://cdn.pixabay.com/photo/2016/11/22/22/18/hotel-1854088_960_720.jpg'),
(9090, 'double', 15000, 'business suite', 'https://images.pexels.com/photos/258154/pexels-photo-258154.jpeg');

-- Insert Spots with Public Images
INSERT INTO spots (spot_id, capacity_range, price, label, image_url) VALUES
('twiga', '1-4', 500, 'family', 'https://cdn.pixabay.com/photo/2018/03/01/14/30/restaurant-3193679_960_720.jpg'),
('kifaru', '5-10', 1000, 'conference', 'https://images.pexels.com/photos/1181406/pexels-photo-1181406.jpeg'),
('nyati', '11-20', 2000, 'friends', 'https://cdn.pixabay.com/photo/2016/11/29/03/53/banquet-1866579_960_720.jpg'),
('simba', '21-50', 5000, 'cooperate', 'https://images.pexels.com/photos/1181407/pexels-photo-1181407.jpeg');

-- Clients
INSERT INTO clients (full_name, email, phone_number) VALUES
('Mwangi Kamau', 'mwangi.kamau@gmail.com', '0712345678'),
('Aisha Mohamed', 'aisha.mohamed@yahoo.com', '0798765432'),
('Otieno Odhiambo', 'otieno.odhiambo@outlook.com', '0723456789'),
('Nafula Wanjiku', 'nafula.wanjiku@gmail.com', '0744567890');

-- Room Bookings
INSERT INTO roomBookings (client_id, room, number_of_nights, checkin_date, booking_status) VALUES
(1, 4444, 3, '2025-04-10', 'confirmed'),
(2, 7777, 2, '2025-04-12', 'pending'),
(3, 8888, 5, '2025-04-14', 'confirmed');

-- Spot Bookings
INSERT INTO spotBookings (client_id, spot, checkin_datetime, meals, booking_status) VALUES
(1, 'twiga', '2025-04-10 18:00:00', 'dinner', 'confirmed'),
(2, 'kifaru', '2025-04-11 12:30:00', 'lunch', 'confirmed');

-- Reviews
INSERT INTO reviews (service_type, service_id, comment, rating) VALUES
('room', 1, 'The room was spacious and clean, excellent service!', 5),
('spot', 1, 'Great venue for family gatherings, loved the ambiance.', 4),
('room', 2, 'Decent stay, but the AC was not working properly.', 3);

-- Payments
INSERT INTO payments (client_id, booking_type, booking_id, amount_paid, payment_method, payment_date) VALUES
(1, 'room', 1, 24000, 'Credit Card', '2025-04-10 09:00:00'),
(2, 'spot', 1, 500, 'M-PESA', '2025-04-11 11:30:00');

-- Room Facilities
INSERT INTO roomFacilities (room_id, facility) VALUES
(4444, 'Air Conditioning'),
(4444, 'Flat Screen TV'),
(7777, 'Mini Bar'),
(8888, 'Free WiFi');

-- Spot Facilities
INSERT INTO spotFacilities (spot_id, facility) VALUES
('twiga', 'Projector'),
('kifaru', 'Sound System'),
('nyati', 'Outdoor Seating');

-- Check-in/Check-out Logs
INSERT INTO checkInCheckOutLogs (booking_type, booking_id, client_id, checkin_time, checkout_time) VALUES
('room', 1, 1, '2025-04-10 14:00:00', '2025-04-13 11:00:00'),
('spot', 1, 1, '2025-04-10 17:30:00', '2025-04-10 21:30:00');

-- Booking Notes
INSERT INTO bookingNotes (booking_type, booking_id, note) VALUES
('room', 1, 'Client requested early check-in.'),
('spot', 1, 'Client requested extra chairs.');



-- more seeding data

-- Insert 20 more Rooms (excluding room_ids 4444, 7777, 8888, 9090)
INSERT INTO rooms (room_id, room_type, price_per_night, label, image_url) VALUES
(1001, 'single', 7000, 'standard', 'https://images.pexels.com/photos/271743/pexels-photo-271743.jpeg'),
(1002, 'double', 13000, 'deluxe', 'https://images.pexels.com/photos/271624/pexels-photo-271624.jpeg'),
(1003, 'single', 7500, 'executive', 'https://images.pexels.com/photos/164595/pexels-photo-164595.jpeg'),
(1004, 'suite', 18000, 'business suite', 'https://images.pexels.com/photos/1571460/pexels-photo-1571460.jpeg'),
(1005, 'double', 11000, 'standard', 'https://images.pexels.com/photos/210265/pexels-photo-210265.jpeg'),
(1006, 'single', 6500, 'regular', 'https://images.pexels.com/photos/164595/pexels-photo-164595.jpeg'),
(1007, 'double', 12500, 'premium', 'https://images.pexels.com/photos/26139/pexels-photo.jpg'),
(1008, 'suite', 19000, 'luxury', 'https://images.pexels.com/photos/271619/pexels-photo-271619.jpeg'),
(1009, 'single', 7200, 'cozy', 'https://images.pexels.com/photos/189296/pexels-photo-189296.jpeg'),
(1010, 'double', 11500, 'deluxe', 'https://images.pexels.com/photos/271624/pexels-photo-271624.jpeg'),
(1011, 'suite', 17000, 'business', 'https://images.pexels.com/photos/271639/pexels-photo-271639.jpeg'),
(1012, 'double', 13500, 'premium', 'https://images.pexels.com/photos/262048/pexels-photo-262048.jpeg'),
(1013, 'single', 6800, 'basic', 'https://images.pexels.com/photos/271639/pexels-photo-271639.jpeg'),
(1014, 'double', 14000, 'deluxe', 'https://images.pexels.com/photos/271639/pexels-photo-271639.jpeg'),
(1015, 'suite', 19500, 'executive suite', 'https://images.pexels.com/photos/1457848/pexels-photo-1457848.jpeg'),
(1016, 'single', 6900, 'compact', 'https://images.pexels.com/photos/271743/pexels-photo-271743.jpeg'),
(1017, 'double', 12500, 'family', 'https://images.pexels.com/photos/2102587/pexels-photo-2102587.jpeg'),
(1018, 'suite', 18500, 'business suite', 'https://images.pexels.com/photos/1571460/pexels-photo-1571460.jpeg'),
(1019, 'double', 13200, 'comfort', 'https://images.pexels.com/photos/261102/pexels-photo-261102.jpeg'),
(1020, 'single', 6700, 'economy', 'https://images.pexels.com/photos/260931/pexels-photo-260931.jpeg');


-- Insert 20 more Spots (excluding spot_ids 'twiga', 'kifaru', 'nyati', 'simba')
INSERT INTO spots (spot_id, capacity_range, price, label, image_url) VALUES
('duma', '1-4', 600, 'family', 'https://images.pexels.com/photos/260922/pexels-photo-260922.jpeg'),
('mbuzi', '5-10', 900, 'friends', 'https://images.pexels.com/photos/262047/pexels-photo-262047.jpeg'),
('tembo', '10-20', 1800, 'cooperate', 'https://images.pexels.com/photos/260922/pexels-photo-260922.jpeg'),
('chui', '15-30', 3000, 'conference', 'https://images.pexels.com/photos/2343468/pexels-photo-2343468.jpeg'),
('ndege', '5-15', 1200, 'business', 'https://images.pexels.com/photos/2062431/pexels-photo-2062431.jpeg'),
('mbuni', '20-50', 5000, 'event', 'https://images.pexels.com/photos/260928/pexels-photo-260928.jpeg'),
('pundamilia', '1-6', 800, 'friends', 'https://images.pexels.com/photos/210558/pexels-photo-210558.jpeg'),
('nyumbu', '2-8', 750, 'team', 'https://images.pexels.com/photos/262047/pexels-photo-262047.jpeg'),
('mbega', '10-25', 2500, 'gathering', 'https://images.pexels.com/photos/1170412/pexels-photo-1170412.jpeg'),
('ngiri', '5-12', 1300, 'family', 'https://images.pexels.com/photos/1662159/pexels-photo-1662159.jpeg'),
('kongoni', '1-4', 550, 'private', 'https://images.pexels.com/photos/2343468/pexels-photo-2343468.jpeg'),
('nyoka', '8-18', 1600, 'workshop', 'https://images.pexels.com/photos/1763075/pexels-photo-1763075.jpeg'),
('kobe', '12-22', 2700, 'conference', 'https://images.pexels.com/photos/1170412/pexels-photo-1170412.jpeg'),
('fisheagle', '3-6', 650, 'intimate', 'https://images.pexels.com/photos/297933/pexels-photo-297933.jpeg'),
('swala', '10-30', 3200, 'training', 'https://images.pexels.com/photos/260922/pexels-photo-260922.jpeg'),
('ndovu', '30-60', 6000, 'seminar', 'https://images.pexels.com/photos/210558/pexels-photo-210558.jpeg'),
('paa', '5-9', 1000, 'friends', 'https://images.pexels.com/photos/1763075/pexels-photo-1763075.jpeg'),
('nyati2', '15-35', 3500, 'cooperate', 'https://images.pexels.com/photos/210558/pexels-photo-210558.jpeg'),
('simba2', '25-50', 4800, 'corporate', 'https://images.pexels.com/photos/260922/pexels-photo-260922.jpeg'),
('kifaru2', '20-40', 5200, 'business', 'https://images.pexels.com/photos/2062431/pexels-photo-2062431.jpeg');





-- joins

SELECT room, number_of_nights, checkin_date, full_name, amount_paid FROM roombookings JOIN clients ON roombookings.client_id = clients.client_id left join payments on roombookings.booking_id = payments.booking_id;



-- check room availability 

SELECT
    r.room_id,
    r.label,
    r.room_type,
    r.price_per_night,
    r.image_url,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM checkInCheckOutLogs log
            JOIN roomBookings rb ON log.booking_id = rb.booking_id
            WHERE log.booking_type = 'room'
              AND log.checkout_time IS NULL
              AND rb.room = r.room_id
        )
        THEN 'Not Available'
        ELSE 'Available'
    END AS availability
FROM rooms r;



-- check spot availability

SELECT
    s.spot_id,
    s.label,
    s.capacity_range,
    s.price,
    s.image_url,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM checkInCheckOutLogs log
            JOIN spotBookings sb ON log.booking_id = sb.booking_id
            WHERE log.booking_type = 'spot'
              AND log.checkout_time IS NULL
              AND sb.spot = s.spot_id
        )
        THEN 'Not Available'
        ELSE 'Available'
    END AS availability
FROM spots s;
