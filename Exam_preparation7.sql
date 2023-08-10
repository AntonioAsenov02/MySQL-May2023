CREATE DATABASE `softuni_stores_system`;

CREATE TABLE `pictures` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `url` VARCHAR(100) NOT NULL,
 `added_on` DATETIME NOT NULL
);

CREATE TABLE `categories` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `name` VARCHAR(40) UNIQUE NOT NULL
);

CREATE TABLE `products` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `name` VARCHAR(40) UNIQUE NOT NULL,
 `best_before` DATE,
 `price` DECIMAL(10,2) NOT NULL,
 `description` TEXT,
 `category_id` INT NOT NULL,
 `picture_id` INT NOT NULL,
 CONSTRAINT fk_products_categories
 FOREIGN KEY (`category_id`)
 REFERENCES `categories`(`id`),
 CONSTRAINT fk_products_pictures
 FOREIGN KEY (`picture_id`)
 REFERENCES `pictures`(`id`)
);

CREATE TABLE `towns` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `name` VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE `addresses` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `name` VARCHAR(50) UNIQUE NOT NULL,
 `town_id` INT NOT NULL,
 CONSTRAINT fk_addresses_towns
 FOREIGN KEY (`town_id`)
 REFERENCES `towns`(`id`)
);

CREATE TABLE `stores` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `name` VARCHAR(20) UNIQUE NOT NULL,
 `rating` FLOAT NOT NULL,
 `has_parking` BOOLEAN DEFAULT FALSE,
 `address_id` INT NOT NULL,
 CONSTRAINT fk_stores_addresses
 FOREIGN KEY (`address_id`)
 REFERENCES `addresses`(`id`)
);

CREATE TABLE `products_stores` (
 `product_id` INT NOT NULL,
 `store_id` INT NOT NULL,
 PRIMARY KEY (`product_id`, `store_id`),
 CONSTRAINT fk_products_stores_products
 FOREIGN KEY (`product_id`)
 REFERENCES `products`(`id`),
 CONSTRAINT fk_products_stores_stores
 FOREIGN KEY (`store_id`)
 REFERENCES `stores`(`id`)
);

CREATE TABLE `employees` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `first_name` VARCHAR(15) NOT NULL,
 `middle_name` CHAR(1),
 `last_name` VARCHAR(20) NOT NULL,
 `salary` DECIMAL(19,2) DEFAULT 0,
 `hire_date` DATE NOT NULL,
 `manager_id` INT,
 `store_id` INT NOT NULL,
 CONSTRAINT fk_employees_employees
 FOREIGN KEY (`manager_id`)
 REFERENCES `employees`(`id`),
 CONSTRAINT fk_employees_stores
 FOREIGN KEY (`store_id`)
 REFERENCES `stores`(`id`)
);


INSERT INTO `products_stores` (`product_id`, `store_id`)
SELECT p.`id`, 1
FROM `products` AS p
LEFT JOIN `products_stores` AS ps
ON p.`id` = ps.`product_id`
WHERE ps.`product_id` IS NULL;


UPDATE `employees` AS e
JOIN `stores` AS s
ON s.`id` = e.`store_id` 
SET `salary` = `salary` - 500, e.`manager_id` = 3
WHERE YEAR(e.`hire_date`) >= 2003 AND s.`name` NOT IN('Cardguard', 'Veribet');


DELETE e FROM `employees` AS e
WHERE `id` <> `manager_id` AND `salary` > 6000;

SELECT `first_name`, `middle_name`, `last_name`, `salary`, `hire_date`
FROM `employees`
ORDER BY `hire_date` DESC;

SELECT p.`name` AS 'product_name', p.`price`,
p.`best_before`, CONCAT(SUBSTRING(p.`description`,1,10), '...')
AS 'short_description', pic.`url`
FROM `products` AS p
JOIN `pictures` AS pic
ON pic.`id` = p.`picture_id`
WHERE char_length(p.`description`) > 100 AND
YEAR(pic.`added_on`) < 2019 AND p.`price` > 20
ORDER BY p.`price` DESC;


SELECT s.`name`, COUNT(p.`id`) AS `product_count`,
ROUND(AVG(p.`price`),2) AS 'avg'
FROM `stores` AS s
LEFT JOIN `products_stores` AS ps
ON s.`id` = ps.`store_id`
LEFT JOIN `products` AS p
ON p.`id` = ps.`product_id`
GROUP BY s.`id`
ORDER BY `product_count` DESC, `avg` DESC, s.`id`;

SELECT CONCAT(e.`first_name`, ' ', `last_name`) AS 'Full_name',
s.`name` AS 'Store_name', a.`name` AS 'address', e.`salary`
FROM `employees` AS e
JOIN `stores` AS s
ON s.`id` = e.`store_id`
JOIN `addresses` AS a
ON a.`id` = s.`address_id`
WHERE e.`salary` < 4000 AND a.`name` LIKE '%5%'
AND char_length(s.`name`) > 8 AND e.`last_name` LIKE '%n';

SELECT REVERSE(s.`name`) AS 'reversed_name',
CONCAT(UPPER(t.`name`), '-', a.`name`) AS 'full_address',
COUNT(e.`id`) AS 'employees_count'
FROM `stores` AS s
LEFT JOIN `employees` AS e
ON s.`id` = e.`store_id`
JOIN `addresses` AS a
ON a.`id` = s.`address_id`
JOIN `towns` AS t
ON t.`id` = a.`town_id`
GROUP BY s.`id`
HAVING `employees_count` >= 1
ORDER BY `full_address`;

DELIMITER $$

CREATE FUNCTION udf_top_paid_employee_by_store(store_name VARCHAR(50))
RETURNS TEXT
DETERMINISTIC
BEGIN

     RETURN (SELECT CONCAT(`first_name`, ' ', `middle_name`, '. ', `last_name`, ' works in store for ', '2020' - YEAR(`hire_date`), ' years')
     FROM `employees` AS e
     JOIN `stores` AS s
     ON s.`id` = e.`store_id`
     WHERE s.`name` = store_name
     ORDER BY e.`salary` DESC
     LIMIT 1);
     
END$$


CREATE PROCEDURE udp_update_product_price (address_name VARCHAR (50))
BEGIN

     UPDATE `addresses` AS a
     JOIN `stores` AS s
     ON a.`id` = s.`address_id`
     JOIN `products_stores` AS ps
     ON s.`id` = ps.`store_id`
     JOIN `products` AS p
     ON p.`id` = ps.`product_id`
     SET p.`price` =  IF (a.`name` LIKE '0%',p.`price` + 100, p.`price` + 200)
     WHERE a.`name` = address_name;
     
END$$

CALL udp_update_product_price('07 Armistice Parkway');
SELECT name, price FROM products WHERE id = 15;
