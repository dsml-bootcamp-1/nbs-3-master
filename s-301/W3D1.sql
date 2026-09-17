/* ============================================================
   SQL I  -  Week 2, Day 3
   Database: sqlite-sakila.db  (open it in DB Browser for SQLite)

   SQLite has no schema prefix, so where the slides write
   "sakila.film", here we simply write "film".
   ============================================================ */


/* INTRO */

	SELECT *
	FROM film;

	/* my first sql query select all columns and only first 20 rows */
	SELECT *
	FROM film
	LIMIT 20;

	/*select only some columns */

	SELECT
	title ,
	description ,
	rating
	FROM film;


/* BASIC READ QUERIES */
	/*select the distinct values in a particular column */

	SELECT DISTINCT rental_duration
	FROM film;


	/*... or multiple */

	SELECT DISTINCT rental_duration, language_id
	FROM film;

	/*Check the longest films */

	SELECT title, rental_rate, length
	FROM film
	ORDER BY length DESC;

	/*Check the longest films, tiebreak by most expensive rental */

	SELECT title, rental_rate, length
	FROM film
	ORDER BY length DESC, rental_rate DESC;


	/* Aliasing */
	SELECT title, rental_rate AS cost, length
	FROM film;

	/* Computations */
	SELECT title, rental_rate/length AS price_per_min
	FROM film
	ORDER BY price_per_min ASC;

	/*String Computations */
	/* the slides use CONCAT(). SQLite joins strings with || ,
	   which also works in MySQL and PostgreSQL */

	SELECT title || ', rating:' || rating AS descriptor
	FROM film;

	/* perform a query with a condition */

	SELECT *
	FROM film
	WHERE rental_duration = 6;

	/* plus some variations - swap the WHERE line of the query above */

	SELECT title, rental_duration FROM film WHERE rental_duration > 6;
	SELECT title, rental_duration FROM film WHERE rental_duration >= 6;
	SELECT title, rental_duration FROM film WHERE rental_duration <> 6;
	SELECT title, rental_duration FROM film WHERE rental_duration in (3,4,5,6);

	SELECT title, special_features FROM film WHERE special_features = 'Deleted Scenes';
	SELECT title, special_features FROM film WHERE special_features LIKE '%Deleted Scenes%';
	SELECT title, special_features FROM film WHERE special_features NOT LIKE '%Deleted Scenes%';

	/* Sample aggregations */

	SELECT COUNT(*),MAX(rental_duration),AVG(replacement_cost),AVG(rental_duration)
	FROM film;


	/* Aggregations with group by */
	SELECT rating, COUNT(rating), AVG(rental_rate)
	FROM film
	GROUP BY rating;


	SELECT rating, rental_duration, COUNT(rating), AVG(rental_rate)
	FROM film
	GROUP BY rating, rental_duration;


/* Joins are tomorrow - see s-303/W3D2.sql */
