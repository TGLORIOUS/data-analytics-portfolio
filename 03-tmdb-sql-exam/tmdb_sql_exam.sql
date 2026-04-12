-- ============================================================
-- ALX AFRICA SQL EXAM: TMDB DATABASE
-- Database: The Movie Database (TMDb)
-- All 15 questions answered with correct queries
-- ============================================================

-- Q1: Who won the Oscar for "Actor in a Leading Role" in 2015?
-- ANSWER: Leonardo DiCaprio
SELECT name 
FROM oscars 
WHERE award = 'Actor in a Leading Role' 
AND year = '2015' 
AND winner = 1.0;

-- Q2: Query to produce the ten oldest movies in the database
-- ANSWER: SELECT * FROM movies WHERE release_date IS NOT NULL ORDER BY release_date ASC LIMIT 10
SELECT * 
FROM movies 
WHERE release_date IS NOT NULL 
ORDER BY release_date ASC 
LIMIT 10;

-- Q3: How many unique awards are there in the Oscars table?
-- ANSWER: 114
SELECT COUNT(DISTINCT award) AS unique_awards
FROM oscars;

-- Q4: How many movies contain the word "Spider" within their title?
-- ANSWER: 9
SELECT COUNT(*) AS spider_movies
FROM movies 
WHERE title LIKE '%Spider%';

-- Q5: Movies in "Thriller" genre that contain the word "love" in keywords
-- ANSWER: 48
SELECT COUNT(DISTINCT m.movie_id) AS thriller_love_movies
FROM movies m
JOIN genremap gm ON m.movie_id = gm.movie_id
JOIN genres g ON gm.genre_id = g.genre_id
JOIN keywordmap km ON m.movie_id = km.movie_id
JOIN keywords k ON km.keyword_id = k.keyword_id
WHERE g.genre_name = 'Thriller'
AND k.keyword_name LIKE '%love%';

-- Q6: Movies released between 2006-08-01 and 2009-10-01 with popularity > 40 and budget < 50,000,000
-- ANSWER: 29
SELECT COUNT(*) AS filtered_movies
FROM movies
WHERE release_date BETWEEN '2006-08-01' AND '2009-10-01'
AND popularity > 40
AND budget < 50000000;

-- Q7: How many unique characters has Vin Diesel played?
-- ANSWER: 16
SELECT COUNT(DISTINCT c.characters) AS unique_characters
FROM casts c
JOIN actors a ON c.actor_id = a.actor_id
WHERE a.actor_name = 'Vin Diesel';

-- Q8: What are the genres of "The Royal Tenenbaums"?
-- ANSWER: Drama, Comedy
SELECT g.genre_name
FROM movies m
JOIN genremap gm ON m.movie_id = gm.movie_id
JOIN genres g ON gm.genre_id = g.genre_id
WHERE m.title = 'The Royal Tenenbaums';

-- Q9: Top 3 production companies by highest average movie popularity
-- ANSWER: The Donners' Company, Bulletproof Cupid, and Kinberg Genre
SELECT 
    pc.production_company_name, 
    AVG(m.popularity) AS avg_popularity
FROM movies m
JOIN productioncompanymap pcm ON m.movie_id = pcm.movie_id
JOIN productioncompanies pc ON pcm.production_company_id = pc.production_company_id
GROUP BY pc.production_company_name
ORDER BY avg_popularity DESC
LIMIT 3;

-- Q10: How many female actors (gender = 1) have a name starting with "N"?
-- ANSWER: 355
SELECT COUNT(*) AS female_actors_N
FROM actors
WHERE gender = 1
AND actor_name LIKE 'N%';

-- Q11: Which genre has the lowest average movie popularity score?
-- ANSWER: Foreign
SELECT 
    g.genre_name, 
    AVG(m.popularity) AS avg_popularity
FROM movies m
JOIN genremap gm ON m.movie_id = gm.movie_id
JOIN genres g ON gm.genre_id = g.genre_id
GROUP BY g.genre_name
ORDER BY avg_popularity ASC
LIMIT 1;

-- Q12: Award category with highest number of actor nominations
-- ANSWER: Actor in a Supporting Role
SELECT 
    award, 
    COUNT(*) AS nominations
FROM oscars o
WHERE o.name IN (SELECT actor_name FROM actors)
GROUP BY award
ORDER BY nominations DESC
LIMIT 1;

-- Q13: Correct query to fix year format for pre-1934 Oscars entries
-- ANSWER: UPDATE Oscars SET year = substr(year, -4)
UPDATE Oscars 
SET year = substr(year, -4)
WHERE LENGTH(year) > 4;

-- Q14: Create a VIEW for Alan Rickman movies
-- ANSWER: CREATE VIEW with proper syntax
CREATE VIEW Alan_Rickman_Movies AS
SELECT title, release_date, tagline, overview
FROM movies
LEFT JOIN casts ON casts.movie_id = movies.movie_id
LEFT JOIN actors ON casts.actor_id = actors.actor_id
WHERE actors.actor_name = 'Alan Rickman';

-- Q15: True statements about database normalisation
-- ANSWER: Statements i and iii are true
-- i) Normalisation improves data redundancy, saves storage, fulfils unique record requirement - TRUE
-- iii) Normalisation removes inconsistencies that complicate data analysis - TRUE
-- ii) FALSE - normalisation supports beyond 3NF (BCNF, 4NF, 5NF)
-- iv) FALSE - normalisation REDUCES (not increases) data redundancy
