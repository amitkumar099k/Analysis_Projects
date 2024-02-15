USE imdb;

-- Segment 1:

-- Examining the entries within each table of the schema.

SELECT 
    table_name, 
    table_rows
FROM
    INFORMATION_SCHEMA.tables
WHERE
    TABLE_SCHEMA = 'imdb';


-- Verifying for the presence of null values.


SELECT 
    SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS ID,
    SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS title,
    SUM(CASE WHEN year IS NULL THEN 1 ELSE 0 END) AS year_,
    SUM(CASE WHEN date_published IS NULL THEN 1 ELSE 0 END) AS date_published,
    SUM(CASE WHEN duration IS NULL THEN 1 ELSE 0 END) AS duration,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country,
    SUM(CASE WHEN worlwide_gross_income IS NULL THEN 1 ELSE 0 END) AS worlwide_gross_income,
    SUM(CASE WHEN languages IS NULL THEN 1 ELSE 0 END) AS languages,
    SUM(CASE WHEN production_company IS NULL THEN 1 ELSE 0 END) AS production_company
FROM
    movie;
    
-- Columns containing null values include (country, worldwide gross income, languages, production company).


-- Counting the yearly release of movies.
SELECT 
    year, 
    COUNT(title) AS number_of_movies
FROM movie
GROUP BY year;

-- Monthly trend analysis of the overall movie count.

SELECT 
    MONTH(date_published) AS month_num,
    COUNT(title) AS number_of_movies
FROM movie
GROUP BY month_num
ORDER BY month_num;

/*The highest number of movies is produced in the month of March.
USA and India produces huge number of movies each year.*/
  
-- Verifying the count of movies produced in the USA or India in 2019.

SELECT 
    COUNT(DISTINCT id) AS number_of_movies, 
    year
FROM movie
WHERE (country LIKE '%INDIA%'
        OR country LIKE '%USA%')
        AND year = 2019; 
        
-- The combined number of movies produced by the USA and India is 1059.

/* USA and India produced more than a thousand movies in the year 2019.

-- Confirming the unique list of genres within the dataset.

SELECT DISTINCT genre
FROM genre;


-- Confirming which genre had the highest number of movies produced overall.

SELECT 
    genre, 
    COUNT(m.id) AS Overall_movie_count
FROM
    movie AS m
        INNER JOIN
    genre AS g ON m.id = g.movie_id
GROUP BY genre
ORDER BY Overall_movie_count DESC
LIMIT 1;

-- A total of 4265 movies fall under the Drama genre, making it the highest among all genres.


-- Verifying the count of movies belonging to only one genre.

WITH one_genre_movies AS
(
	SELECT movie_id , COUNT(genre) AS genre_count
	FROM genre
	GROUP BY movie_id
	HAVING COUNT(genre) = 1
)
SELECT 
	COUNT(*) AS Single_genre_movie 
FROM 
	one_genre_movies;

-- A total of 3289 movies are categorized under only one genre.


/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant.*/

-- Verifying the average duration of movies in each genre.

SELECT 
    genre, 
    ROUND(AVG(duration), 2) AS avg_duration
FROM
    movie AS m
        INNER JOIN
    genre AS g ON m.id = g.movie_id
GROUP BY genre
ORDER BY AVG(duration) DESC;
    

-- Now we know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.

-- Determining the rank of the 'thriller' genre among all genres based on the number of movies produced.

SELECT 
	genre , 
    count(movie_id) AS movie_count, 
    RANK() OVER(ORDER BY count(movie_id) DESC) AS genre_rank
FROM genre
GROUP BY genre;

-- 'Thriller' genre is ranked 3rd in total movie production among all genres.

/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.*/




-- Segment 2:




-- Finding the minimum and maximum values in each column of the ratings table.

SELECT 
    MIN(avg_rating) AS min_avg_rating,
    MAX(avg_rating) AS max_avg_rating,
    MIN(total_votes) AS min_total_votes,
    MAX(total_votes) AS max_total_votes,
    MIN(median_rating) AS min_median_rating,
    MAX(median_rating) AS max_median_rating
FROM
    ratings;


/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table.*/

-- Listing the top 10 movies based on average rating.

WITH top_10 AS 
(
	SELECT 
		title, 
        avg_rating ,
		ROW_NUMBER() OVER(ORDER BY avg_rating DESC) AS movie_rank
	FROM movie m
		INNER JOIN 
        ratings AS r ON m.id = r.movie_id
) 
SELECT * 
FROM top_10
WHERE movie_rank <= 10;


-- The top 10 movies with an average rating of 9.6 .

-- Summarizing the ratings table based on the count of movies by median ratings.

SELECT 
    median_rating, 
    COUNT(movie_id) AS movie_count
FROM ratings
GROUP BY median_rating
ORDER BY median_rating;
    

/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Verifying which production house has produced the most number of hit movies (average rating > 8).

WITH hit_movies_by_production_house AS 
(
	SELECT
		production_company,
		count(movie_id) AS movie_count,
		RANK() OVER( ORDER BY count(movie_id) DESC) AS prod_company_rank
	FROM movie AS m
		INNER JOIN 
    ratings AS r ON m.id = r.movie_id
	WHERE avg_rating > 8 AND production_company IS NOT NULL
	GROUP BY production_company
)
SELECT 
	* 
FROM hit_movies_by_production_house
WHERE prod_company_rank =1;


-- Dream Warrior Pictures and National Theatre Live has produced the most number of hit movies.

-- Determining the number of movies released in each genre during March 2017 in the USA that received more than 1,000 votes.

SELECT 
    genre, 
    COUNT(title) AS movie_count
FROM
    movie AS m
        INNER JOIN
    ratings AS r ON m.id = r.movie_id
        INNER JOIN
    genre AS g ON m.id = g.movie_id
WHERE
    MONTH(date_published) = 03
        AND year = 2017
        AND country LIKE '%USA%'
        AND total_votes > 1000
GROUP BY genre;

-- Identifying movies in each genre that start with the word 'The' and have an average rating > 8.

SELECT 
    title, 
    avg_rating, 
    genre
FROM
    movie AS m
        INNER JOIN
    ratings AS r ON m.id = r.movie_id
        INNER JOIN
    genre AS g ON m.id = g.movie_id
WHERE
    title LIKE 'The%' AND avg_rating > 8;



-- Verifying the number of movies released between April 1, 2018, and April 1, 2019, that were given a median rating of 8.

SELECT 
    title
FROM
    movie AS m
        INNER JOIN
    ratings AS r ON m.id = r.movie_id
WHERE
    median_rating = 8
        AND DATE_FORMAT(date_published, '%Y-%m-%d') BETWEEN '2018-04-01' AND '2019-04-01';


-- Verifying if German movies receive more votes than Italian movies.

WITH german_votes AS 
(
	SELECT 
		sum(total_votes) AS German_Total_votes,
		RANK() OVER(ORDER BY sum(total_votes)) AS ranks
	FROM
		movie AS m
			INNER JOIN
		ratings AS r ON m.id = r.movie_id
	WHERE languages LIKE '%german%' 
),
italian_votes AS 
(
	SELECT 
		SUM(total_votes) AS Italian_Total_votes,
		RANK() OVER(ORDER BY sum(total_votes)) AS ranks
	FROM movie AS m
		INNER JOIN 
	ratings AS r ON m.id=r.movie_id
	WHERE languages LIKE '%Italian%'
) 
SELECT 
	Italian_total_votes,
    German_total_votes,
	CASE
		WHEN german_total_votes > italian_total_votes THEN 'German' ELSE 'Italian' 
        END AS 'Popular_movie'
FROM italian_votes
		INNER JOIN 
	german_votes USING (ranks);


-- German movies receive more votes than Italian movies.


-- Segment 3:



-- Verifying which columns in the names table have null values.

SELECT 
    COUNT(*)-COUNT(name) AS name_nulls,
    COUNT(*)-COUNT(height) AS height_nulls,
    COUNT(*)-COUNT(date_of_birth) AS date_of_birth_nulls,
    COUNT(*)-COUNT(known_for_movies) AS known_for_movies_nulls
FROM
    names; 


--There are no Null value in the column 'name'.



-- Identifying the top three directors in the top three genres whose movies have an average rating > 8.

WITH top_3_genres AS
(
    SELECT 
        g.genre,
        COUNT(m.id) AS movie_count,
        RANK() OVER (ORDER BY COUNT(m.id) DESC) AS genre_rank
    FROM movie AS m
		INNER JOIN 
    genre AS g ON g.movie_id = m.id
		INNER JOIN 
    ratings AS r ON r.movie_id = m.id 
    WHERE r.avg_rating > 8
    GROUP BY g.genre 
    ORDER BY movie_count DESC
    LIMIT 3 
)
SELECT
    n.name AS director_name,
    COUNT(dm.movie_id) AS movie_count
FROM director_mapping AS dm
	INNER JOIN 
genre AS g ON dm.movie_id = g.movie_id
	INNER JOIN 
names AS n ON n.id = dm.name_id
	INNER JOIN 
top_3_genres AS t3g ON g.genre = t3g.genre
	INNER JOIN 
ratings AS r ON r.movie_id = dm.movie_id 
WHERE r.avg_rating > 8
GROUP BY n.name
ORDER BY movie_count DESC
LIMIT 3;

-- James Mangold can be hired as the director for RSVP's next project.


-- Determining the top two actors whose movies have a median rating >= 8.

SELECT 
    name AS actor_name, 
    COUNT(r.movie_id) AS movie_count
FROM role_mapping AS r_m
       INNER JOIN 
	movie AS m ON M.id = r_m.movie_id
       INNER JOIN 
	ratings AS r USING(movie_id)
       INNER JOIN 
	names AS n ON n.id = r_m.name_id
WHERE
    median_rating >= 8 AND category = 'ACTOR'
GROUP BY actor_name
ORDER BY movie_count DESC
LIMIT 2;

-- Mammootty and Mohanlal are the actors whose films maintain a median rating of 8 or higher.

/* RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/


-- Identifying the top three production houses based on the number of votes received by their movies.

SELECT 
    production_company, 
    SUM(total_votes) AS vote_count , 
    RANK() OVER (order by SUM(total_votes) DESC) AS prod_comp_rank
FROM
    movie AS m
        INNER JOIN
    ratings AS r ON m.id = r.movie_id
WHERE
    production_company IS NOT NULL
GROUP BY production_company
LIMIT 3;


-- Marvel Studios has the highest number of votes."


/* Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel.*/


/* Ranking actors with movies released in India based on their average ratings. 
The actor at the top of the list have appeared in at least five Indian movies.*/

SELECT 
    name AS actor_name,
    SUM(total_votes) AS total_votes,
    COUNT(m.id) AS movie_count,
    ROUND(SUM(avg_rating * total_votes) / SUM(total_votes),2) AS actor_avg_rating,
    RANK() OVER(ORDER BY  ROUND(SUM(avg_rating*total_votes)/SUM(total_votes),2) DESC) AS actor_rank		
FROM
    movie AS m
        INNER JOIN
    ratings AS r ON m.id = r.movie_id
        INNER JOIN
    role_mapping AS rm ON m.id = rm.movie_id
        INNER JOIN
    names AS nm ON rm.name_id = nm.id
WHERE
    category = 'actor' AND country = 'India'
GROUP BY name
HAVING movie_count >= 5
LIMIT 1;

-- Top actor is Vijay Sethupathi


/* Ranking the top five actresses in Hindi movies released in India based on their average ratings.
The actresses have appeared in at least three Indian movies.*/

SELECT 
    name AS actress_name,
    SUM(total_votes) AS total_votes,
    COUNT(m.id) AS movie_count,
    ROUND(SUM(avg_rating * total_votes) / SUM(total_votes),2) AS actor_avg_rating,
	RANK() OVER(ORDER BY  ROUND(SUM(avg_rating*total_votes)/SUM(total_votes),2) DESC) AS actress_rank 
FROM
    movie AS m
        INNER JOIN
    ratings AS r ON m.id = r.movie_id
        INNER JOIN
    role_mapping AS rm ON m.id = rm.movie_id
        INNER JOIN
    names AS nm ON rm.name_id = nm.id
WHERE
    category = 'Actress'
        AND country like '%India%'
        AND languages like '%Hindi%'
GROUP BY name 
HAVING movie_count >=3
LIMIT 5;


/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Ranking thriller movies based on their average rating and categorizing them as follows:

Rating > 8: Superhit movies
Rating between 7 and 8: Hit movies
Rating between 5 and 7: One-time-watch movies
Rating < 5: Flop movies */


SELECT DISTINCT
    title,
    CASE
        WHEN avg_rating > 8 THEN 'Superhit movies'
        WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
        WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
        ELSE 'Flop movies'
    END AS movies_category
FROM
    role_mapping AS r_m
        INNER JOIN
    movie AS m ON r_m.movie_id = m.id
        INNER JOIN
    ratings AS r ON r.movie_id = m.id
;



-- Segment 4:

-- Calculating the genre-wise running total and moving average of the average movie duration.

SELECT genre,
		ROUND(AVG(duration),2) AS avg_duration,
        SUM(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS UNBOUNDED PRECEDING) AS running_total_duration,
        AVG(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS 10 PRECEDING) AS moving_avg_duration
FROM movie AS m 
		INNER JOIN 
    genre AS g ON m.id= g.movie_id
GROUP BY genre
ORDER BY genre;




-- Identifying the five highest-grossing movies of each year that belong to the top three genres.

WITH top_3_genre AS
(
	SELECT 
		genre
	FROM genre
			INNER JOIN
		movie ON genre.movie_id = movie.id
	GROUP BY genre
	ORDER BY COUNT(id) DESC
	LIMIT 3
), 
top_5 AS
(
	SELECT 
		genre,
		year,
		title AS movie_name,
		worlwide_gross_income AS worldwide_gross_income,
		DENSE_RANK() OVER (PARTITION BY YEAR ORDER BY worlwide_gross_income DESC) AS movie_rank
	FROM
		movie AS m
			INNER JOIN 
		genre AS g ON m.id= g.movie_id
	WHERE g.genre IN (SELECT genre FROM top_3_genre)
)
SELECT * 
FROM top_5
WHERE movie_rank <=5;


/* -- Determining the names of the top two production houses that have produced the 
highest number of hits among multilingual movies, and the top two production houses 
that have produced the highest number of hits (median rating >= 8) among multilingual movies. */

SELECT 
    production_company, 
    COUNT(id) AS movie_count,
    RANK() OVER(ORDER BY COUNT(id) DESC) AS prod_comp_rank
FROM
    movie AS m
        INNER JOIN
    ratings AS r ON m.id = r.movie_id
WHERE
    median_rating >= 8
        AND production_company IS NOT NULL
        AND POSITION(',' IN languages) > 0
GROUP BY production_company
LIMIT 2;

-- Star Cinema and Twentieth Century Fox are the top two production houses that have produced the highest number of hits among multilingual movies.


-- Identifying the top 3 actresses based on the number of Super Hit movies (average rating > 8) in the drama genre.

SELECT 
    name,
    SUM(total_votes) AS total_votes,
    COUNT(r_m.movie_id) AS movie_count,
    avg_rating AS actress_avg_rating,
	DENSE_RANK() OVER(ORDER BY COUNT(r_m.movie_id) DESC) AS actress_rank
FROM
    names AS n
        INNER JOIN
    role_mapping AS r_m ON n.id = r_m.name_id
        INNER JOIN
    ratings AS r ON r.movie_id = r_m.movie_id
        INNER JOIN
    genre AS g ON r.movie_id = g.movie_id
WHERE
    category = 'actress' AND avg_rating > 8
        AND genre = 'drama'
GROUP BY name , avg_rating
LIMIT 3;

-- The top three actresses with the highest number of super-hit movies are Kim Hunter, Kathleen Byron, and Yolonda Ross.


/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

/* Gathering the specified information for the top 9 directors, ordered by the number of movies they have directed:
- Director ID
- Name
- Number of movies
- Average duration between movies in days
- Average ratings of their movies
- Total votes received
- Minimum rating received
- Maximum rating received
- Total duration of all their movies. */

WITH movie_date_information AS
(
	SELECT 
		d_m.name_id, 
		name, d_m.movie_id,
		m.date_published, 
		LEAD(date_published, 1) OVER(PARTITION BY d_m.name_id ORDER BY date_published, d_m.movie_id) AS next_movie_date
	FROM director_mapping d_m
			INNER JOIN 
		names AS n ON d_m.name_id=n.id 
			INNER JOIN 
        movie AS m ON d_m.movie_id=m.id
),

date_inter_difference AS
(
	SELECT 
		*, 
		DATEDIFF(next_movie_date, date_published) AS date_differance
	FROM movie_date_information
 ),
 avg_inter_days AS
 (
	SELECT 
		name_id, 
        AVG(date_differance) AS avg_inter_movie_days
	 FROM date_inter_difference
	 GROUP BY name_id
 ),
 final_output AS
 (
	SELECT 
		d_m.name_id AS director_id,
        name AS director_name,
		COUNT(d_m.movie_id) AS number_of_movies,
		ROUND(avg_inter_movie_days) AS avg_inter_movie_days,
		ROUND(AVG(avg_rating),2) AS avg_rating,
		SUM(total_votes) AS total_votes,
		MIN(avg_rating) AS min_rating,
		MAX(avg_rating) AS max_rating,
		SUM(duration) AS total_duration,
		ROW_NUMBER() OVER(ORDER BY COUNT(d_m.movie_id) DESC) AS director_rank
	 FROM
		 names AS n 
			INNER JOIN 
		director_mapping AS d_m ON n.id=d_m.name_id
			INNER JOIN 
		ratings AS r ON d_m.movie_id=r.movie_id
			INNER JOIN 
		movie AS m ON m.id=r.movie_id
			INNER JOIN 
		avg_inter_days AS a ON a.name_id=d_m.name_id
	GROUP BY director_id
 )
 SELECT *	
 FROM final_output
 LIMIT 9; 


