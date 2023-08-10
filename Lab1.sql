CREATE DATABASE `gamebar`;

CREATE TABLE `gamebar`.`employees` (
id INT AUTO_INCREMENT PRIMARY KEY,
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL 
);

CREATE TABLE `gamebar`.`categories` (
id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(100) NOT NULL
);

CREATE TABLE `gamebar`.`products` (
id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(100) NOT NULL,
category_id INT NOT NULL
);

USE `gamebar`;

INSERT INTO `employees` (first_name, last_name) VALUES ("Peter", "Petrov");
INSERT INTO `employees` (first_name, last_name) VALUES
  ("John", "Johnson"),
  ("Go", "Gone");
  
ALTER TABLE `employees` 
ADD COLUMN `middle_name` VARCHAR(100);
  
ALTER TABLE `employees`
DROP COLUMN `middle name`;


ALTER TABLE `employees`
MODIFY COLUMN `middle_name` VARCHAR(50);


ALTER TABLE `products`
ADD CONSTRAINT fk_products_categories
FOREIGN KEY `products` (`category_id`)
REFERENCES `categories` (`id`);

  