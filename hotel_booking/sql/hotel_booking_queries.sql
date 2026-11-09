-- Cancellation rate
SELECT
COUNT(*) AS total_bookings,
SUM(is_canceled) AS total_cancellations,
ROUND(AVG(is_canceled) * 100, 2) AS overall_cancel_rate_pct
FROM hotel_bookings;
-- leadig time calculations
SELECT
 CASE
        WHEN lead_time = 0 THEN '1. Same Day'
        WHEN lead_time BETWEEN 1 AND 30 THEN '2. 1-30 Days'
        WHEN lead_time BETWEEN 31 AND 90 THEN '3. 31-90 Days'
        WHEN lead_time BETWEEN 91 AND 180 THEN '4. 91-180 Days'
        WHEN lead_time BETWEEN 181 AND 365 THEN '5. 181-365 Days'
        ELSE '6. 365+ Days'
    END AS lead_time_bucket,
    COUNT(*) AS total_bookings,
    SUM(is_canceled) AS cancellations,
    ROUND(AVG(is_canceled) * 100, 2) AS cancel_rate_pct
FROM hotel_bookings
GROUP BY lead_time_bucket
ORDER BY MIN(lead_time);

-- Cancel Rate by Deposit Type
SELECT 
    deposit_type,
    COUNT(*) AS total_bookings,
    ROUND(AVG(is_canceled) * 100, 2) AS cancel_rate_pct
FROM hotel_bookings
GROUP BY deposit_type;

-- Cancel Rate by Market Segment
SELECT 
    market_segment,
    COUNT(*) AS total_bookings,
    ROUND(AVG(is_canceled) * 100, 2) AS cancel_rate_pct
FROM hotel_bookings
GROUP BY market_segment
ORDER BY cancel_rate_pct DESC;

-- The "Repeat Offender" Effect (Previous Cancellations)
SELECT 
    CASE 
        WHEN previous_cancellations = 0 THEN 'No prior cancellations'
        WHEN previous_cancellations = 1 THEN '1 prior cancellation'
        ELSE '2+ prior cancellations'
    END AS prior_cancel_history,
    COUNT(*) AS total_bookings,
    ROUND(AVG(is_canceled) * 100, 2) AS cancel_rate_pct
FROM hotel_bookings
GROUP BY prior_cancel_history
ORDER BY MIN(previous_cancellations);

--  Cancellation Rate: Direct vs Agent vs Company
SELECT 
    CASE 
        WHEN agent IS NULL THEN 'Direct Booking'
        ELSE 'Travel Agent'
    END AS booking_source,
    COUNT(*) AS total_bookings,
    ROUND(AVG(is_canceled) * 100, 2) AS cancel_rate_pct,
    ROUND(AVG(lead_time), 0) AS avg_lead_time_days
FROM hotel_bookings
GROUP BY booking_source;

SELECT 
    CASE 
        WHEN company IS NULL THEN 'No Company'
        ELSE 'Corporate Booking'
    END AS booking_source,
    COUNT(*) AS total_bookings,
    ROUND(AVG(is_canceled) * 100, 2) AS cancel_rate_pct,
    ROUND(AVG(lead_time), 0) AS avg_lead_time_days
FROM hotel_bookings
GROUP BY booking_source;

--  Top 10 Agents by Cancellation Rate (Min 500 bookings)
SELECT 
    agent,
    COUNT(*) AS total_bookings,
    ROUND(AVG(lead_time), 0) AS avg_lead_time_days,
    ROUND(AVG(is_canceled) * 100, 2) AS cancel_rate_pct
FROM hotel_bookings
WHERE agent IS NOT NULL
GROUP BY agent
HAVING COUNT(*) > 500
ORDER BY cancel_rate_pct DESC
LIMIT 10;

-- Agent Cancel Rate by Lead Time Bucket
SELECT 
    CASE 
        WHEN agent IS NULL THEN 'Direct Booking'
        ELSE 'Travel Agent'
    END AS booking_source,
    CASE
        WHEN lead_time <= 30 THEN 'Short (0-30 Days)'
        WHEN lead_time BETWEEN 31 AND 90 THEN 'Medium (31-90 Days)'
        ELSE 'Long (90+ Days)'
    END AS lead_time_bucket,
    COUNT(*) AS total_bookings,
    ROUND(AVG(is_canceled) * 100, 2) AS cancel_rate_pct
FROM hotel_bookings
GROUP BY booking_source, lead_time_bucket
ORDER BY booking_source, MIN(lead_time);

SELECT 
    CASE WHEN agent IS NULL THEN 'Direct' ELSE 'Agent' END AS source,
    previous_cancellations,
    COUNT(*) AS users,
    ROUND(AVG(is_canceled) * 100, 2) AS cancel_rate
FROM hotel_bookings
WHERE previous_cancellations > 0
GROUP BY source, previous_cancellations
ORDER BY source, previous_cancellations;

-- Total Revenue Lost to Cancellations
SELECT 
    COUNT(*) AS total_cancellations,
    ROUND(SUM(adr * (stays_in_weekend_nights + stays_in_week_nights)), 2) AS estimated_revenue_lost
FROM hotel_bookings
WHERE is_canceled = 1 
  AND adr > 0; -- We filter out the negative ADR errors in the dataset


-- Average Lead Time by Market Segment
SELECT 
    market_segment,
    COUNT(*) AS total_bookings,
    ROUND(AVG(lead_time), 0) AS avg_lead_time_days,
    ROUND(AVG(is_canceled) * 100, 2) AS cancel_rate_pct
FROM hotel_bookings
GROUP BY market_segment
ORDER BY avg_lead_time_days DESC;

--  Average Lead Time by Country (Top 10 by volume)
SELECT 
    country,
    COUNT(*) AS total_bookings,
    ROUND(AVG(lead_time), 0) AS avg_lead_time_days,
    ROUND(AVG(is_canceled) * 100, 2) AS cancel_rate_pct
FROM hotel_bookings
GROUP BY country
HAVING COUNT(*) > 1000 -- Only look at countries with significant volume
ORDER BY avg_lead_time_days DESC
LIMIT 10;


SELECT 
    is_canceled,
    lead_time,
    deposit_type,
    market_segment,
    CASE WHEN agent IS NULL THEN 'Direct' ELSE 'Agent' END AS booking_source,
    previous_cancellations
FROM hotel_bookings;