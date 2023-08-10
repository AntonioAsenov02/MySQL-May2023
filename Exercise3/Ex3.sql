SELECT `name`, date_format(`start`, '%Y-%m-%d')
FROM `games`
WHERE YEAR(`start`) IN(2011,2012)
ORDER BY `start`, `name`
LIMIT 50;

SELECT `user_name`, SUBSTRING(`email`, locate('@', `email`) + 1)
AS `email provider`
FROM `users`
ORDER BY `email provider`, `user_name`;

SELECT `user_name`, `ip_address`
FROM `users`
WHERE `ip_address` LIKE '___.1%.%.___'
ORDER BY `user_name`;

SELECT `name` AS `game`,
CASE
WHEN HOUR(`start`) BETWEEN 0 AND 11 THEN 'Morning'
WHEN HOUR(`start`) BETWEEN 12 AND 17 THEN 'Afternoon'
ELSE 'Evening'
END
AS `Part of the Day`,
CASE
WHEN `duration` BETWEEN 0 AND 3 THEN 'Extra Short'
WHEN `duration` BETWEEN 4 AND 6 THEN 'Short'
WHEN `duration` BETWEEN 7 AND 10 THEN 'Long'
ELSE 'Extra Long'
END
AS `Duration`
FROM `games`;
       