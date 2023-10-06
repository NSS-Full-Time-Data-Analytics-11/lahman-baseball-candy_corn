-- Looking For:  Name and height of shortest player (rude),  # of Games, What team he played for
SELECT DISTINCT CONCAT(namefirst,' ',namelast) AS name, height AS height_in_inches,g_all,teams.name
FROM people
INNER JOIN appearances
USING(playerid)
INNER JOIN teams
USING(teamid)
ORDER BY height_in_inches ASC
LIMIT 1;



