-- Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? 
-- Give their full name and the teams that they were managing when they won the award.

WITH al as(SELECT playerid
			FROM awardsmanagers
			WHERE lgid = 'AL'
			AND awardid = 'TSN Manager of the Year'
		  INTERSECT
 	 SELECT playerid
			FROM awardsmanagers
			WHERE lgid = 'NL'
			AND awardid = 'TSN Manager of the Year')
SELECT DISTINCT(playerid), teamid,
namelast,
namefirst,
awardsmanagers.lgid, yearid,
name as team_name
FROM al
INNER JOIN awardsmanagers USING(playerid)
INNER JOIN people USING (playerid)
INNER JOIN managers USING (yearid, playerid)
INNER JOIN teams USING(yearid, teamid)
WHERE awardid = 'TSN Manager of the Year'

