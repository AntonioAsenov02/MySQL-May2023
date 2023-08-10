CREATE TABLE `mountains` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `name` VARCHAR(120)
);

CREATE TABLE `peaks` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `name` VARCHAR(120),
 `mountain_id` INT NOT NULL,
 CONSTRAINT fk_peaks_mountains
 FOREIGN KEY (`mountain_id`)
 REFERENCES `mountains`(`id`)
);


SELECT c.`id`, v.`vehicle_type`, CONCAT(c.`first_name`, ' ', c.`last_name`)
AS 'driver_name'
FROM `campers` AS c
JOIN `vehicles` AS v ON
v.`driver_id` = c.`id`;

SELECT `starting_point`
AS 'route_starting_point',
`end_point`
AS 'route_ending_point',
`leader_id`,
CONCAT(`first_name`, ' ', `last_name`)
AS 'leader_name'
FROM `routes` AS r
JOIN `campers` AS c ON
r.`leader_id` = c.`id`;

CREATE TABLE `mountains` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `name` VARCHAR(120) NOT NULL
);

CREATE TABLE `peaks` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `name` VARCHAR(120) NOT NULL,
 `mountain_id` INT,
 CONSTRAINT fk_peaks_mountain
 FOREIGN KEY (`mountain_id`)
 REFERENCES `mountains`(`id`)
 ON DELETE CASCADE
);

