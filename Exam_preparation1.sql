CREATE DATABASE `fsd`;


CREATE TABLE `countries` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `name` VARCHAR(45) NOT NULL
);

CREATE TABLE `towns` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `name` VARCHAR(45) NOT NULL,
 `country_id` INT NOT NULL,
 CONSTRAINT fk_towns_countries
 FOREIGN KEY (`country_id`)
 REFERENCES `countries`(`id`)
);

CREATE TABLE `stadiums` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `name` VARCHAR(45) NOT NULL,
 `capacity` INT NOT NULL,
 `town_id` INT NOT NULL,
 CONSTRAINT fk_stadiums_towns
 FOREIGN KEY (`town_id`)
 REFERENCES `towns`(`id`)
);

CREATE TABLE `teams` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `name` VARCHAR(45) NOT NULL,
 `established` DATE NOT NULL,
 `fan_base` BIGINT NOT NULL DEFAULT 0,
 `stadium_id` INT NOT NULL,
 CONSTRAINT fk_teams_stadiums
 FOREIGN KEY (`stadium_id`)
 REFERENCES `stadiums`(`id`)
);

CREATE TABLE `skills_data` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `dribbling` INT DEFAULT 0,
 `pace` INT DEFAULT 0,
 `passing` INT DEFAULT 0,
 `shooting` INT DEFAULT 0,
 `speed` INT DEFAULT 0,
 `strength` INT DEFAULT 0
);

CREATE TABLE `coaches` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `first_name` VARCHAR(10) NOT NULL,
 `last_name` VARCHAR(20) NOT NULL,
 `salary` DECIMAL(10,2) NOT NULL DEFAULT 0,
 `coach_level` INT NOT NULL DEFAULT 0
);


CREATE TABLE `players` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `first_name` VARCHAR(10) NOT NULL,
 `last_name` VARCHAR(20) NOT NULL,
 `age` INT NOT NULL DEFAULT 0,
 `position` CHAR(1) NOT NULL,
 `salary` DECIMAL(10,2) NOT NULL DEFAULT 0,
 `hire_date` DATETIME,
 `skills_data_id` INT NOT NULL,
 `team_id` INT,
 CONSTRAINT fk_players_skills_data
 FOREIGN KEY (`skills_data_id`)
 REFERENCES `skills_data`(`id`),
 CONSTRAINT fk_players_teams
 FOREIGN KEY (`team_id`)
 REFERENCES `teams`(`id`)
);


CREATE TABLE `players_coaches` (
 `player_id` INT,
 `coach_id` INT,
 PRIMARY KEY(`player_id`, `coach_id`),
 CONSTRAINT fk_players_coaches_players
 FOREIGN KEY (`player_id`)
 REFERENCES `players`(`id`),
 CONSTRAINT fk_players_coaches_coaches
 FOREIGN KEY (`coach_id`)
 REFERENCES `coaches`(`id`)
);


INSERT INTO `coaches` (`first_name`, `last_name`, `salary`, `coach_level`)
SELECT `first_name`, `last_name`, `salary` * 2, char_length(`first_name`)
AS `coach_level`
FROM `players`
WHERE `age` >= 45;

UPDATE `coaches`
SET `coach_level` = `coach_level` + 1
WHERE `first_name` LIKE 'A%' AND 
(SELECT COUNT(*)
 FROM `players_coaches`
 WHERE `coach_id` = `id`);
 
 DELETE FROM `players`
 WHERE `age` >= 45;
 
 
 SELECT `first_name`, `age`, `salary`
 FROM `players`
 ORDER BY `salary` DESC;
 
 SELECT p.`id`, CONCAT(p.`first_name`, ' ', p.`last_name`)
 AS 'full_name',
 p.`age`, p.`position`, p.`hire_date`
 FROM `players` AS p
 JOIN `skills_data` AS sd
 ON p.`skills_data_id` = sd.`id`
 WHERE p.`age` < 23 AND p.`position` = 'A'
 AND p.`hire_date` IS NULL AND sd.`strength` > 50
 ORDER BY p.`salary`, p.`age`;
 
SELECT t.`name` AS 'team_name', t.`established`,
t.`fan_base`, COUNT(p.`id`)			 
AS 'players_count'
FROM `teams` AS t
LEFT JOIN `players` AS p 
ON t.`id` = p.`team_id`
GROUP BY t.`id`
ORDER BY `players_count` DESC, `fan_base` DESC;

SELECT MAX(sk.`speed`) AS 'speed', t.`name`
AS 'town_name'
FROM `towns` AS t
LEFT JOIN `stadiums` AS s
ON t.`id` = s.`town_id`
LEFT JOIN `teams` As tm
ON s.`id` = tm.`stadium_id`
LEFT JOIN `players` AS p
ON tm.`id` = p.`team_id`
LEFT JOIN `skills_data` AS sk
ON p.`skills_data_id` = sk.`id`
WHERE tm.`name` NOT LIKE 'Devify'
GROUP BY t.name
ORDER BY `speed` DESC, t.`name`;


SELECT c.`name`, COUNT(p.id) AS 'total_count_of_players',
SUM(p.`salary`) AS 'total_sum_of_salaries'
FROM `countries` AS c
LEFT JOIN `towns` AS t
ON t.`country_id` = c.`id`
LEFT JOIN `stadiums` AS s
ON t.`id` = s.`town_id`
LEFT JOIN `teams` As tm
ON s.`id` = tm.`stadium_id`
LEFT JOIN `players` AS p
ON tm.`id` = p.`team_id`
GROUP BY c.`name`
ORDER BY `total_count_of_players` DESC, c.`name`;

DELIMITER $$

CREATE FUNCTION udf_stadium_players_count (stadium_name VARCHAR(30))
RETURNS INT
DETERMINISTIC
BEGIN

	RETURN (SELECT COUNT(p.`id`)
     FROM `stadiums` AS s
	 LEFT JOIN `teams` As tm
     ON s.`id` = tm.`stadium_id`
     LEFT JOIN `players` AS p
	 ON tm.`id` = p.`team_id`
     WHERE s.`name` = stadium_name);
     
END$$

CREATE PROCEDURE udp_find_playmaker (min_dribble_points INT, team_name VARCHAR(45))
BEGIN

     SELECT CONCAT(p.`first_name`, ' ', p.`last_name`)
     AS 'full_name', p.`age`, p.`salary`, sd.`dribbling`,
     sd.`speed`, t.`name` AS 'team_name'
     FROM `skills_data` AS sd
     JOIN `players` AS p
     ON p.`skills_data_id` = sd.`id`
     RIGHT JOIN `teams` AS t
     ON t.`id` = p.`team_id`
     WHERE t.`name` = team_name
     AND sd.`dribbling` > min_dribble_points
	 AND sd.`speed` > (SELECT AVG(`speed`) FROM `skills_data`)
     ORDER BY sd.`speed` DESC
     LIMIT 1;
     
END$$

