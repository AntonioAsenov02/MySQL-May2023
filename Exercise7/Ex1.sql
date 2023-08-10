DELIMITER $$

CREATE PROCEDURE usp_get_employees_salary_above_35000()
BEGIN

     SELECT `first_name`, `last_name`
     FROM `employees`
     WHERE `salary` > 35000
     ORDER BY `first_name`, `last_name`, `employee_id`;
     
END$$


CREATE PROCEDURE usp_get_employees_salary_above (salary_to_compare DECIMAL(10,4))
BEGIN

	 SELECT `first_name`, `last_name`
     FROM `employees`
     WHERE `salary` >= salary_to_compare
     ORDER BY `first_name`, `last_name`, `employee_id`;
     
END$$

DELIMITER $$

CREATE PROCEDURE usp_get_towns_starting_with(string_to_start VARCHAR(50))
BEGIN

	 SELECT `name`
     FROM `towns`
     WHERE `name` LIKE CONCAT(string_to_start, '%')
     ORDER BY `name`;
     
END$$


CREATE PROCEDURE usp_get_employees_from_town(town_name VARCHAR(50))
BEGIN

	 SELECT `first_name`, `last_name`
     FROM `employees` AS e
     JOIN `addresses` AS a
     ON e.`address_id` = a.`address_id`
     JOIN `towns` AS t
     ON a.`town_id` = t.`town_id`
     WHERE t.`name` = town_name
     ORDER BY `first_name`, `last_name`, `employee_id`;
     
END$$


CREATE FUNCTION ufn_get_salary_level(salary DECIMAL(19,4))
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
     DECLARE salary_level VARCHAR(10);
     
     IF salary < 30000 THEN SET salary_level := 'Low';
     ELSEIF salary BETWEEN 30000 AND 50000 THEN SET salary_level := 'Average';
     ELSE SET salary_level := 'High';
     END IF;
     
     RETURN salary_level;
     
END$$

CREATE PROCEDURE usp_get_employees_by_salary_level(salary_level VARCHAR(10))
BEGIN
      SELECT `first_name`, `last_name`
      FROM `employees`
      WHERE `salary_level` = (SELECT ufn_get_salary_level(`salary`))
      ORDER BY `first_name` DESC, `last_name` DESC;
      
END$$


CREATE FUNCTION ufn_is_word_comprised(set_of_letters VARCHAR(50), word VARCHAR(50))
RETURNS INT
DETERMINISTIC
BEGIN

     RETURN word REGEXP(CONCAT('^[', set_of_letters, ']+$'));
END$$



