DROP TABLE IF EXISTS netflix;


CREATE TABLE netflix (
    show_id VARCHAR(20) PRIMARY KEY,
    type VARCHAR(10),
    title TEXT,
    director TEXT,
    "cast" TEXT,          -- ← DOUBLE QUOTES HERE
    country TEXT,
    date_added DATE,
    release_year INT,
    rating VARCHAR(10),
    duration VARCHAR(20),
    listed_in TEXT,
    description TEXT
);

-- Check total rows (should be 8,807)
SELECT COUNT(*) FROM netflix;

-- Preview the data
SELECT * FROM netflix LIMIT 10;

-- Check for NULL values in key columns
SELECT 
    COUNT(*) AS total_rows,
    COUNT(CASE WHEN director IS NULL OR director = '' THEN 1 END) AS missing_director,
    COUNT(CASE WHEN country IS NULL OR country = '' THEN 1 END) AS missing_country,
    COUNT(CASE WHEN rating IS NULL OR rating = '' THEN 1 END) AS missing_rating
FROM netflix;

-- Replace blanks with 'Unknown' for text columns
UPDATE netflix SET director = 'Unknown' WHERE director IS NULL OR director = '';
UPDATE netflix SET country = 'Not Specified' WHERE country IS NULL OR country = '';
UPDATE netflix SET rating = 'Not Rated' WHERE rating IS NULL OR rating = '';
UPDATE netflix SET duration = 'Unknown' WHERE duration IS NULL OR duration = '';

-- For date_added, we keep NULL as-is (better for date calculations)
-- For cast, we can set to 'Unknown' if needed
UPDATE netflix SET "cast" = 'Unknown' WHERE "cast" IS NULL OR "cast" = '';

-- How many Movies vs TV Shows?
SELECT 
    type, 
    COUNT(*) AS total_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM netflix), 2) AS percentage
FROM netflix
GROUP BY type;

-- Which countries produce the most content?
SELECT 
    country,
    COUNT(*) AS total_titles
FROM netflix
WHERE country != 'Not Specified'
GROUP BY country
ORDER BY total_titles DESC
LIMIT 10;

-- How has content addition changed over the years?
SELECT 
    EXTRACT(YEAR FROM date_added) AS year_added,
    COUNT(*) AS titles_added
FROM netflix
WHERE date_added IS NOT NULL
GROUP BY year_added
ORDER BY year_added DESC;

-- What are the most common age certifications?
SELECT 
    rating,
    COUNT(*) AS total_titles
FROM netflix
WHERE rating != 'Not Rated'
GROUP BY rating
ORDER BY total_titles DESC
LIMIT 10;

-- What are the top genres on Netflix?
-- (Splitting the comma-separated list in listed_in)
SELECT 
    TRIM(genre) AS genre,
    COUNT(*) AS total_titles
FROM netflix
CROSS JOIN LATERAL UNNEST(string_to_array(listed_in, ',')) AS genre
GROUP BY genre
ORDER BY total_titles DESC
LIMIT 5;


CREATE VIEW netflix_summary AS
SELECT 
    type,
    EXTRACT(YEAR FROM date_added) AS year_added,
    rating,
    country,
    COUNT(*) AS total_titles
FROM netflix
WHERE date_added IS NOT NULL
GROUP BY type, year_added, rating, country;
