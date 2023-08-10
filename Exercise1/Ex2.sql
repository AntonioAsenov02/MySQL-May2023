CREATE DATABASE `exercise`;

USE `exercise`;

CREATE TABLE `people` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(200) NOT NULL,
  `picture` BLOB,
  `height` DOUBLE (10, 2),
  `weight` DOUBLE (10, 2),
  `gender` CHAR (1) NOT NULL,
  `birthdate` DATE NOT NULL,
  `biography` TEXT
); 

USE `exercise`;

INSERT INTO `people` (`name`, `gender`, `birthdate`)
VALUES
   ("Atanas", 'm', DATE (NOW())),
   ("Antonio", 'm', DATE (NOW())),
   ("Go", 'm', DATE(NOW())),
   ("Jessica", 'f', DATE(NOW())),
   ("Karl", 'm', DATE(NOW()));
   
   
USE `exercise`;

CREATE TABLE `users` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `username` VARCHAR(30) NOT NULL,
  `password` VARCHAR(26) NOT NULL,
  `profile_picture` BLOB,
  `last_login_time` TIME,
  `is_deleted` BOOLEAN
);


USE `exercise`;

INSERT INTO `users` (`username`, `password`, `is_deleted`)
VALUES
	  ("Atanas", "1234", false),
      ("Antonio", "0202", false),
      ("Go", "GONOW", true),
      ("Start", "StartNow", true),
      ("Hey", "HeyNow", false);
      
USE `exercise`;

ALTER TABLE `users`
DROP PRIMARY KEY,
ADD PRIMARY KEY pk_users (`id`, `username`);

USE `exercise`;

ALTER TABLE `users`
MODIFY COLUMN `last_login_time` DATETIME DEFAULT NOW();

USE `exercise`;

ALTER TABLE `users`
DROP PRIMARY KEY,
ADD CONSTRAINT pk_users
PRIMARY KEY `users` (`id`),
MODIFY COLUMN `username` VARCHAR(30) UNIQUE;


