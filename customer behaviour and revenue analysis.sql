-- PROJECT TITLE : CUSTOMER BEHAVIOUR AND REVENUE ANALYSIS

-- DATA CLEANING

CREATE VIEW clean_customer AS 
SELECT DISTINCT
	   customer_id,store_id,
       CONCAT(TRIM(first_name),' ',TRIM(last_name)) AS customer_name
FROM customer;       

SELECT * FROM clean_customer;

CREATE VIEW clean_payment AS 
SELECT DISTINCT
       payment_id,customer_id,rental_id,staff_id,
       payment_date,
       COALESCE(amount,0) AS amount
FROM payment;

CREATE VIEW clean_film AS
SELECT DISTINCT
       film_id,title
FROM film;

CREATE VIEW clean_rental AS
SELECT DISTINCT
       rental_id,inventory_id
FROM rental;

SELECT * FROM  clean_rental;

-- DATA ANALYSIS

CREATE TABLE analysis_data AS
SELECT
	c.customer_id, c.customer_name, 
    p.payment_id, p.payment_date, r.rental_id,
    p.amount AS payment_amount,
    f.title AS film_title,
    cat.name AS category,
    s.store_id,
    a.address,
    ci.city
FROM clean_customer c
JOIN clean_payment p 
    ON c.customer_id = p.customer_id
JOIN clean_rental r 
    ON p.rental_id = r.rental_id
JOIN inventory i 
    ON r.inventory_id = i.inventory_id
JOIN clean_film f 
    ON i.film_id = f.film_id
JOIN film_category fc 
    ON f.film_id = fc.film_id
JOIN category cat 
    ON fc.category_id = cat.category_id
JOIN store s 
    ON i.store_id = s.store_id
JOIN address a 
    ON s.address_id = a.address_id
JOIN city ci 
    ON a.city_id = ci.city_id;


SELECT * FROM analysis_data;


-- KPI METRICS


SELECT SUM(payment_amount) as total_revenue
FROM analysis_data;


SELECT count(rental_id) as total_orders
FROM analysis_data;


SELECT AVG(payment_amount) AS avg_revenue
FROM analysis_data;


-- TOP 5 CUSTOMERS BY REVENUE

SELECT
      customer_name,SUM(payment_amount) AS total_revenue
FROM  analysis_data
GROUP BY customer_name
ORDER BY total_revenue DESC
LIMIT 5;


-- TOP 5 FILMS BY REVENUE

SELECT 
      film_title,SUM(payment_amount)AS total_revenue
FROM  analysis_data
GROUP BY film_title
ORDER BY total_revenue DESC
LIMIT 5 ;


-- STORE PERFORMANCE BY REVENUE

SELECT store_id,city, SUM(payment_amount) AS total_revenue
FROM analysis_data
GROUP BY store_id,city
ORDER BY total_revenue DESC;


-- TOP 5 FILM CATEGORIES  BY REVENUE 

SELECT 
    category,
    total_revenue,
    category_rank
FROM (
    SELECT 
        category,
        SUM(payment_amount) AS total_revenue,
        DENSE_RANK() OVER (ORDER BY SUM(payment_amount) DESC) AS category_rank
    FROM analysis_table_simple
    GROUP BY category
) ranked_categories
WHERE category_rank <= 5;


-- Customer segmentation by  rental activity

SELECT 
    customer_segment,
    COUNT(*) AS number_of_customers
FROM (
    SELECT 
        customer_name,
        CASE 
            WHEN COUNT(rental_id) >= 30 THEN 'Frequent'
            WHEN COUNT(rental_id) BETWEEN 20 AND 29 THEN 'Occasional'
            ELSE 'Low Activity'
        END AS customer_segment
    FROM analysis_table_simple
    GROUP BY customer_name
) customer_segments
GROUP BY customer_segment;






