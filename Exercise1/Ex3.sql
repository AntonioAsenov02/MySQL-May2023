CREATE DATABASE `Movies`;

USE `Movies`;

CREATE TABLE `directors` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`director_name` VARCHAR(500) NOT NULL,
`notes` VARCHAR(1000)
); 

USE `Movies`;

CREATE TABLE `genres` (
 `id` INT PRIMARY KEY AUTO_INCREMENT,
 `genre_name` VARCHAR(50) NOT NULL,
 `notes` VARCHAR(1000)
);

USE `Movies`;

CREATE TABLE `categories` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `category_name` VARCHAR(100) NOT NULL,
  `notes` VARCHAR(1000)
);

USE `Movies`;

CREATE TABLE `movies` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `title` VARCHAR(100) NOT NULL,
  `director_id` INT,
  `copyright_year` DATE,
  `length` DOUBLE,
  `genre_id` INT,
  `category_id` INT,
  `rating` DOUBLE,
  `notes` VARCHAR(1000)
);

INSERT INTO `categories` (`category_name`, `notes`)
VALUES ("Best movie", "The best one"),
       ("Best picture", "The best picture"),
       ("Best director", "The best director"),
       ("Best actor", "The best actor"),
       ("Best writer", "The best writer");
       
       
INSERT INTO `directors` (`director_name`, `notes`)
VALUES ("Best movie", "The best one"),
       ("Best picture", "The best picture"),
       ("Best director", "The best director"),
       ("Best actor", "The best actor"),
       ("Best writer", "The best writer");
       
       
INSERT INTO `genres` (`genre_name`, `notes`)
VALUES ("Best movie", "The best one"),
       ("Best picture", "The best picture"),
       ("Best director", "The best director"),
       ("Best actor", "The best actor"),
       ("Best writer", "The best writer");
       
       
INSERT INTO `movies` (`title`, `notes`)
VALUES ("Best movie", "The best one"),
       ("Best picture", "The best picture"),
       ("Best director", "The best director"),
       ("Best actor", "The best actor"),
       ("Best writer", "The best writer");
       
       