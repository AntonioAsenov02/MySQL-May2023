CREATE DATABASE `sgd`;

CREATE TABLE `addresses` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `name` VARCHAR(50) NOT NULL
);

CREATE TABLE `categories` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `name` VARCHAR(10) NOT NULL
);

CREATE TABLE `offices` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `workspace_capacity` INT NOT NULL,
 `website` VARCHAR(50),
 `address_id` INT NOT NULL,
 CONSTRAINT fk_offices_addresses
 FOREIGN KEY (`address_id`)
 REFERENCES `addresses`(`id`)
);

CREATE TABLE `employees` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `first_name` VARCHAR(30) NOT NULL,
 `last_name` VARCHAR(30) NOT NULL,
 `age` INT NOT NULL,
 `salary` DECIMAL(10,2) NOT NULL,
 `job_title` VARCHAR(20) NOT NULL,
 `happiness_level` CHAR(1) NOT NULL
);

CREATE TABLE `teams` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `name` VARCHAR(40) NOT NULL,
 `office_id` INT NOT NULL,
 `leader_id` INT UNIQUE,
 CONSTRAINT fk_teams_offices
 FOREIGN KEY (`office_id`)
 REFERENCES `offices`(`id`),
 CONSTRAINT fk_teams_empoyees
 FOREIGN KEY (`leader_id`)
 REFERENCES `employees`(`id`)
);

CREATE TABLE `games` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `name` VARCHAR(50) UNIQUE NOT NULL,
 `description` TEXT,
 `rating` FLOAT NOT NULL DEFAULT 5.5,
 `budget` DECIMAL(10,2) NOT NULL,
 `release_date` DATE,
 `team_id` INT NOT NULL,
 CONSTRAINT fk_games_teams
 FOREIGN KEY (`team_id`)
 REFERENCES `teams`(`id`)
);

CREATE TABLE `games_categories` (
 `game_id` INT NOT NULL,
 `category_id` INT NOT NULL,
 PRIMARY KEY (`game_id`, `category_id`),
 CONSTRAINT fk_games_categories_games
 FOREIGN KEY (`game_id`)
 REFERENCES `games`(`id`),
 CONSTRAINT fk_games_categories_categories
 FOREIGN KEY (`category_id`)
 REFERENCES `categories`(`id`)
);


INSERT INTO `games` (`name`, `rating`, `budget`, `team_id`)
SELECT LOWER(REVERSE(SUBSTRING(t.`name`,2))), t.`id`,
t.`leader_id` * 1000, t.`id`
FROM `teams` AS t
WHERE t.`id` BETWEEN 1 AND 9;


UPDATE `employees` AS e
JOIN `teams` AS t
ON e.`id` = t.`leader_id`
SET `salary` = `salary` + 1000
WHERE e.`id` = t.`leader_id` AND e.`age` < 40 AND e.`salary` < 5000;


DELETE g FROM `games` AS g
LEFT JOIN `games_categories` AS gc
ON g.`id` = gc.`game_id`
LEFT JOIN `categories` AS c
ON c.`id` = gc.`category_id`
WHERE gc.`category_id` IS NULL AND g.`release_date` IS NULL;

SELECT `first_name`, `last_name`, `age`, `salary`, `happiness_level`
FROM `employees`
ORDER BY `salary`, `id`;

SELECT t.`name` AS 'team_name',
a.`name` AS 'address_name', char_length(a.`name`)
AS 'count_of_characters'
FROM `teams` AS t
JOIN `offices` AS o
ON t.`office_id` = o.`id`
JOIN `addresses` AS a
ON a.`id` = o.`address_id`
WHERE o.`website` IS NOT NULL
ORDER BY `team_name`, `address_name`;

SELECT c.`name`, COUNT(g.`id`) AS 'games_count',
ROUND(AVG(g.`budget`), 2) AS 'avg_budget', MAX(g.`rating`) AS 'max_rating' 
FROM `categories` AS c
JOIN `games_categories` AS gc
ON c.`id` = gc.`category_id`
JOIN `games` AS g
ON g.`id` = gc.`game_id`
GROUP BY c.`name`
HAVING `max_rating` >= 9.5
ORDER BY `games_count` DESC, c.`name`;

SELECT g.`name`, g.`release_date`, CONCAT(SUBSTRING(g.`description`,1,10), '...') AS 'summary',
CASE
WHEN MONTH(g.`release_date`) IN(1,2,3) THEN 'Q1'
WHEN MONTH(g.`release_date`) IN(4,5,6) THEN 'Q2'
WHEN MONTH(g.`release_date`) IN(7,8,9) THEN 'Q3'
WHEN MONTH(g.`release_date`) IN(10,11,12) THEN 'Q4'
END AS 'quarter',
t.`name`
FROM `games` AS g
JOIN `teams` AS t
ON t.`id` = g.`team_id`
WHERE YEAR(g.`release_date`) = 2022 AND MONTH(g.`release_date`) % 2 = 0
AND g.`name` LIKE('%2')
ORDER BY `quarter`;

SELECT g.`name`, IF(g.`budget` < 50000, 'Normal budget', 'Insufficient budget') AS 'budget_level',
t.`name`, a.`name`
FROM `categories` AS c
RIGHT JOIN `games_categories` AS gc
ON c.`id` = gc.`category_id`
RIGHT JOIN  `games` AS g
ON g.`id` = gc.`game_id`
JOIN `teams` AS t
ON t.`id` = g.`team_id`
JOIN `offices` AS o
ON o.`id` = t.`office_id`
JOIN `addresses` AS a
ON a.`id` = o.`address_id`
WHERE g.`release_date` IS NULL AND gc.`game_id` IS NULL 
ORDER BY g.`name`;

DELIMITER $$

CREATE FUNCTION udf_game_info_by_name (game_name VARCHAR (20))
RETURNS TEXT
DETERMINISTIC
BEGIN

	 RETURN (SELECT 
     CONCAT('The ', game_name, ' is developed by a ', t.`name`, ' in an office with an address ', a.`name`)
     FROM `games` AS g
     JOIN `teams` AS t
     ON t.`id` = g.`team_id`
     JOIN `offices` AS o
     ON o.`id` = t.`office_id`
     JOIN `addresses` AS a
     ON a.`id` = o.`address_id`
     WHERE g.`name` = game_name);
     
END$$


CREATE PROCEDURE udp_update_budget(min_game_rating FLOAT)
BEGIN

     UPDATE `games` AS g
     LEFT JOIN `games_categories` AS gc
     ON g.`id` = gc.`game_id`
     LEFT JOIN `categories` AS c
     ON c.`id` = gc.`category_id`
     SET g.`budget` = g.`budget` + 100000, g.`release_date` = DATE_ADD(g.`release_date`, INTERVAL 1 YEAR)
     WHERE gc.`category_id` IS NULL AND g.`rating` > min_game_rating AND g.`release_date` IS NOT NULL;
     
END$$