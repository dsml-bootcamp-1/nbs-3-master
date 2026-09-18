/* ============================================================
   SQL II  -  Week 2, Day 4
   Database: sqlite-sakila.db  (in s-301, open it in DB Browser for SQLite)

   SQLite has no schema prefix, so where the slides write
   "sakila.film", here we simply write "film".
   ============================================================ */


/* ============================================================
   1. JOINS
   ============================================================ */

	/* bringing tables together -> join them -> one step inner join*/
	/* What is the language of a film?*/
	SELECT
		film.film_id,
	    film.title,
	    language.name
	FROM film INNER JOIN language
		ON film.language_id = language.language_id;

	/* the three tables behind the next query */
	SELECT * FROM actor;
	SELECT * FROM film_actor;
	SELECT * FROM film;

	/* many 2 many relations are well handled by a "bridge" table */
	SELECT
		film.title,
		actor.first_name AS Fname,
		actor.last_name AS Lname,
	    film_actor.film_id

	FROM actor INNER JOIN film_actor
		ON actor.actor_id = film_actor.actor_id
			INNER JOIN film
				ON film.film_id = film_actor.film_id;

	/* INNER JOIN: only the rows that match on BOTH sides */
	SELECT c.first_name, c.last_name, p.amount
	FROM customer AS c INNER JOIN payment AS p
		ON c.customer_id = p.customer_id
	LIMIT 20;

	/* LEFT JOIN: every row of the LEFT table, NULL where there is no match.
	   This is the one you will reach for most - it answers
	   "everything on the left, plus whatever matched". */
	SELECT f.title, i.inventory_id
	FROM film AS f LEFT JOIN inventory AS i
		ON f.film_id = i.film_id
	LIMIT 20;

	/* which films are in NO store? only a LEFT JOIN can show you */
	SELECT f.title
	FROM film AS f LEFT JOIN inventory AS i
		ON f.film_id = i.film_id
	WHERE i.inventory_id IS NULL;

	/* RIGHT JOIN: every row of the RIGHT table. Mirror image of LEFT -
	   swap the table order and a LEFT JOIN does the same job. */
	SELECT f.title, i.inventory_id
	FROM inventory AS i RIGHT JOIN film AS f
		ON f.film_id = i.film_id
	LIMIT 20;

	/* FULL OUTER JOIN: every row from both sides */
	SELECT f.title, i.inventory_id
	FROM film AS f FULL OUTER JOIN inventory AS i
		ON f.film_id = i.film_id
	LIMIT 20;


/* ============================================================
   2. SUB QUERIES
   ============================================================ */

    /*Find the list of actors which starred in movies with
    lengths higher or equal to the average length of all the movies*/
    /*average length of all the movies*/
    SELECT AVG(length) AS average FROM film;

    /*movies with lengths higher or equal to the average length of all the movies*/
    SELECT *
    FROM film
    WHERE length > (SELECT AVG(length) AS average FROM film)
        ORDER BY length DESC;


    /*list of actors which starred in movies with lengths higher
    or equal to the average length of all the movies */

    SELECT
        DISTINCT actor_id
    FROM film_actor INNER JOIN

        (SELECT
            film_id
        FROM film
        WHERE length > (SELECT AVG(length) AS average FROM film)) AS selected_films_id

    ON film_actor.film_id = selected_films_id.film_id;


    /*Name of actors which starred in movies with lengths
    higher or equal to the average length of all the movies*/

    SELECT
        first_name,
        last_name
    FROM actor INNER JOIN
        (
        SELECT DISTINCT actor_id
        FROM film_actor
        INNER JOIN
            (SELECT
                film_id
            FROM film
            WHERE length > (SELECT AVG(length) AS average FROM film)
        ) AS selected_films_id

    ON film_actor.film_id = selected_films_id.film_id) AS selected_actors
    ON actor.actor_id = selected_actors.actor_id;


/* ============================================================
   3. VIEWS
   ============================================================ */

    -- Drop the view if it already exists
    DROP VIEW IF EXISTS actor_categories;

    -- Create a new view
    CREATE VIEW actor_categories AS
    SELECT
        actor.actor_id,
        first_name,
        last_name,
        COUNT(film_id) AS total_films,
        CASE
            WHEN COUNT(film_id) >= 30 THEN 'Star Actor'
            WHEN COUNT(film_id) >= 15 THEN 'Frequent Actor'
            ELSE 'Occasional Actor'
        END AS actor_category
    FROM
        actor
    JOIN
        film_actor ON actor.actor_id = film_actor.actor_id
    GROUP BY
        actor.actor_id
    ORDER BY
        total_films DESC;

    /* a view behaves like a table: query it as usual */
    SELECT actor_id,
        first_name,
        last_name,
        total_films,
        actor_category
    FROM actor_categories;


/* ============================================================
   4. CASE
   ============================================================ */

    SELECT
        actor.actor_id,
        first_name,
        last_name,
        COUNT(film_id) AS total_films,
        CASE
            WHEN COUNT(film_id) >= 30 THEN 'Star Actor'
            WHEN COUNT(film_id) >= 15 THEN 'Frequent Actor'
            ELSE 'Occasional Actor'
        END AS actor_category
    FROM
        actor
    JOIN
        film_actor ON actor.actor_id = film_actor.actor_id
    GROUP BY
        actor.actor_id
    ORDER BY
        total_films DESC;


/* ============================================================
   APPENDIX - not covered in class

   Reference material. Temporary tables are an advanced topic, action
   queries change the database rather than read it, and the string
   functions are a lookup for when you need one.
   ============================================================ */


/* TEMPORARY TABLES */
    /* a query result, saved for the rest of the session.
       SQLite needs "AS SELECT" where MySQL allows a bare "SELECT". */
    DROP TABLE IF EXISTS new_table;

    CREATE TEMPORARY TABLE new_table AS
    SELECT
        first_name,
        last_name
    FROM actor INNER JOIN
        (
        SELECT DISTINCT actor_id
        FROM film_actor
        INNER JOIN
            (SELECT
                film_id
            FROM film
            WHERE length > (SELECT AVG(length) AS average FROM film)
        ) AS selected_films_id

    ON film_actor.film_id = selected_films_id.film_id) AS selected_actors
    ON actor.actor_id = selected_actors.actor_id;


    /* "new_table" has been created */
    /* Now we can use that table in other queries */
    SELECT *
    FROM new_table;


/* ACTION QUERIES */
    /* everything so far has READ data. These change it.
       SQLite has no CREATE DATABASE: the file IS the database. */

    DROP TABLE IF EXISTS example_table;

    CREATE TABLE example_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT
    );

    ALTER TABLE example_table ADD COLUMN age INT;
    INSERT INTO example_table (name, email, age) VALUES ('John Doe', 'john.doe@example.com', 30);
    UPDATE example_table SET email = 'new.email@example.com' WHERE id = 1;
    DELETE FROM example_table WHERE id = 1;

    DROP TABLE IF EXISTS example_table;


/* STRING FUNCTIONS */

    -- Example: Find the length of film titles
    SELECT title, LENGTH(title) AS title_length
    FROM film
    WHERE rental_duration > 5;

    -- Example: Convert film titles to uppercase and lowercase
    SELECT UPPER(title) AS title_upper, LOWER(title) AS title_lower
    FROM film
    LIMIT 10;

    -- Example: Replace 'Amazing' with 'IRONHACK' in film descriptions
    SELECT description, REPLACE(description, 'Amazing', 'IRONHACK') AS new_description
    FROM film;

    -- Example: Concatenate actor's first and last names into a full name
    SELECT first_name || ' ' || last_name AS full_name
    FROM actor
    LIMIT 10;

    -- Example: Extract a part of the film description
    SELECT description, SUBSTR(description, 1, 50) AS snippet
    FROM film
    WHERE film_id = 1;

    -- Example: Concatenate all actor ids for each film.
    -- MySQL writes GROUP_CONCAT(x ORDER BY x SEPARATOR ', '); SQLite takes the separator as a second argument.
    SELECT film_id, GROUP_CONCAT(actor_id, ', ') AS actor_ids
    FROM film_actor
    GROUP BY film_id;
