CREATE DATABASE IF NOT EXISTS hotel_bookings_db;
USE hotel_bookings_db;
DROP TABLE IF EXISTS hotel_bookings;

CREATE TABLE hotel_bookings (
    hotel VARCHAR(50),
    is_canceled INT,
    lead_time INT,
    arrival_date_year INT,
    arrival_date_month VARCHAR(20),
    arrival_date_week_number INT,
    arrival_date_day_of_month INT,
    stays_in_weekend_nights INT,
    stays_in_week_nights INT,
    adults INT,
    children VARCHAR(10),       -- Changed to VARCHAR to handle blank/NA values
    babies INT,
    meal VARCHAR(20),
    country VARCHAR(10),
    market_segment VARCHAR(50),
    distribution_channel VARCHAR(50),
    is_repeated_guest INT,
    previous_cancellations INT,
    previous_bookings_not_canceled INT,
    reserved_room_type VARCHAR(5),
    assigned_room_type VARCHAR(5),
    booking_changes INT,
    deposit_type VARCHAR(30),
    agent VARCHAR(20),          -- Changed to VARCHAR to handle NULLs
    company VARCHAR(20),        -- Changed to VARCHAR to handle NULLs
    days_in_waiting_list INT,
    customer_type VARCHAR(30),
    adr DECIMAL(10,2),          -- Handles the negative and 5400 max values
    required_car_parking_spaces INT,
    total_of_special_requests INT,
    reservation_status VARCHAR(20),
    reservation_status_date DATE
);

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/Users/user/Downloads/hotel_booking/hotel_bookings.csv' 
INTO TABLE hotel_bookings 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

-- 119,390 rows
SELECT COUNT(*) FROM hotel_bookings;

-- Check the first few rows to ensure data mapped correctly
SELECT * FROM hotel_bookings LIMIT 5;