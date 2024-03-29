CREATE DATABASE `restaurant_db`;

CREATE TABLE `products` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `name` VARCHAR(30) UNIQUE NOT NULL,
 `type` VARCHAR(30) NOT NULL,
 `price` DECIMAL(10,2) NOT NULL
);

CREATE TABLE `clients` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `first_name` VARCHAR(50) NOT NULL,
 `last_name` VARCHAR(50) NOT NULL,
 `birthdate` DATE NOT NULL,
 `card` VARCHAR(50),
 `review` TEXT
);

CREATE TABLE `tables` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `floor` INT NOT NULL,
 `reserved` TINYINT(1),
 `capacity` INT NOT NULL
);

CREATE TABLE `waiters` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `first_name` VARCHAR(50) NOT NULL,
 `last_name` VARCHAR(50) NOT NULL,
 `email` VARCHAR(50) NOT NULL,
 `phone` VARCHAR(50),
 `salary` DECIMAL(10,2)
);

CREATE TABLE `orders` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `table_id` INT NOT NULL,
 `waiter_id` INT NOT NULL,
 `order_time` TIME NOT NULL,
 `payed_status` BOOLEAN,
 CONSTRAINT fk_orders_tables
 FOREIGN KEY (`table_id`)
 REFERENCES `tables`(`id`),
 CONSTRAINT fk_orders_waiters
 FOREIGN KEY (`waiter_id`)
 REFERENCES `waiters`(`id`)
);

CREATE TABLE `orders_clients` (
 `order_id` INT,
 `client_id` INT,
 CONSTRAINT fk_orders_clients_orders
 FOREIGN KEY (`order_id`)
 REFERENCES `orders`(`id`),
 CONSTRAINT fk_orders_clients_clients
 FOREIGN KEY (`client_id`)
 REFERENCES `clients`(`id`)
);

CREATE TABLE `orders_products` (
 `order_id` INT,
 `product_id` INT,
 CONSTRAINT fk_orders_products_orders
 FOREIGN KEY (`order_id`)
 REFERENCES `orders`(`id`),
 CONSTRAINT fk_orders_products_products
 FOREIGN KEY (`product_id`)
 REFERENCES `products`(`id`)
);


INSERT INTO `products` (`name`, `type`, `price`)
SELECT CONCAT(w.`last_name`, ' ', 'specialty'), 'Cocktail',
CEIL(w.`salary` * 0.01)
FROM `waiters` AS w
WHERE w.`id` > 6;


UPDATE `tables` AS t
JOIN `orders` AS o
ON o.`table_id` = t.`id`
SET o.`table_id` = o.`table_id` - 1
WHERE o.`id` BETWEEN 12 AND 23;


DELETE w FROM `waiters` AS w
LEFT JOIN `orders` AS o
ON w.`id` = o.`waiter_id`
WHERE o.`id` IS NULL;

SELECT * FROM `clients`
ORDER BY `birthdate` DESC, `id` DESC;

SELECT `first_name`, `last_name`, `birthdate`, `review`
FROM `clients`
WHERE `card` IS NULL AND YEAR(`birthdate`) BETWEEN 1978 AND 1993
ORDER BY `last_name` DESC, `id`
LIMIT 5;

SELECT CONCAT(`last_name`, `first_name`, char_length(`first_name`), 'Restaurant')
AS 'username',
REVERSE(SUBSTRING(`email`, 2, 12)) AS 'password'
FROM `waiters`
WHERE `salary` IS NOT NULL
ORDER BY `password` DESC;

SELECT p.`id`, p.`name`, COUNT(o.`id`) AS 'count'
FROM `products` AS p
JOIN `orders_products` AS op
ON p.`id` = op.`product_id`
JOIN `orders` AS o
ON o.`id` = op.`order_id`
GROUP BY `name`
HAVING `count` >= 5
ORDER BY `count` DESC, `name`;

SELECT t.`id` AS 'table_id', t.`capacity`,
COUNT(c.`id`) AS 'count_clients',
CASE
WHEN t.`capacity` > COUNT(c.`id`) THEN 'Free seats'
WHEN t.`capacity` = COUNT(c.`id`) THEN 'Full'
ELSE 'Extra seats'
END AS 'availability'  
FROM `tables` AS t
LEFT JOIN `orders` AS o
ON t.`id` = o.`table_id`
LEFT JOIN `orders_clients` AS oc
ON o.`id` = oc.`order_id`
LEFT JOIN `clients` AS c
ON c.`id` = oc.`client_id`
WHERE t.`floor` = 1
GROUP BY t.`id`
HAVING `count_clients` > 0
ORDER BY t.`id` DESC;

DELIMITER $$

CREATE FUNCTION udf_client_bill(full_name VARCHAR(50))
RETURNS DECIMAL(19,2)
DETERMINISTIC
BEGIN

     RETURN (SELECT SUM(p.`price`) 
     FROM `clients` AS c
     JOIN `orders_clients` AS oc
     ON c.`id` = oc.`client_id`
     JOIN `orders` AS o
     ON o.`id` = oc.`order_id`
     JOIN `orders_products` AS op
     ON o.`id` = op.`order_id`
     JOIN `products` AS p
     ON p.`id` = op.`product_id`
     WHERE CONCAT(c.`first_name`, ' ', `last_name`) = full_name);
     
END$$

CREATE PROCEDURE udp_happy_hour(type VARCHAR(50))
BEGIN
	
	 UPDATE `products` SET `price` = `price` - (`price` * 0.2)
     WHERE `price` >= 10 AND `type` = type;
     
END$$