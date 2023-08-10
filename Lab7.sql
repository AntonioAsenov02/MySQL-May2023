SELECT COUNT(*)
FROM `employees` AS e
JOIN `addresses` AS a
USING(`address_id`)
JOIN `towns` AS t
ON a.`town_id` = t.`town_id`
WHERE t.`name` = 'Sofia';

SELECT COUNT(*)
FROM `employees` AS e
WHERE e.`address_id` IN (
SELECT `address_id` FROM `addresses` AS a
WHERE a.`town_id` IN (
SELECT `town_id` FROM `towns` AS t
WHERE t.`name` = 'Sofia'
)
);

DELIMITER $$

DROP FUNCTION ufn_count_employees_by_town$$

CREATE FUNCTION ufn_count_employees_by_town(town_name VARCHAR(50))
RETURNS INT
DETERMINISTIC
BEGIN
        DECLARE id_for_town INT;
        DECLARE count_by_town INT;
        
        SET id_for_town := (SELECT `town_id` FROM `towns` WHERE `name` = town_name);
        SET count_by_town := (SELECT COUNT(*)
							 FROM `employees` AS e
                             JOIN `addresses` AS a
							 USING(`address_id`)
                             WHERE `town_id` = id_for_town
		);
     
	 RETURN count_by_town;
END$$

SELECT `ufn_count_employees_by_town`('Sofia')$$

CREATE PROCEDURE usp_raise_salaries(department_name VARCHAR(50))
BEGIN
        
        UPDATE `employees`
        SET `salary` = `salary` * 1.05
        WHERE `department_id` = (
                       SELECT `department_id` FROM `departments`
					   WHERE `name` = department_name
        );
END$$

CALL usp_raise_salaries('Engineering')$$


CREATE PROCEDURE usp_raise_salary_by_id(id INT)
BEGIN
     DECLARE count_by_id INT;
     
     START TRANSACTION;
     SET count_by_id = (SELECT COUNT(*) FROM `employees` WHERE `employee_id` = id);
     
     UPDATE `employees` SET `salary` = `salary` * 1.05 WHERE `employee_id` = id;
     
     IF (count_by_id < 1) THEN
     ROLLBACK;
     ELSE
     COMMIT;
     END IF;
     
END$$


CREATE TABLE `deleted_employees` (
 `employee_id` INT PRIMARY KEY AUTO_INCREMENT,
 `first_name` VARCHAR(50) NOT NULL,
 `last_name` VARCHAR(50) NOT NULL,
 `middle_name` VARCHAR(50) NOT NULL,
 `job_title` VARCHAR(50) NOT NULL,
 `department_id` INT NOT NULL,
 `salary` DECIMAL(19,4)
)$$

CREATE TRIGGER tr_deleted_employees
AFTER DELETE
ON `employees`
FOR EACH ROW
BEGIN
     
     INSERT INTO `deleted_employees` (`employee_id`, `first_name`, `last_name`,
                        `middle_name`, `job_title`, `department_id`, `salary`)
     VALUES(OLD.`employee_id`,
		    OLD.`first_name`,
            OLD.`last_name`,
            OLD.`middle_name`,
            OLD.`job_title`,
            OLD.`department_id`,
            OLD.`salary`);
            
END$$
        