CREATE DATABASE `softuni_imdb`;

CREATE TABLE `movies_additional_info` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `rating` DECIMAL(10,2) NOT NULL,
 `runtime` INT NOT NULL,
 `picture_url` VARCHAR(80) NOT NULL,
 `budget` DECIMAL(10,2),
 `release_date` DATE NOT NULL,
 `has_subtitles` BOOLEAN,
 `description` TEXT
);

CREATE TABLE `genres` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `name` VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE `countries` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `name` VARCHAR(30) UNIQUE NOT NULL,
 `continent` VARCHAR(30) NOT NULL,
 `currency` VARCHAR(5) NOT NULL
);

CREATE TABLE `actors` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `first_name` VARCHAR(50) NOT NULL, 
 `last_name` VARCHAR(50) NOT NULL,
 `birthdate` DATE NOT NULL,
 `height` INT,
 `awards` INT,
 `country_id` INT NOT NUll,
 CONSTRAINT fk_actors_countries
 FOREIGN KEY (`country_id`)
 REFERENCES `countries`(`id`)
);

CREATE TABLE `movies` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `title` VARCHAR(70) UNIQUE NOT NULL,
 `country_id` INT NOT NULL,
 `movie_info_id` INT UNIQUE NOT NULL,
 CONSTRAINT fk_movies_countries
 FOREIGN KEY (`country_id`)
 REFERENCES `countries`(`id`),
 CONSTRAINT fk_movies_info
 FOREIGN KEY (`movie_info_id`)
 REFERENCES `movies_additional_info`(`id`)
);

CREATE TABLE `genres_movies` (
 `genre_id` INT,
 `movie_id` INT,
 CONSTRAINT fk_genres_movies_genres
 FOREIGN KEY (`genre_id`)
 REFERENCES `genres`(`id`),
 CONSTRAINT fk_genres_movies_movies
 FOREIGN KEY (`movie_id`)
 REFERENCES `movies`(`id`)
); 

CREATE TABLE `movies_actors` (
 `movie_id` INT,
 `actor_id` INT,
 CONSTRAINT fk_movies_actors_movies
 FOREIGN KEY (`movie_id`)
 REFERENCES `movies`(`id`),
 CONSTRAINT fk_movies_actors_actors
 FOREIGN KEY (`actor_id`)
 REFERENCES `actors`(`id`)
);


INSERT INTO `actors` (`first_name`, `last_name`, `birthdate`, `height`, `awards`, `country_id`)
SELECT REVERSE(`first_name`), REVERSE(`last_name`), DATE(`birthdate` - 2), `height` + 10, `country_id`, 3
FROM `actors`
WHERE `id` <= 10;

UPDATE `movies_additional_info`
SET `runtime` = `runtime` - 10
WHERE `id` >= 15 AND `id` <= 25;

DELETE c FROM `countries` AS c
LEFT JOIN `movies` AS m 
ON m.`country_id` = c.`id`
WHERE m.`country_id` IS NULL;


SELECT `id`, `name`, `continent`, `currency`
FROM `countries`
ORDER BY `currency` DESC, `id`;

SELECT m.`id`, m.`title`, mi.`runtime`, mi.`budget`, mi.`release_date`
FROM `movies` AS m
JOIN `movies_additional_info` AS mi
ON m.`movie_info_id` = mi.`id`
WHERE YEAR(mi.`release_date`) BETWEEN 1996 AND 1999
ORDER BY mi.`runtime`, m.`movie_info_id`
LIMIT 20;

SELECT CONCAT(a.`first_name`, ' ', `last_name`) AS 'full_name',
CONCAT(REVERSE(a.`last_name`), char_length(a.`last_name`), '@cast.com') AS 'email',
2022 - YEAR(a.`birthdate`) AS 'age', a.`height`
FROM `actors` AS a
LEFT JOIN `movies_actors` AS ma
ON a.`id` = ma.`actor_id`
LEFT JOIN `movies` AS m
ON m.`id` = ma.`movie_id`
WHERE m.`id` IS NULL
ORDER BY a.`height`;

SELECT c.`name`, COUNT(m.`id`) AS 'movies_count'
FROM `countries` AS c
LEFT JOIN `movies` AS m
ON c.`id` = m.`country_id`
GROUP BY c.`name`
HAVING `movies_count` >= 7
ORDER BY c.`name` DESC;

SELECT m.`title`,
CASE
WHEN mi.`rating` <= 4 THEN 'poor'
WHEN mi.`rating` <= 7 THEN 'good'
ELSE 'excellent'
END AS 'rating',
IF(mi.`has_subtitles` = 1,'english', '-') AS 'subtitles',
mi.`budget` 
FROM `movies` AS m
JOIN `movies_additional_info` AS mi
ON m.`movie_info_id` = mi.`id`
ORDER BY mi.`budget` DESC;


DELIMITER $$

CREATE FUNCTION udf_actor_history_movies_count(full_name VARCHAR(50))
RETURNS INT
DETERMINISTIC
BEGIN

	  RETURN (SELECT COUNT(a.id)
      FROM `actors` AS a
	  LEFT JOIN `movies_actors` AS ma
      ON a.`id` = ma.`actor_id`
      LEFT JOIN `movies` AS m
      ON ma.`movie_id` = m.`id`
      LEFT JOIN `genres_movies` AS gm
      ON m.`id` = gm.`movie_id`
      LEFT JOIN `genres` AS g
      ON gm.`genre_id` = g.`id`
      WHERE CONCAT(a.`first_name`, ' ', a.`last_name`) = full_name
      AND g.`name` = 'history');
      
END$$

CREATE PROCEDURE udp_award_movie(movie_title VARCHAR(50))
BEGIN
     
     UPDATE `actors` AS a
	 LEFT JOIN `movies_actors` AS ma
	 ON a.`id` = ma.`actor_id`
	 LEFT JOIN `movies` AS m
	 ON ma.`movie_id` = m.`id`
     SET a.`awards` = a.`awards` + 1
	 WHERE m.`title` = movie_title;
	 
END$$