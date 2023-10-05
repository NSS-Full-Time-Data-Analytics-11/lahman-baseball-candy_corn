--**Initial Questions**
--1. What range of years for baseball games played does the provided database cover? 

SELECT MIN(debut), MAX(finalgame)
FROM people;
-- 1871-05-04,2017-04-03


--2. Find the name and height of the shortest player in the database. 
--How many games did he play in? What is the name of the team for which he played?

SELECT CONCAT(namefirst, ' ', namelast) as full_name, height, teamid, g_all
FROM people
LEFT JOIN appearances as a
USING(playerid)
WHERE height = (SELECT MIN(height)
               FROM people);
--SLA, Eddie Gaedel, height= 43, played in 1 game


--3. Find all players in the database who played at Vanderbilt University. 
--Create a list showing each player’s first and last names as well as the total salary 
--they earned in the major leagues. Sort this list in descending order by the total salary earned. 
--Which Vanderbilt player earned the most money in the majors?

SELECT namefirst,namelast,schoolname,
MONEY(CAST(SUM(DISTINCT salary)AS numeric)) AS sal_total
FROM collegeplaying AS cp
JOIN people
USING(playerid)
JOIN salaries
USING(playerid)
JOIN schools AS s
ON cp.schoolid = s.schoolid
WHERE cp.schoolid = 'vandy' AND schoolname = 'Vanderbilt University'
GROUP BY namelast, namefirst, schoolname
ORDER BY sal_total DESC;


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
ORDER BY sal_total DESC;
-- David Price $81,851,296.00
-- Not sure if the DISTINCT needs to be in there or not.



-- 4.Using the fielding table, group players into three groups based on their position: 
--label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", 
--and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

SELECT SUM(PO) AS put_outs, 
CASE 
	WHEN POS = 'OF' THEN 'Outfield'
  	WHEN POS = 'SS' OR POS LIKE '%B' THEN 'Infield'
  	ELSE 'Battery' END AS group_positions
FROM fielding
WHERE yearid = 2016
GROUP BY group_positions
ORDER BY put_outs DESC;
 
	

-- 5.Find the average number of strikeouts per game by decade since 1920. 
--Round the numbers you report to 2 decimal places. 
--Do the same for home runs per game. Do you see any trends?

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



-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as 
--the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) 
--Consider only players who attempted _at least_ 20 stolen bases.

WITH stealing_bases_2016 AS (SELECT p.namefirst, p.namelast, SUM(b.sb + b.cs) AS total, b.sb
FROM batting AS b INNER JOIN people AS p USING(playerid)
WHERE yearid= '2016' 
GROUP BY p.namefirst, p.namelast, b.sb)

SELECT namefirst,namelast, total, ROUND(((sb::numeric)/(total::numeric)*100),0) AS percetage
FROM stealing_bases_2016
WHERE total >= 20
ORDER BY percetage DESC 
LIMIT 1;



-- 7. From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 
--What is the smallest number of wins for a team that did win the world series? 
--Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. 
--Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

SELECT yearid, name, SUM(w) as game_wins, WSWin as World_Series_Champs
FROM teams
WHERE WSWIN = 'N' AND yearid BETWEEN 1970 AND 2016
GROUP BY yearid, name, World_Series_Champs
ORDER BY game_wins DESC;

SELECT yearid, name, SUM(w) as game_wins, WSWin as World_Series_Champs
FROM teams
WHERE WSWIN = 'Y' AND yearid BETWEEN 1970 AND 2016 AND YEARID !=1981
GROUP BY yearid, name, World_Series_Champs
ORDER BY game_wins;

WITH CTE_N AS (SELECT COUNT(sub1.World_Series_win) as num_maxw_noWS
               FROM (SELECT DISTINCT t.yearid, t.w, t.wswin as World_Series_win
                     FROM teams as t
                     JOIN (SELECT DISTINCT yearid, MAX(w) as highest_games_won 
                           FROM teams 
                           GROUP BY yearid) AS subquery ON subquery.yearid = t.yearid AND subquery.highest_games_won = t.w
                           WHERE t.wswin IS NOT NULL AND t.yearid BETWEEN 1970 AND 2016
                           ORDER BY t.yearid DESC) as sub1
                      WHERE sub1.World_Series_win = 'N'),
CTE_Y AS (SELECT COUNT(sub2.World_Series_win) as num_maxw_WSwin
               FROM (SELECT DISTINCT t.yearid, t.w, t.wswin as World_Series_win
                     FROM teams as t
                     JOIN (SELECT DISTINCT yearid, MAX(w) as highest_games_won 
                           FROM teams 
                           GROUP BY yearid) AS subquery ON subquery.yearid = t.yearid AND subquery.highest_games_won = t.w
                           WHERE t.wswin IS NOT NULL AND t.yearid BETWEEN 1970 AND 2016
                           ORDER BY t.yearid DESC) as sub2
                           WHERE sub2.World_Series_win = 'Y')
SELECT (num_maxw_noWS) as num_maxw_noWS, num_maxw_WSwin, 
ROUND(((CAST(num_maxw_noWS as numeric))/46)*100,2) AS percent_noWS,
ROUND((CAST(num_maxw_WSwin as numeric)/46)*100,2) AS percent_WSwin
FROM CTE_N              
CROSS JOIN CTE_Y



-- 8. Using the attendance figures from the homegames table, 
--find the teams and parks which had the top 5 average attendance per 
--game in 2016 (where average attendance is defined as total attendance divided 
--by number of games). Only consider parks where there were at least 10 games played. 
--Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

SELECT teams.name, park_name, SUM(games) as total_games, 
ROUND(SUM(CAST(homegames.attendance as numeric))/SUM(CAST(games as numeric)),2) as AVG_attendance
FROM homegames
JOIN parks
USING (park)
JOIN teams
ON teams.teamid = homegames.team AND teams.yearid = homegames.year
WHERE year = 2016 AND games >= 10
GROUP BY teams.name, park_name
ORDER BY avg_attendance DESC
LIMIT 5

SELECT teams.name, park_name, SUM(games) as total_games, 
ROUND(SUM(CAST(homegames.attendance as numeric))/SUM(CAST(games as numeric)),2) as AVG_attendance
FROM homegames
JOIN parks
USING(park)
JOIN teams
ON teams.teamid = homegames.team AND teams.yearid = homegames.year
WHERE year = 2016 AND games >= 10
GROUP BY teams.name, park_name
ORDER BY avg_attendance
LIMIT 5



-- 9. Which managers have won the TSN Manager of the Year award in both the 
--National League (NL) and the American League (AL)? Give their full name and the 
--teams that they were managing when they won the award.

WITH CTE_NL AS (SELECT am.playerid, CONCAT(p.namefirst,' ', p.namelast) as full_name, am.awardid, am.lgid, am.yearid, t.name as NL_team
FROM awardsmanagers AS am
JOIN people p
USING (playerid)
JOIN managers m 
USING(yearid, playerid)
JOIN teams t
ON t.teamid = m.teamid AND t.yearid = m.yearid
WHERE am.awardid = 'TSN Manager of the Year' 
AND am.lgid ='NL'
GROUP BY am.playerid, full_name, am.awardid, am.lgid, am.yearid, t.name
ORDER BY am.playerid),

CTE_AL AS (SELECT am2.playerid, CONCAT(p.namefirst,' ', p.namelast) as full_name, am2.awardid, am2.lgid, am2.yearid, t.name as AL_team
FROM awardsmanagers am2
JOIN people p
USING (playerid)
JOIN managers m 
USING(yearid, playerid)
JOIN teams t
ON t.teamid = m.teamid AND t.yearid = m.yearid
WHERE am2.awardid = 'TSN Manager of the Year' 
AND am2.lgid = 'AL'
GROUP BY am2.playerid, full_name, am2.awardid, am2.lgid, am2.lgid, am2.yearid, t.name
ORDER BY am2.playerid)

SELECT CTE_NL.playerid, CTE_AL.full_name, CTE_NL.awardid, 
CTE_NL.lgid as NL, CTE_NL.yearid as NL_year, NL_team,
CTE_AL.lgid as AL, CTE_AL.yearid as AL_year, AL_team
FROM CTE_NL
JOIN CTE_AL
USING(playerid)



-- 10. Find all players who hit their career highest number of home runs in 2016. 
--Consider only players who have played in the league for at least 10 years, and 
--who hit at least one home run in 2016. Report the players' first and last names and the 
--number of home runs they hit in 2016.

WITH stats_2016 AS (SELECT p.namefirst, 
p.namelast, 
b.hr AS hit_hr_in_2016,
EXTRACT(YEAR FROM finalgame::date)- EXTRACT(YEAR FROM debut::date) AS num_of_yrs_playing,
MAX(b.hr)+MAX(pc.hr) AS career_highest_home_runs
FROM people AS p INNER JOIN batting as b USING(playerid)
			     INNER JOIN pitching AS pc ON b.playerid = pc.playerid
					                    AND b.yearid = pc.yearid
WHERE  b.hr>=1 AND b.yearid=2016 AND pc.yearid=2016
GROUP BY p.namefirst, p.namelast, finalgame,debut,b.hr)

SELECT namefirst, namelast, career_highest_home_runs
FROM stats_2016
WHERE num_of_yrs_playing >=10



-- **Open-ended questions**

--11. Is there any correlation between number of wins and team salary? 
--Use data from 2000 and later to answer this question. As you do this 
--analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

SELECT s.teamid, s.playerid, s.yearid, s.lgid, MONEY(CAST(s.salary as numeric)) as salary, t.w AS wins
FROM salaries s
JOIN teams t
USING (teamid,yearid)
WHERE yearid >=2000
ORDER BY yearid DESC, wins DESC;
-- I didn't see any major trend indicating the number of wins correlates to salary amount.
-- It is less about the number of wins but player performance.




