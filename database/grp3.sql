-------------------------29 queries--------------------------------
1. Customers who booked more than 3 times and spent above average revenue
SELECT customer_id, COUNT(*) AS total_bookings, SUM(booking_revenue) AS total_spent
FROM bookings
GROUP BY customer_id
HAVING COUNT(*) > 3
AND SUM(booking_revenue) > (SELECT AVG(booking_revenue) FROM bookings);


2. Customers who never cancelled a booking
SELECT c.customer_id, c.first_name
FROM customers c
WHERE c.customer_id NOT IN (
    SELECT customer_id FROM cancellations
);

3. Top 5 customers by total revenue
SELECT customer_id, SUM(booking_revenue) AS total_revenue
FROM bookings
GROUP BY customer_id
ORDER BY total_revenue DESC
LIMIT 5;


4. Customers with highest average hotel rating given
SELECT customer_id, AVG(hotel_rating) AS avg_rating
FROM reviews
GROUP BY customer_id
ORDER BY avg_rating DESC;

5. Customers who booked luxury hotels only
SELECT DISTINCT b.customer_id
FROM bookings b
JOIN hotels h ON b.hotel_id = h.hotel_id
WHERE h.star_rating >= 4.5;

6. Hotels with occupancy rate above average and revenue above average
SELECT *
FROM hotels
WHERE occupancy_rate > (SELECT AVG(occupancy_rate) FROM hotels)
AND hotel_revenue > (SELECT AVG(hotel_revenue) FROM hotels);

7. Hotels with highest cancellation rate
SELECT hotel_id, 
COUNT(*) FILTER (WHERE booking_status = 'Cancelled') * 100.0 / COUNT(*) AS cancellation_rate
FROM bookings
GROUP BY hotel_id
ORDER BY cancellation_rate DESC;

8. Hotels with more than 80% occupancy AND high customer rating
SELECT *
FROM hotels
WHERE occupancy_rate > 80
AND customer_rating > 4;

9. Top 3 hotels in each city
SELECT *
FROM (
    SELECT hotel_name, city, customer_rating,
    RANK() OVER (PARTITION BY city ORDER BY customer_rating DESC) AS rnk
    FROM hotels
) t
WHERE rnk <= 3;

10. Hotels where revenue is higher than competitor average
SELECT *
FROM hotels h
WHERE hotel_revenue > (
    SELECT AVG(competitor_price)
    FROM pricing p
    WHERE p.hotel_id = h.hotel_id
);


11. Total revenue generated per payment method
SELECT payment_method, SUM(payment_amount)
FROM payment
GROUP BY payment_method;

12. Failed payments count per customer
SELECT b.customer_id, COUNT(*)
FROM payment p
JOIN bookings b ON p.booking_id = b.booking_id
WHERE p.payment_status = 'Pending'
GROUP BY b.customer_id;

select * from payment

13. High-value bookings with successful payments only
SELECT *
FROM bookings b
JOIN payment p ON b.booking_id = p.booking_id
WHERE p.payment_status = 'Paid'
AND b.booking_revenue > 10000;

14. Average transaction fee per payment method
SELECT payment_method, AVG(transaction_fee)
FROM payment
GROUP BY payment_method;

15. Monthly revenue trend
SELECT DATE_TRUNC('month', payment_date) AS month,
SUM(payment_amount) AS revenue
FROM payment
GROUP BY month
ORDER BY month;


16. Cancellation rate per hotel
SELECT hotel_id,
COUNT(*) FILTER (WHERE booking_status='Cancelled') * 100.0 / COUNT(*) AS cancel_rate
FROM bookings
GROUP BY hotel_id;


17. Most common cancellation reasons
SELECT cancellation_reason, COUNT(*)
FROM cancellations
GROUP BY cancellation_reason
ORDER BY COUNT(*) DESC;


18. Refund pending cases
SELECT *
FROM cancellations
WHERE refund_status = 'Pending';


19. High refund amount cancellations
SELECT *
FROM cancellations
WHERE refund_amount > 5000;


20. Cancellation source-wise analysis
SELECT cancellation_source, COUNT(*)
FROM cancellations
GROUP BY cancellation_source;



21. Hotels with best average rating
SELECT booking_id,
AVG(hotel_rating + service_rating + cleanliness_rating + food_rating)/4 AS avg_score
FROM reviews
GROUP BY booking_id
ORDER BY avg_score DESC;


22. Customers who gave low ratings (<3)
SELECT DISTINCT customer_id
FROM reviews
WHERE hotel_rating < 3;


23. Negative reviews with long text
SELECT *
FROM reviews
WHERE hotel_rating <= 2
AND LENGTH(review_text) > 100;


24. Hotels with most positive reviews
SELECT booking_id, COUNT(*) AS positive_reviews
FROM reviews
WHERE hotel_rating >= 4
GROUP BY booking_id
ORDER BY positive_reviews DESC;


25. Customer lifetime value (CLV)
SELECT customer_id, SUM(booking_revenue) AS CLV
FROM bookings
GROUP BY customer_id;


26. High spending customers who never cancelled
SELECT customer_id, SUM(booking_revenue)
FROM bookings
WHERE customer_id NOT IN (SELECT customer_id FROM cancellations)
GROUP BY customer_id;


27. Hotels with high demand and availability
SELECT *
FROM rooms
WHERE availability_status = 'available'
AND base_price > 5000;


28. Seasonal pricing vs occupancy correlation
SELECT p.season, AVG(p.seasonal_price), AVG(o.occupancy_rate)
FROM pricing p
JOIN hotels o ON p.hotel_id = o.hotel_id
GROUP BY p.season;

29. hotel performance score 
WITH revenue_data AS (
    SELECT hotel_id, SUM(booking_revenue) AS total_revenue
    FROM bookings
    GROUP BY hotel_id
),
rating_data AS (
    SELECT b.hotel_id, AVG(r.hotel_rating) AS avg_rating
    FROM bookings b
    LEFT JOIN reviews r ON b.booking_id = r.booking_id
    GROUP BY b.hotel_id
),
occupancy_data AS (
    SELECT hotel_id, AVG(occupancy_rate) AS occupancy
    FROM hotels
    GROUP BY hotel_id
)

SELECT 
    h.hotel_id,
    rd.total_revenue,
    rat.avg_rating,
    od.occupancy
FROM hotels h
LEFT JOIN revenue_data rd ON h.hotel_id = rd.hotel_id
LEFT JOIN rating_data rat ON h.hotel_id = rat.hotel_id
LEFT JOIN occupancy_data od ON h.hotel_id = od.hotel_id;

