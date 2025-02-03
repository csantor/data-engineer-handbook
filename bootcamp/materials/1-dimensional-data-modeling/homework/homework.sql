-- 1. DDL for actors table

CREATE TYPE films AS
(
    film TEXT,
    votes INTEGER,
    rating REAL,
    filmid TEXT
);

CREATE TYPE quality_class AS ENUM
('star', 'good', 'average', 'bad');

CREATE TABLE actors
(   
    actor TEXT,
    actorid TEXT,
    films films[],
    quality_class quality_class,
    current_year INTEGER,
    is_active BOOLEAN,
    PRIMARY KEY (actor, current_year)
);

-- 2. Cumulative table generation query

WITH ly AS (
    SELECT * FROM actors
    WHERE current_year = 1969

), ty AS (
     SELECT * FROM actor_films
    WHERE year = 1970
)
INSERT INTO actors
SELECT
        COALESCE(ly.actor, ty.actor) as actor_name,
        COALESCE(ly.actorid, ty.actorid) as actor_name,
        COALESCE(ly.year,
            ARRAY[]::films[]
            ) || CASE WHEN ty.year IS NOT NULL THEN
                ARRAY[ROW(
                ty.film,
                ty.votes,
                ty.rating,
                ty.filmid)::films]
                ELSE ARRAY[]::films[] END
            as films,
        
         CASE
             WHEN ty.year IS NOT NULL THEN
                 (CASE WHEN ty.rating > 8 THEN 'star'
                    WHEN ty.rating > 7 THEN 'good'
                    WHEN ty.rating > 6 THEN 'average'
                    ELSE 'bad' END)::quality_class
             ELSE ly.quality_class
         END as quality_class,
         COALESCE(ty.year, ly.current_year + 1) AS current_year,
         ty.year IS NOT NULL as is_active
         

    FROM ly
    FULL OUTER JOIN ty
    ON ly.actor = ty.actor

