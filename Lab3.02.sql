USE sakila;

-- 1. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT COUNT(inventory_id) AS Number_of_Copies
FROM sakila.inventory i
INNER JOIN sakila.film f
USING (film_id)
WHERE f.title='Hunchback Impossible';

-- 2. List all films whose length is longer than the average of all the films

SELECT title, length
FROM sakila.film
WHERE length > (
SELECT AVG(length) AS Average_Length
FROM sakila.film)
ORDER BY length DESC;

-- 3. Use subqueries to display all actors who appear in the film Alone Trip

SELECT first_name, last_name
FROM sakila.actor
WHERE actor_id IN (
	SELECT actor_id
	FROM sakila.film_actor
	WHERE film_id IN (
		SELECT film_id
		FROM sakila.film
		WHERE title='Alone Trip'
	)
);

-- 4.  Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films

SELECT title
FROM sakila.film
WHERE film_id IN ( 
	SELECT film_id
	FROM sakila.film_category
	WHERE category_id IN (
		SELECT category_id 
		FROM sakila.category
		WHERE name='Family'
	)
);

SELECT title FROM (
	SELECT film_id 
	FROM sakila.film_category fc
	JOIN sakila.category c
	USING (category_id)
	WHERE c.name='Family'
) sub
JOIN film f
USING (film_id);

-- 5.1 Get name and email from customers from Canada using subqueries

SELECT first_name, last_name, email
FROM sakila.customer
WHERE address_id IN (
	SELECT address_id 
	FROM sakila.address 
    WHERE city_id IN (
		SELECT city_id 
		FROM sakila.city 
		WHERE country_id IN (
			SELECT country_id 
			FROM sakila.country
			WHERE Country='Canada'
		)
	)
);

-- 5.2 Get name and email from customers from Canada using joins. 

SELECT cm.first_name, cm.last_name, cm.email
FROM sakila.country ct
JOIN sakila.city cc
USING(country_id)
JOIN sakila.address a
USING (city_id)
JOIN sakila.customer cm
USING (address_id)
WHERE ct.country='Canada';

-- 6. Which are films starred by the most prolific actor?

SELECT title
FROM sakila.film
WHERE film_id IN (
	SELECT film_id
	FROM sakila.film_actor
	WHERE actor_ID IN (
		SELECT actor_id FROM (
			SELECT actor_id, COUNT(film_id) AS Appearances
			FROM sakila.film_actor
			GROUP BY actor_id
			ORDER BY Appearances DESC
			LIMIT 1
		) sub
	)
);

-- 7. Films rented by most profitable customer

SELECT title
FROM sakila.film
WHERE film_id IN (
	SELECT film_id
	FROM sakila.inventory
	WHERE inventory_id IN (
		SELECT inventory_id
		FROM sakila.rental
		WHERE customer_id IN (
			SELECT customer_id FROM (
				SELECT customer_id, SUM(amount) AS Accumulated
				FROM sakila.payment
				GROUP BY customer_ID
				ORDER BY Accumulated DESC
				LIMIT 1
			) sub
		)
	)
);

-- 8. Customers who spent more than the average payments

SELECT first_name, last_name
FROM sakila.customer
WHERE customer_id IN (
	SELECT customer_id
	FROM ( 
		SELECT customer_id, AVG(amount) AS AVG_Payment_Customer, (SELECT AVG(amount) FROM sakila.payment) AS AVG_Total
		FROM sakila.payment
		GROUP BY customer_id
	) sub
	WHERE AVG_Payment_Customer > AVG_Total
);
