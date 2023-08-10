SELECT `first_name`, `last_name`
FROM `employees`
WHERE SUBSTRING(`first_name`,1, 2) = "Sa"
ORDER BY `employee_id`;

SELECT `first_name`, `last_name`
FROM `employees`
WHERE `last_name` LIKE '%ei%'
ORDER BY `employee_id`;

SELECT `first_name` FROM `employees`
WHERE `department_id` IN(3,10)
AND YEAR (`hire_date`) BETWEEN 1995 AND 2005
ORDER BY `employee_id`;

SELECT `first_name`, `last_name`
FROM `employees`
WHERE `job_title` NOT LIKE '%engineer%'
ORDER BY `employee_id`;

SELECT `name` FROM `towns`
WHERE char_length(`name`) = 5 OR char_length(`name`) = 6
ORDER BY `name`;

SELECT `name` FROM `towns`
WHERE char_length(`name`) IN(5,6)
ORDER BY `name`;

USE `soft_uni`;

SELECT * FROM `towns`
WHERE 
`name` LIKE 'm%' OR
`name` LIKE 'k%' OR
`name` LIKE 'b%' OR
`name` LIKE 'e%'
ORDER BY `name`;


SELECT * FROM `towns`
WHERE 
     `name` NOT LIKE 'r%' AND
     `name` NOT LIKE 'b%' AND
     `name` NOT LIKE 'd%'
ORDER BY `name`;

CREATE VIEW v_employees_hired_after_2000 AS
SELECT `first_name`, `last_name`
FROM `employees`
WHERE  YEAR(`hire_date`) > 2000;

SELECT `first_name`, `last_name`
FROM `employees`
WHERE `last_name` LIKE '_____';