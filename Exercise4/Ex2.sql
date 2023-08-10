USE `soft_uni`;

SELECT `department_id`, MIN(`salary`)
AS 'minimum salary'
FROM `employees`
WHERE `department_id` IN(2,5,7) AND `hire_date` > '2000-01-01'
GROUP BY `department_id`
ORDER BY `department_id`; 

CREATE TABLE `high_paid_employees`
SELECT * FROM `employees`
WHERE `salary` > 30000;

DELETE FROM `high_paid_employees`
WHERE `manager_id` = 42;

UPDATE `high_paid_employees`
SET `salary` = `salary` + 5000
WHERE `department_id` = 1;

SELECT `department_id`, AVG(`salary`)
AS 'avg_salary'
FROM `high_paid_employees`
GROUP BY `department_id`
ORDER BY `department_id`;

SELECT `department_id`, MAX(`salary`)
AS 'max_salary'
FROM `employees`
GROUP BY `department_id`
HAVING `max_salary` NOT BETWEEN 30000 AND 70000
ORDER BY `department_id`;

SELECT COUNT(`salary`)
FROM `employees`
WHERE `manager_id` IS NULL;

SELECT `department_id`,
(SELECT DISTINCT `salary`
FROM `employees` e
WHERE e.`department_id` = `employees`.`department_id`
ORDER BY `salary` DESC
LIMIT 1 OFFSET 2
)
AS `third_highest_salary`
FROM `employees`
GROUP BY `department_id`
HAVING `third_highest_salary` IS NOT NULL
ORDER BY `department_id`;


SELECT `first_name`, `last_name`, `department_id`
FROM `employees` e1
WHERE `salary` > 
(SELECT AVG(`salary`)
FROM `employees` e2
WHERE e1.`department_id` = e2.`department_id`)
ORDER BY `department_id`, `employee_id`
LIMIT 10;

SELECT `department_id`, SUM(`salary`)
AS 'total_salary'
FROM `employees`
GROUP BY `department_id`
ORDER BY `department_id`;

