--1. What range of years for baseball games played does the provided database cover? 
SELECT MIN(yearid) AS first_year 
FROM teams 
UNION
SELECT MAX(yearid) 
FROM teams

SELECT MIN(debut), MAX(finalgame)
FROM people

/*
2.Find the name and height of the shortest player in the database. 
--How many games did he play in?
--What is the name of the team for which he played?*/




   SELECT p.namefirst,p.namelast, p.height, ap.g_all, t.name AS team_name
   FROM people AS p INNER JOIN appearances AS ap USING(playerid)
                    INNER JOIN teams AS t USING(teamid)
   WHERE height = (SELECT MIN(height)
				   FROM people)
   GROUP BY p.namefirst,p.namelast, p.height, t.name, ap.g_all

/*
3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names 
as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. 
Which Vanderbilt player earned the most money in the majors?*/

SELECT p.namefirst, p.namelast, sc.schoolname,  SUM(s.salary::numeric)::money AS tot_salary
FROM people as p INNER JOIN salaries AS s USING(playerid )
                 INNER JOIN collegeplaying AS cp USING(playerid)
				 INNER JOIN schools AS sc USING(schoolid)
WHERE sc.schoolname = 'Vanderbilt University'
GROUP BY p.namefirst, p.namelast, sc.schoolname
ORDER BY tot_salary DESC

/*
4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", 
those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of 
putouts made by each of these three groups in 2016.*/


SELECT
CASE 
   WHEN pos = 'OF' THEN 'outfield'
   WHEN pos IN ('SS','1B','2B','3B') THEN 'infield'
   WHEN pos IN ('P','C') THEN 'Battery'
   END AS position, 
   SUM(po) AS total_putouts
FROM fielding
WHERE yearid= '2016'
GROUP BY position




-5. 
SELECT
  ROUND(SUM(b.SO + p.SO + t.SO)::NUMERIC / SUM(t.G) / 10, 2) AS avg_strikeouts_per_game,
  ROUND(SUM(b.HR + p.HR + t.HR)::NUMERIC / SUM(t.G) / 10, 2) AS avg_home_runs_per_game,
  (yearid / 10) * 10 AS decade
FROM
  batting AS b
JOIN pitching AS p USING (yearid)
JOIN teams AS t USING (yearid)
WHERE
  yearid >= 1920
GROUP BY decade
ORDER BY decade;




/*
6.Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which 
are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) 
Consider only players who attempted _at least_ 20 stolen bases.*/

WITH stealing_bases_2016 AS (SELECT p.namefirst, p.namelast, SUM(b.sb + b.cs) AS total, b.sb
FROM batting AS b INNER JOIN people AS p USING(playerid)
WHERE yearid= '2016' 
GROUP BY p.namefirst, p.namelast, b.sb)

SELECT namefirst,namelast, total, ROUND(((sb::numeric)/(total::numeric)*100),0) AS percetage
FROM stealing_bases_2016
WHERE total >= 20
ORDER BY percetage DESC 
LIMIT 1;






/*
8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 
(where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. 
Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.*/

SELECT *
FROM teams

SELECT *
FROM homegames


/*top 10 avg attaendance*/

SELECT park_name,  t.name, (hg.attendance/hg.games) AS avg_attendance
FROM homegames AS hg INNER JOIN parks AS p USING(park)
                     INNER JOIN  teams AS t ON hg.team = t.teamid
					                        AND hg.year = t.yearid
WHERE year='2016' AND games >=10
ORDER BY avg_attendance DESC
LIMIT 5 


/*lowest 5 average attendance*/

SELECT park_name,  t.name, (hg.attendance/hg.games) AS avg_attendance
FROM homegames AS hg INNER JOIN parks AS p USING(park)
                     INNER JOIN  teams AS t ON hg.team = t.teamid
					                        AND hg.year = t.yearid
WHERE year='2016' AND games >=10
ORDER BY avg_attendance ASC
LIMIT 5 

/*
10.  Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league 
for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home 
runs they hit in 2016.*/


SELECT 

EXTRACT(YEAR FROM finalgame::date)- EXTRACT(YEAR FROM debut::date) AS num_of_yrs_playing
FROM people AS p INNER JOIN batting as b USING(playerid)
			     INNER JOIN pitching AS pc USING(playerid)



WITH stats AS (SELECT p.namefirst, b.playerid, pc.playerid,
p.namelast, 
SUM(b.hr+pc.hr) AS total_homeruns,
b.hr,
EXTRACT(YEAR FROM finalgame::date)- EXTRACT(YEAR FROM debut::date) AS num_of_yrs_playing
FROM people AS p INNER JOIN batting as b USING(playerid)
			     INNER JOIN pitching AS pc USING(playerid)
WHERE b.yearid = 2016 AND pc.yearid= 2016  AND b.hr>=1
GROUP BY p.namefirst, p.namelast, finalgame,debut,b.hr,b.playerid, pc.playerid)


SELECT *
FROM stats 
WHERE num_of_yrs_playing >=10


SELECT SUM(b.hr+pc.hr) AS total_homeruns, b.yearid,p.namefirst,p.namelast
FROM people AS p INNER JOIN batting as b USING(playerid)
			     INNER JOIN pitching AS pc USING(playerid)
WHERE p.namelast = 'Colon' AND namefirst='Bartolo'AND b.yearid=2016 AND pc.yearid=2016
GROUP BY b.yearid,p.namefirst,p.namelast
ORDER BY b.yearid ASC



SELECT EXTRACT(YEAR FROM finalgame::date)- EXTRACT(YEAR FROM debut::date) AS num_of_yrs_playing
