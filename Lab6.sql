SELECT e.`employee_id`,
CONCAT(e.`first_name`, ' ', e.`last_name`) AS 'full_name',
d.`department_id`,
d.`name`
FROM `employees` AS e
RIGHT JOIN `departments` AS d ON
d.manager_id = e.employee_id
ORDER BY e.`employee_id`
LIMIT 5;

SELECT t.`town_id`, t.`name`, a.`address_text`
FROM `towns` AS t
LEFT JOIN `addresses` AS a
ON t.`town_id` = a.`town_id`
WHERE t.`name` = 'San Francisco' OR
t.`name` = 'Sofia' OR t.`name` = 'Carnation'
ORDER BY t.`town_id`, a.`address_id`;

SELECT `employee_id`, `first_name`,
`last_name`, `department_id`, `salary`
FROM `employees`
WHERE `manager_id` IS NULL;


SELECT COUNT(*) AS 'count'
FROM `employees`
WHERE `salary` > 
(SELECT AVG(`salary`)
FROM `employees`);
