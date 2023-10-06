-- Find all players in the database who played at Vanderbilt University. 
--Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. 
--Sort this list in descending order by the total salary earned. 
--Which Vanderbilt player earned the most money in the majors?
-- LOOKING FOR: All Vandy players' first and last name, total salaries in the major leagues DESCENDING.
-- which Vandy player earned the most money?

-- Keys: playerid, teamid, schoolid
-- Fields: namefirst,namelast, schoolid, salary DESC, limit 1 
-- Tables: people,collegeplaying,schools

SELECT CONCAT(namefirst,' ',namelast) AS name, SUM(salary) AS total_salary
FROM people
	INNER JOIN collegeplaying
	USING(playerid)
	INNER JOIN schools
	USING(schoolid)
	INNER JOIN salaries
	USING (playerid)
WHERE schoolid = 'vandy'
GROUP BY name
ORDER BY total_salary DESC
LIMIT 1;










