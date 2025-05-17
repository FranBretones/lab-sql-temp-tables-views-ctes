-- Creating a Customer Summary Report
	/*In this exercise, you will create a customer summary report that summarizes key information about customers in the Sakila database, 
    including their rental history and payment details. The report will be generated using a combination of views, CTEs, and temporary tables.*/
	
/*Step 1: Create a View
First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).*/

CREATE OR REPLACE VIEW v_rental_customer AS 
SELECT 
    c.customer_id,
    c.first_name AS name, 
    c.email,
    COUNT(r.rental_id) AS total_rent
FROM customer c 
LEFT JOIN rental r 
    ON c.customer_id = r.customer_id
GROUP BY 
    c.customer_id, c.first_name, c.email;

/*Step 2: Create a Temporary Table
Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.*/

CREATE TEMPORARY TABLE temp_customer_payments AS
SELECT 
    p.customer_id,
    v.name,
    v.email,
    v.total_rent,
    SUM(p.amount) AS total_paid
FROM payment p
JOIN v_rental_customer v
    ON p.customer_id = v.customer_id
GROUP BY 
    p.customer_id, v.name, v.email, v.total_rent;

/*Step 3: Create a CTE and the Customer Summary Report
Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
The CTE should include the customer's name, email address, rental count, and total amount paid.*/

WITH cte_customer_summary AS (
    SELECT
        v.customer_id,
        v.name,
        v.email,
        v.total_rent,
        t.total_paid
    FROM v_rental_customer v
    JOIN temp_customer_payments t
        ON v.customer_id = t.customer_id
)
/* Next, using the CTE, create the query to generate the final customer summary report, 
which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.*/

SELECT
    name,
    email,
    total_rent AS rental_count,
    total_paid,
    ROUND(
        CASE 
            WHEN total_rent > 0 THEN total_paid / total_rent
            ELSE 0
        END, 2
    ) AS average_payment_per_rental
FROM cte_customer_summary
ORDER BY total_paid DESC;

