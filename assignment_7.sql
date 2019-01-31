USE sakila;

-- 1a. Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name FROM actor;
-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT UPPER(CONCAT(first_name," ",last_name)) AS "Actor Name" FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor 
WHERE first_name = "JOE";
-- 2b. Find all actors whose last name contain the letters `GEN`:
SELECT actor_id, first_name, last_name 
FROM actor
WHERE last_name LIKE "%GEN%"; 
-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT last_name,first_name,actor_id 
FROM actor
WHERE last_name LIKE "%LI%"
ORDER BY last_name, first_name; 
-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ("Afghanistan","Bangladesh","China");
-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor
ADD description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor
DROP description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS "count"
FROM actor
GROUP BY last_name;
-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) AS "count"
FROM actor
GROUP BY last_name
HAVING COUNT(last_name)>=2;
-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE actor
SET first_name = "HARPO", last_name = "WILLIAMS"
WHERE first_name="GROUCHO" AND last_name = "WILLIAMS";
-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name="HARPO";
-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE address;
-- Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html](https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT * FROM address;
SELECT * FROM staff;
-- on address_id (staff to address)
SELECT first_name, last_name, address 
FROM staff
LEFT JOIN address ON staff.address_id = address.address_id;
-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT first_name, last_name, SUM(amount)
FROM staff
LEFT JOIN payment ON staff.staff_id = payment.staff_id
WHERE MONTH(payment.payment_date) = 08 AND YEAR(payment.payment_date)=2005
GROUP BY staff.staff_id
-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.

SELECT title, COUNT(actor_id) AS "Actors"
FROM film INNER JOIN film_actor ON film.film_id = film_actor.film_id
GROUP BY film.film_id
ORDER BY Actors DESC;
-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT title,COUNT(inventory_id) AS "Inventory Count"
FROM film LEFT JOIN inventory ON film.film_id = inventory.film_id
GROUP BY film.film_id
HAVING title = "HUNCHBACK IMPOSSIBLE";
-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT first_name, last_name, SUM(amount) AS "Total Amount"
FROM customer LEFT JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY customer.customer_id
ORDER BY customer.last_name;
-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT title
FROM film
WHERE title LIKE "K%"
OR title LIKE "Q%"
AND language_id IN
	(
    SELECT language_id
    FROM language
    WHERE name = "English"
    )
ORDER BY title;
-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name
FROM actor
WHERE actor_id in
	(
		SELECT actor_id
        FROM film_actor
        WHERE film_id =
			(
				SELECT film_id
                FROM film
                WHERE title = "Alone Trip"
			)
	);
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT first_name, last_name, email, country
FROM customer
JOIN address
ON (customer.address_id = address.address_id)
JOIN city
ON (address.city_id = city.city_id)
JOIN country
ON (city.country_id = country.country_id)
WHERE country.country = "canada";
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
SELECT title, name
FROM film
JOIN film_category
ON film.film_id = film_category.film_id
JOIN category
ON category.category_id = film_category.category_id
WHERE name = "family"
-- 7e. Display the most frequently rented movies in descending order.
SELECT title, COUNT(title) AS "Rentals"
FROM film 
JOIN inventory
ON film.film_id = inventory.film_id
JOIN rental
ON inventory.inventory_id = rental.inventory_id
GROUP BY title
ORDER BY rentals DESC;
-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id, SUM(amount)
FROM payment
JOIN rental
ON payment.rental_id = rental.rental_id
JOIN inventory
ON inventory.inventory_id = rental.inventory_id
JOIN store
ON store.store_id = inventory.store_id
GROUP BY store.store_id;
-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country
FROM store
JOIN address
ON store.address_id = address.address_id
JOIN city
ON city.city_id = address.city_id
JOIN country
ON country.country_id = country.country_id;
-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT SUM(amount) AS 'Total Sales', name AS 'Genre'
FROM payment
JOIN rental
ON (payment.rental_id = rental.rental_id)
JOIN inventory
ON (rental.inventory_id = inventory.inventory_id)
JOIN film_category
ON (inventory.film_id = film_category.film_id)
JOIN category
ON (film_category.category_id = category.category_id)
GROUP BY category.name
ORDER BY SUM(amount) DESC;
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres AS
SELECT SUM(amount) AS 'Total Sales', category.name AS 'Genre'
FROM payment
JOIN rental
ON (payment.rental_id = rental.rental_id)
JOIN inventory
ON (rental.inventory_id = inventory.inventory_id)
JOIN film_category
ON (inventory.film_id = film_category.film_id)
JOIN category
ON (film_category.category_id = category.category_id)
GROUP BY category.name
ORDER BY SUM(amount) DESC
LIMIT 5;
-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;
-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_five_genres;
-- * A schema is also available as `sakila_schema.svg`. Open it with a browser to view.

-- ```sql
-- 'actor'
-- 'actor_info'
-- 'address'
-- 'category'
-- 'city'
-- 'country'
-- 'customer'
-- 'customer_list'
-- 'film'
-- 'film_actor'
-- 'film_category'
-- 'film_list'
-- 'film_text'
-- 'inventory'
-- 'language'
-- 'nicer_but_slower_film_list'
-- 'payment'
-- 'rental'
-- 'sales_by_film_category'
-- 'sales_by_store'
-- 'staff'
-- 'staff_list'
-- 'store'
```