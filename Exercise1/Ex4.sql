CREATE DATABASE `car_rental`;

USE `car_rental`;

CREATE TABLE `categories` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `category` VARCHAR(100) NOT NULL,
  `daily_rate` DOUBLE,
  `weekly_rate` DOUBLE,
  `monthly_rate` DOUBLE,
  `weekend_rate` DOUBLE
);

CREATE TABLE `cars` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `plate_number` VARCHAR(100) NOT NULL,
  `make` VARCHAR(50),
  `model` VARCHAR(50),
  `car_year` DATE,
  `category_id` INT,
  `doors` INT,
  `picture` BLOB,
  `car_condition` VARCHAR(10),
  `available` BOOLEAN
);

CREATE TABLE `employees` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `first_name` VARCHAR(50) NOT NULL,
  `last_name` VARCHAR(100),
  `title` VARCHAR(100),
  `notes` VARCHAR(1000)
);

CREATE TABLE `customers` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `driver_licence_number` INT NOT NULL,
  `full_name` VARCHAR(200),
  `address` VARCHAR(300),
  `city` VARCHAR(100),
  `zip_code` INT,
  `notes` VARCHAR(1000)
);


CREATE TABLE `rental_orders` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `employee_id` INT NOT NULL,
  `customer_id` INT NOT NULL,
  `car_id` INT NOT NULL,
  `car_condition` VARCHAR(10),
  `tank_level` INT,
  `kilometrage_start` INT,
  `kilometrage_end` INT,
  `total_kilometrage` INT,
  `start_date` DATE,
  `end_date` DATE,
  `total_days` INT,
  `rate_applied` INT,
  `tax_rate` DOUBLE,
  `order_status` VARCHAR(20),
  `notes` VARCHAR(1000)
);

USE `car_rental`;

INSERT INTO `cars` (`plate_number`, `make`)
VALUES ("1234", "Mercedes"),
       ("1233", "BMW"),
       ("1323", "Audi");
       
       
INSERT INTO `categories` (`category`)
VALUES ("Van"),
       ("Bus"),
       ("Truck");
       
       
INSERT INTO `customers` (`driver_licence_number`)
VALUES (1234),
       (1233),
       (1323);
       
       
INSERT INTO `employees` (`first_name`, `last_name`)
VALUES ("Atanas", "Petrov"),
       ("Peter", "Petrov"),
       ("John", "Atanasov");
       
INSERT INTO `rental_orders` (`employee_id`, `customer_id`, `car_id`)
VALUES (1,10,1234),
       (2,23,1233),
       (3,27,1323);
       
       