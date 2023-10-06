-- 145/146 Years 1871-2016 seasons, but the 2016 season extends into 2017?
SELECT DISTINCT yearid
FROM managers
ORDER BY yearid ASC
LIMIT 1;


SELECT DISTINCT yearid
FROM managers
ORDER BY yearid DESC
LIMIT 1;


-- Q2

-- Looking For:  Name and height of shortest player (rude),  # of Games, What team he played for
SELECT DISTINCT CONCAT(namefirst,' ',namelast) AS name, height AS height_in_inches, g_all AS games_played,teams.name
FROM people
	INNER JOIN appearances
	USING(playerid)
	INNER JOIN teams
	USING(teamid)
ORDER BY height_in_inches ASC
LIMIT 1;




SELECT * 
FROM appearances
WHERE playerid = 'gaedeed01'



SELECT MIN(debut), MAX(finalgame)
FROM people


-- Find all players in the database who played at Vanderbilt University. 
--Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. 
--Sort this list in descending order by the total salary earned. 
--Which Vanderbilt player earned the most money in the majors?
-- LOOKING FOR: All Vandy players' first and last name, total salaries in the major leagues DESCENDING.
-- which Vandy player earned the most money?

-- Keys: playerid, teamid, schoolid
-- Fields: namefirst,namelast, schoolid, salary DESC, limit 1 
-- Tables: people,collegeplaying,schools

SELECT CONCAT(namefirst,' ',namelast) AS name, MONEY(CAST(SUM(salary)AS numeric)) AS total_salary
FROM people
	INNER JOIN collegeplaying
	USING(playerid)
	INNER JOIN schools
	USING(schoolid)
	INNER JOIN salaries
	USING (playerid)
WHERE schoolid = 'vandy'
GROUP BY name
ORDER BY total_salary DESC;


SELECT namefirst,namelast,schoolname,
MONEY(CAST(SUM(salary)AS numeric)) AS sal_total
FROM collegeplaying AS cp
JOIN people
USING(playerid)
JOIN salaries
USING(playerid)
JOIN schools AS s
ON cp.schoolid = s.schoolid
WHERE cp.schoolid = 'vandy' AND schoolname = 'Vanderbilt University'
GROUP BY namelast, namefirst, schoolname
ORDER BY sal_total DESC
-- David Price $81,851,296.00

--Using the fielding table, group players into three groups based on their position:
--label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", 
--and those with position "P" or "C" as "Battery". 
--Determine the number of putouts made by each of these three groups in 2016.
-- LOOKING FOR: OF as Outfield players,
-- 				SS,1B,2B, and 3B positions as Infield
-- 				P or C as Battery

SELECT
CASE 
	WHEN pos = 'OF' THEN 'Outfield'
	WHEN pos = 'SS' THEN 'Infield'
	WHEN pos = '1B' THEN 'Infield'
	WHEN pos = '2B' THEN 'Infield'
	WHEN pos = '3B' THEN 'Infield'
	WHEN pos = 'P' THEN 'Battery'
	WHEN pos = 'C' THEN 'Battery'
END AS position_group, SUM(po) AS total_putouts
FROM fielding
WHERE yearid = '2016'
GROUP BY position_group;






