CREATE DATABASE `universities_db`;

CREATE TABLE `countries` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `name` VARCHAR(40) UNIQUE NOT NULL
);

CREATE TABLE `cities` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `name` VARCHAR(40) UNIQUE NOT NULL,
 `population` INT,
 `country_id` INT NOT NULL,
 CONSTRAINT fk_cities_countries
 FOREIGN KEY (`country_id`)
 REFERENCES `countries`(`id`)
);

CREATE TABLE `universities` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `name` VARCHAR(60) UNIQUE NOT NULL,
 `address` VARCHAR(80) UNIQUE NOT NULL,
 `tuition_fee` DECIMAL(19,2) NOT NULL,
 `number_of_staff` INT,
 `city_id` INT,
 CONSTRAINT fk_universities_cities
 FOREIGN KEY (`city_id`)
 REFERENCES `cities`(`id`)
);

CREATE TABLE `students` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `first_name` VARCHAR(40) NOT NULL,
 `last_name` VARCHAR(40) NOT NULL,
 `age` INT,
 `phone` VARCHAR(20) UNIQUE NOT NULL,
 `email` VARCHAR(255) UNIQUE NOT NULL,
 `is_graduated` BOOLEAN NOT NULL,
 `city_id` INT,
 CONSTRAINT fk_students_cities
 FOREIGN KEY (`city_id`)
 REFERENCES `cities`(`id`)
);

CREATE TABLE `courses` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `name` VARCHAR(40) UNIQUE NOT NULL,
 `duration_hours` DECIMAL(19,2),
 `start_date` DATE,
 `teacher_name` VARCHAR(60) UNIQUE NOT NULL,
 `description` TEXT,
 `university_id` INT,
 CONSTRAINT fk_courses_universities
 FOREIGN KEY (`university_id`)
 REFERENCES `universities`(`id`)
);

CREATE TABLE `students_courses` (
 `grade` DECIMAL(19,2) NOT NULL,
 `student_id` INT NOT NULL,
 `course_id` INT NOT NULL,
 CONSTRAINT fk_students_courses_students
 FOREIGN KEY (`student_id`)
 REFERENCES `students`(`id`),
 CONSTRAINT fk_students_courses_courses
 FOREIGN KEY (`course_id`)
 REFERENCES `courses`(`id`)
);


INSERT INTO `courses` (`name`, `duration_hours`, `start_date`, `teacher_name`, `description`, `university_id`)
SELECT CONCAT(`teacher_name`, ' course'), (char_length(`name`) / 10),
DATE_ADD(`start_date`, INTERVAL 5 DAY), REVERSE(`teacher_name`),
CONCAT('Course ', `teacher_name`, REVERSE(`description`)), DAY(`start_date`)
FROM `courses`
WHERE `id` <= 5;


UPDATE `universities` 
SET `tuition_fee` = `tuition_fee` + 300
WHERE `id` BETWEEN 5 AND 12;

DELETE u FROM `universities` AS u
WHERE `number_of_staff` IS NULL;


SELECT * FROM `cities`
ORDER BY `population` DESC;

SELECT `first_name`, `last_name`, `age`, `phone`, `email`
FROM `students`
WHERE `age` >= 21
ORDER BY `first_name` DESC, `email`, `id`
LIMIT 10;

SELECT CONCAT(s.`first_name`, ' ', s.`last_name`) AS 'full_name',
SUBSTRING(s.`email`,2,10) AS 'username', REVERSE(s.`phone`) AS 'password'
FROM `students` AS s
LEFT JOIN `students_courses` AS sc
ON s.`id` = sc.`student_id`
LEFT JOIN `courses` AS c
ON c.`id` = sc.`student_id`
WHERE c.`id` IS NULL
ORDER BY `password` DESC;

SELECT COUNT(s.`id`) AS 'students_count',
u.`name` AS 'university_name'
FROM `universities` AS u
JOIN `courses` AS c
ON u.`id` = c.`university_id`
JOIN `students_courses` AS sc
ON c.`id` = sc.`course_id`
JOIN `students` AS s
ON s.`id` = sc.`student_id`
GROUP BY u.`id`
HAVING `students_count` >= 8
ORDER BY `students_count` DESC, u.`name` DESC;

SELECT u.`name` AS 'university_name', c.`name` AS 'city_name',
u.`address`,
CASE
WHEN u.`tuition_fee` < 800 THEN 'cheap'
WHEN u.`tuition_fee` BETWEEN 800 AND 1199 THEN 'normal'
WHEN u.`tuition_fee` BETWEEN 1200 AND 2499 THEN 'high'
ELSE 'expensive'
END AS 'price_rank', u.`tuition_fee`
FROM `universities` AS u
JOIN `cities` AS c
ON c.`id` = u.`city_id`
ORDER BY u.`tuition_fee`;

DELIMITER $$

CREATE FUNCTION udf_average_alumni_grade_by_course_name(course_name VARCHAR(60))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN

     RETURN (SELECT AVG(sc.`grade`) AS 'average_alumni_grade'
     FROM `courses` AS c
     JOIN `students_courses` AS sc
     ON c.`id` = sc.`course_id`
     JOIN `students` AS s
     ON s.`id` = sc.`student_id`
     WHERE s.`is_graduated` IS TRUE AND c.`name` = course_name
     GROUP BY c.`name`);
     
END$$


CREATE PROCEDURE udp_graduate_all_students_by_year(year_started INT)
BEGIN

     UPDATE `students` AS s
     JOIN `students_courses` AS sc
     ON s.`id` = sc.`student_id`
     JOIN `courses` AS c
     ON c.`id` = sc.`course_id`
     SET `is_graduated` = TRUE
     WHERE YEAR(c.`start_date`) = year_started;
     
END$$