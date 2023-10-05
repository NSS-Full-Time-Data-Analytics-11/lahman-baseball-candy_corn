--Lahman Baseball Query
--1. What range of years for baseball games played does the provided database cover?
SELECT MIN(debut), MAX(finalgame)
FROM people

--2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for wich he played?
SELECT DISTINCT namefirst, namelast, name, height, g_all AS num_game_played
FROM people INNER JOIN appearances USING(playerid)
			INNER JOIN teams USING(teamid)
WHERE height = (SELECT MIN(height)
			   FROM people)
GROUP BY namefirst, namelast, name, height, g_all;


--3. Find all players in the database who played at Vanderbuilt University. Create a list showing each players first and last name as well as the total salary they earned in the major leagues. Sort the list in decending order by the total salary earned. Whcih Vanderbuilt player earned the most money in the majors?
SELECT namefirst, namelast, schoolname, SUM(salary)::numeric::money AS salary
FROM people INNER JOIN collegeplaying USING(playerid)
			INNER JOIN schools USING(schoolid)
			INNER JOIN salaries USING(playerid)
WHERE schoolname = 'Vanderbilt University'
GROUP BY namefirst, namelast, schoolname
ORDER BY salary DESC;

--4. Using the fielding table, group the player into three groups based on their position: label players with position OF as "Outfield", those with positin "SS", "1B, "2B, and "3B" as "Infield" and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016
WITH position_type AS (SELECT pos, po,yearid,
					   (CASE WHEN pos = 'OF' THEN 'Outfield'
								  WHEN pos = 'SS' OR pos = '1B' OR pos = '2B' OR pos= '3B' THEN 'Infield'
								  WHEN pos = 'P' OR pos = 'C' THEN 'Battery'
								  END) AS position
					  FROM fielding)
SELECT position, SUM(po) AS num_of_putouts
FROM position_type
WHERE yearid='2016'
GROUP BY position;

--5. Find the average number of strikeouts per game by decade since 1920. Round the number you report to the 2 decimal places. Do the same for home runs per game. Do you see any trends? 
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
--6. 
WITH stealing_bases_2016 AS (SELECT p.namefirst, p.namelast, SUM(b.sb + b.cs) AS total, b.sb
							 FROM batting AS b INNER JOIN people AS p USING(playerid)
							 WHERE yearid= '2016' 
							 GROUP BY p.namefirst, p.namelast, b.sb)
SELECT namefirst,namelast, total, ROUND(((sb::numeric)/(total::numeric)*100),0) AS percetage
FROM stealing_bases_2016
WHERE total >= 20
ORDER BY percetage DESC 
LIMIT 1;
--7. 
--Most games won by a team that did not win a world series
SELECT teamid, yearid AS year, name AS team_name, w AS wins
FROM teams
WHERE yearid >= 1970 AND yearid <= 2016 AND wswin = 'N'
ORDER BY w DESC
LIMIT 1;


SELECT *
FROM teams;
--Least number of games won for a team that won the world series
SELECT name, SUM(w) AS total_wins, yearid
FROM teams
WHERE wswin = 'Y' AND yearid > 1970
GROUP BY name, yearid
ORDER BY total_wins ASC
LIMIT 1;
--Fix for the discrepency in 1981
SELECT teamid, yearid, name, w
FROM teams
WHERE yearid >= 1970 
	AND yearid <= 2016 
	AND wswin = 'Y' 
	AND yearid <> 1981
ORDER BY w ASC;

--8. Using the attendance figures from the homegames table, find the teams and parks which had the top five average attendance per game in 2016 (where average attendance is defined as total attendance divided by mumber of games).Only consider parks where there were atleast 1- games played. Report the park name, team name and average attendance. Repeat for the lowest 5 average attendance. 

--9. Which managers have won the TSN Manager of the Year award in both the National League and the American League? Give their full name and the teams that they were managing when they won the award.
SELECT namefirst, namelast, name, awardid, a.lgid, a.yearid
FROM awardsmanagers AS a INNER JOIN people AS p ON p.playerid=a.playerid
					INNER JOIN managershalf AS m ON m.playerid=a.playerid 
					INNER JOIN teams AS t ON t.yearid = a.yearid 
WHERE awardid = 'TSN Manager of the Year' AND (a.lgid = 'AL' OR a.lgid = 'NL')
ORDER BY p.namefirst; 

--10. Find all players who hit their career highest number of home runs in 2016. COnsider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players first and last names and the number of home runs they hit in 2016. 
WITH stats_2016 AS (SELECT p.namefirst, p.namelast, b.hr AS hit_hr_in_2016,
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

--11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may wantt to look on a year-by-year basis.



			 