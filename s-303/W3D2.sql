/* ============================================================
   JOINS  -  moved here from s-301/W3D1.sql
   The slide deck teaches the join types at the end of SQL day one,
   but both join labs run on day two, so they are taught together here.
   Already adapted for SQLite: no "sakila." prefix.
   NOTE: the rest of this file still carries the sakila. prefix and is
   adapted when Day 4 is rebuilt.
   ============================================================ */

/* JOIN */
	/* bringing tables together -> join them -> one step inner join*/
	/* What is the language of a film?*/
	SELECT
		film.film_id,
	    film.title,
	    language.name
	FROM film INNER JOIN language
		ON film.language_id = language.language_id;

	/* bringing tables together -> join them -> 2 step inner join*/
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


/* SUB QUERIES */
    /*Find the list of actors which starred in movies with 
    lengths higher or equal to the average length of all the movies*/
    /*average length of all the movies*/
    SELECT AVG(length) AS average FROM sakila.film;

    /*movies with lengths higher or equal to the average length of all the movies*/
    SELECT * 
    FROM sakila.film 
    WHERE length > (SELECT AVG(length) AS average FROM sakila.film)
        ORDER BY length DESC;


    /*list of actors which starred in movies with lengths higher 
    or equal to the average length of all the movies */

    USE sakila;
    SELECT 
        DISTINCT actor_id 
    FROM sakila.film_actor INNER JOIN 

        (SELECT 
            film_id 
        FROM sakila.film 
        WHERE length > (SELECT AVG(length) AS average FROM film)) AS selected_films_id
        
    ON sakila.film_actor.film_id = selected_films_id.film_id;


    /*Name of actors which starred in movies with lengths
    higher or equal to the average length of all the movies*/

    SELECT 
        first_name, 
        last_name
    FROM sakila.actor INNER JOIN 
        (
        SELECT DISTINCT actor_id 
        FROM sakila.film_actor
        INNER JOIN 
            (SELECT 
                film_id 
            FROM sakila.film 
            WHERE length > (SELECT AVG(length) AS average FROM film)
        ) AS selected_films_id

    ON sakila.film_actor.film_id = selected_films_id.film_id) AS selected_actors
    ON sakila.actor.actor_id = selected_actors.actor_id;

/* TEMPORARY TABLES */
    /* Now this new table can be used as a Temp -> ADVANCED TOPIC */
    CREATE TEMPORARY TABLE sakila.new_table
    SELECT 
        first_name, 
        last_name
    FROM sakila.actor INNER JOIN 
        (
        SELECT DISTINCT actor_id 
        FROM sakila.film_actor
        INNER JOIN 
            (SELECT 
                film_id 
            FROM sakila.film 
            WHERE length > (SELECT AVG(length) AS average FROM film)
        ) AS selected_films_id

    ON sakila.film_actor.film_id = selected_films_id.film_id) AS selected_actors
    ON sakila.actor.actor_id = selected_actors.actor_id;


    /* "new_table" has been created */
    /* Now we can use that table in other queries */
    SELECT *
    FROM sakila.new_table;

/* VIEWS */
    USE sakila;
    -- Drop the view if it already exists
    DROP VIEW IF EXISTS actor_categories;

    -- Create a new view
    CREATE VIEW actor_categories AS
    SELECT 
        actor_id,
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
        actor_id
    ORDER BY 
        total_films DESC;

    SELECT `actor_categories`.`actor_id`,
        `actor_categories`.`first_name`,
        `actor_categories`.`last_name`,
        `actor_categories`.`total_films`,
        `actor_categories`.`actor_category`
    FROM `sakila`.`actor_categories`;



/* ACTION QUERIES */

    CREATE DATABASE IF NOT EXISTS temp_sakila;
    USE temp_sakila;
    CREATE TABLE example_table (
        id INT AUTO_INCREMENT PRIMARY KEYå,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255)
    );

    ALTER TABLE example_table ADD COLUMN age INT;
    INSERT INTO example_table (name, email, age) VALUES ('John Doe', 'john.doe@example.com', 30);
    UPDATE example_table SET email = 'new.email@example.com' WHERE id = 1;


    DROP TABLE IF EXISTS example_table;
    DROP DATABASE IF EXISTS temp_sakila;




/* Advance Queries */
    /* CASE STATEMENT */
    USE sakila;
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
        actor_id
    ORDER BY 
        total_films DESC;

    
    -- STRINGS
    -- Example: Find the length of film titles
    SELECT title, LENGTH(title) AS title_length
    FROM film
    WHERE rental_duration > 5;

    -- Example: Convert film titles to uppercase and lowercase
    SELECT UPPER(title) AS title_upper, LOWER(title) AS title_lower
    FROM film
    LIMIT 10;

    -- Example: Replace 'Trail' with 'Path' in film descriptions
    SELECT description, REPLACE(description, 'Amazing', 'IRONHACK') AS new_description
    FROM film

    -- Example: Concatenate actor's first and last names into a full name
    SELECT CONCAT(first_name, ' ', last_name) AS full_name
    FROM actor
    LIMIT 10;

    -- Example: Extract a part of the film description
    SELECT description, SUBSTRING(description, 1, 50) AS snippet
    FROM film
    WHERE film_id = 1;

    -- Example: Concatenate all actor names for each film
    SELECT film_id, GROUP_CONCAT(actor_id ORDER BY actor_id SEPARATOR ', ') AS actor_ids
    FROM film_actor
    GROUP BY film_id;
