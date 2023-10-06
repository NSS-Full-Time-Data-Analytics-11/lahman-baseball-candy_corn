-- Find all players who hit their career highest number of home runs in 2016. 
-- Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. 
-- Report the players' first and last names and the number of home runs they hit in 2016.

-- Year = 2016, batting table, group by playerid, max homeruns, IF debut has YEAR 2006
-- Return first and last names and number of home runs hit in 2016

-- To find the year of their highest amt of home runs. 
-- We want to return the player name and year
-- Which year, for this player, did they have the highest number of homeruns?

WITH debut_year AS 
SELECT DISTINCT CONCAT(namefirst,' ',namelast) AS name, MAX(b.hr) AS max_home_runs
FROM people AS p1
	INNER JOIN debut_year AS d USING(playerid)
	--INNER JOIN First_years AS f USING(playerid)
	INNER JOIN batting AS b USING(playerid) 
WHERE yrs_playing >= 10 AND b.yearid = 2016 AND b.hr > 1
	GROUP BY name
	ORDER BY max_home_runs DESC


SELECT DISTINCT playerid, MAX(hr) AS most_homeruns
FROM batting
WHERE yearid = 2016 AND hr > 1
GROUP BY playerid

-- Gives you every batter by their first year in the game.
-- How can this help?
-- If we want to find the max hr then we can find the year of their greatest amount of homeruns and then add it to the table.
-- Inner join the batting table with this table then group by playerids, first_years, and year of their max homeruns


SELECT DISTINCT playerid, MAX(b.hr)+MAX(p.hr) AS most_homeruns
FROM batting AS b
INNER JOIN pitching AS p
USING(playerid)
WHERE b.yearid = 2016 AND p.yearid = 2016 AND p.hr > 1 AND b.hr > 1
GROUP BY playerid



WITH stats_2016 AS (SELECT DISTINCT CONCAT(namefirst,' ',namelast) AS name,
b.hr AS hit_hr_in_2016,
EXTRACT(YEAR FROM finalgame::date)- EXTRACT(YEAR FROM debut::date) AS num_of_yrs_playing,
MAX(b.hr) AS career_highest_home_runs
FROM people AS p INNER JOIN batting as b USING(playerid)
WHERE  b.hr>1 AND yearid=2016 
GROUP BY name, finalgame,debut,b.hr)

SELECT name, career_highest_home_runs
FROM stats_2016
WHERE num_of_yrs_playing >=10














EXTRACT(YEAR FROM finalgame::date)- EXTRACT(YEAR FROM debut::date)








