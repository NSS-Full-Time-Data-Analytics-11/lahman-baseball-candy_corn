-- From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 
-- What is the smallest number of wins for a team that did win the world series?
-- Doing this will probably result in an unusually small number of wins for a world series champion
-- determine why this is the case. Then redo your query, excluding the problem year. 
-- How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? 
-- What percentage of the time?
-- LOOKING FOR: A. largest number of wins for teams that did not win the world series
-- 				B. Smallest number of wins for a team that DID win the world series
--				C. Determine why the result is a very small number of wins for a world series champion, Then redo the query
--				D. How often from 1970 - 2016 was it the case that a team with the most wins also won the world series?
--				E. What is the percentage of this?

--				Tables
--					Teams table
-- 				Fields
--					Yearid,W,WSWinner
--				For A, use the max number of wins where WS winner is N'
--				For B Min number of wins, where WS winner is Y

-- largest number of wins for teams that did not win the world series
SELECT teamid, yearid AS year, name AS team_name, w AS wins
FROM teams
WHERE yearid >= 1970 AND yearid <= 2016 AND wswin = 'N'
ORDER BY w DESC;


--  Smallest number of wins for a team that DID win the world series
SELECT teamid, yearid, name, w
FROM teams
WHERE yearid >= 1970 AND yearid <= 2016 AND wswin = 'Y'
ORDER BY w ASC;

-- Determine why the result is a very small number of wins for a world series champion, Then redo the query
-- Discrepancy created by the 1981 MLB strike

SELECT teamid, yearid, name, w
FROM teams
WHERE yearid >= 1970 
	AND yearid <= 2016 
	AND wswin = 'Y' 
	AND yearid <> 1981
ORDER BY w ASC;


--	D. How often from 1970 - 2016 was it the case that a team with the most wins also won the world series?


SELECT DISTINCT name,yearid
FROM teams
WHERE yearid >= 1970 
	AND yearid <= 2016 
	AND wswin = 'Y'
GROUP BY yearid,name
ORDER BY yearid

WITH max_wins_per_year AS 
(SELECT yearid, MAX(w) AS w
FROM teams
WHERE yearid >= 1970
	AND yearid <=2016
GROUP BY yearid
ORDER BY yearid)

SELECT COUNT(*) AS number_of_years,
COUNT(CASE WHEN wswin = 'Y' THEN 1 ELSE NULL END) AS world_series_winner_had_most_wins, 
COUNT(CASE WHEN wswin = 'N' THEN 1 ELSE NULL END) AS world_series_winner_did_not_have_the_most_wins,
ROUND(((CAST(12 AS numeric)/COUNT(*))*100),2) AS percent
FROM teams
INNER JOIN max_wins_per_year
USING (yearid,w)



-- Ilissa's 
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










