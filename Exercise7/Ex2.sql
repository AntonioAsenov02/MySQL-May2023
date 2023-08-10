DELIMITER $$

CREATE PROCEDURE usp_get_holders_full_name()
BEGIN
     SELECT CONCAT(`first_name`, ' ', `last_name`)
     AS 'full_name'
     FROM `account_holders`
     ORDER BY `full_name`, `id`;
END$$


CREATE PROCEDURE usp_get_holders_with_balance_higher_than(balance_comparator INT)
BEGIN
     SELECT ah.`first_name`, ah.`last_name`
     FROM `account_holders` AS ah
     JOIN `accounts` AS a
     ON ah.`id` = a.`account_holder_id`
     GROUP BY a.`account_holder_id`
     HAVING SUM(a.`balance`) > balance_comparator
     ORDER BY ah.`id`;
     
END$$


CREATE FUNCTION ufn_calculate_future_value(sum DECIMAL(19,4), yearly_interest_rate DOUBLE, number_of_years INT)
RETURNS DECIMAL(19,4)
DETERMINISTIC
BEGIN
 
     DECLARE future_sum DECIMAL(19,4);
	 SET future_sum :=  sum * POW(1 + yearly_interest_rate, number_of_years);
     RETURN future_sum;
     
END$$


CREATE PROCEDURE usp_calculate_future_value_for_account(id INT, interest_rate DECIMAL(19,4))
BEGIN
      SELECT a.`id`
      AS 'account_id',
      ah.`first_name`, ah.`last_name`, a.`balance`
      AS 'current_balance',
      ufn_calculate_future_value(a.`balance`, interest_rate, 5)
      AS 'balance_in_5_years'
      FROM `accounts` AS a
      JOIN `account_holders` AS ah
      ON a.`account_holder_id` = ah.`id`
      WHERE a.`id` = id;

END$$


CREATE PROCEDURE usp_deposit_money(account_id INT, money_amount DECIMAL(19,4))
BEGIN
     START TRANSACTION;
     IF money_amount <= 0 THEN
     ROLLBACK;
     ELSE 
     UPDATE `accounts`
     SET `balance` = `balance` + money_amount;
     COMMIT;
     END IF;
END$$

CREATE PROCEDURE usp_withdraw_money(account_id INT, money_amount DECIMAL(19,4))
BEGIN
     START TRANSACTION;
     IF money_amount <= 0  OR (SELECT`balance` FROM `accounts` WHERE `id` = account_id) < money_amount THEN ROLLBACK;
     ELSE
     UPDATE `accounts`
     SET `balance` = `balance` - money_amount
     WHERE `id` = account_id;
     COMMIT;
     END IF;
     
END$$

CREATE PROCEDURE usp_transfer_money(from_account_id INT, to_account_id INT, amount DECIMAL(19,4))
BEGIN

     START TRANSACTION;
     IF (SELECT COUNT(`id`) FROM `accounts` WHERE `id` = from_account_id) < 1 OR
     (SELECT COUNT(`id`) FROM `accounts` WHERE `id` = to_account_id) < 1 OR
     amount <= 0
     OR (SELECT `balance` FROM `accounts` WHERE from_account_id = `id`) < amount OR from_account_id = to_account_id THEN ROLLBACK;
     ELSE
     UPDATE `accounts`
     SET `balance` = `balance` - amount
     WHERE `id` = from_account_id;
     UPDATE `accounts`
     SET `balance` = `balance` + amount
     WHERE `id` = to_account_id;
     COMMIT;
     END IF;
     
END$$

CREATE TABLE `logs` (
 `log_id` INT PRIMARY KEY AUTO_INCREMENT,
 `account_id` INT NOT NULL,
 `old_sum` DECIMAL(19,4) NOT NULL,
 `new_sum` DECIMAL(19,4) NOT NULL
);

DELIMITER $$

CREATE TRIGGER tr_changes_balance_account
AFTER UPDATE ON `accounts`
FOR EACH ROW
BEGIN
     INSERT INTO `logs` (`account_id`, `old_sum`, `new_sum`)
     VALUES (OLD.`id`, OLD.`balance`, NEW.`balance`);
END$$

CREATE TABLE `notification_emails` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `recipient` INT NOT NULL,
 `subject` VARCHAR(500) NOT NULL,
 `body` VARCHAR(500) NOT NULL
);

DELIMITER $$

CREATE TRIGGER tr_creates_email
BEFORE INSERT ON `logs`
FOR EACH ROW
BEGIN
     INSERT INTO `notification_emails` (`recipient`, `subject`, `body`)
     VALUES (NEW.`account_id`, CONCAT('Balance change for account: ', NEW.`account_id`), 
     CONCAT('On ',  NOW(), ' your balance was changed from ', ROUND(NEW.`old_sum`, 0), ' to ', ROUND(NEW.`new_sum`, 0), '.'));
     
END$$

