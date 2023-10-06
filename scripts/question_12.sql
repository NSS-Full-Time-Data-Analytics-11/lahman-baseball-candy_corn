--  In this question, you will explore the connection between number of wins and attendance.
-- <ol type="a">
-- <li>Does there appear to be any correlation between attendance at home games and number wins? </li>
-- <li>Do teams that win the world series see a boost in attendance the following year? 
-- What about teams that made the playoffs? 
-- Making the playoffs means either being a division winner or a wild card winner.</li>

-- Find higher and lower than average attendance

WITH yearly_avgs AS (SELECT yearid,AVG(w) AS yearly_avg_wins ,AVG(attendance) AS yearly_avg_attendance
FROM teams
WHERE yearid > 2005
GROUP BY yearid
ORDER BY yearid),

team_avgs AS (SELECT name,AVG(w) AS team_avg_wins ,AVG(attendance) AS team_avg_attendance
FROM teams
WHERE yearid > 2005
GROUP BY name
ORDER BY name)

SELECT yearid,name,
CASE WHEN team_avg_wins > yearly_avg_wins THEN 'Higher than average wins' ELSE 'Lower than average wins'
	 END AS avg_win_report,
CASE WHEN team_avg_attendance > yearly_avg_attendance THEN 'Higher then average attendance' ELSE 'Lower than average attendance'
	 END AS avg_attendance_report
FROM teams
INNER JOIN team_avgs
USING(name)
INNER JOIN yearly_avgs
USING(yearid)
GROUP BY yearid,name,avg_win_report,avg_attendance_report
ORDER BY yearid


-- Count correlation between highs and lows

WITH yearly_avgs AS (SELECT yearid,AVG(w) AS yearly_avg_wins ,AVG(attendance) AS yearly_avg_attendance
FROM teams
WHERE yearid > 2005
GROUP BY yearid
ORDER BY yearid),

team_avgs AS (SELECT name,AVG(w) AS team_avg_wins ,AVG(attendance) AS team_avg_attendance
FROM teams
WHERE yearid > 2005
GROUP BY name
ORDER BY name),

win_report AS (SELECT yearid,name,
CASE WHEN team_avg_wins > yearly_avg_wins THEN 'Higher than average wins' ELSE 'Lower than average wins'
	 END AS avg_win_report,
CASE WHEN team_avg_attendance > yearly_avg_attendance THEN 'Higher than average attendance' ELSE 'Lower than average attendance'
	 END AS avg_attendance_report
FROM teams
INNER JOIN team_avgs
USING(name)
INNER JOIN yearly_avgs
USING(yearid)
GROUP BY yearid,name,avg_win_report,avg_attendance_report)


SELECT COUNT(win_report) AS total_count, (SELECT COUNT(avg_attendance_report) FROM win_report WHERE avg_win_report = 'Higher than average wins' AND avg_attendance_report = 'Higher than average attendance')
FROM win_report

-- Only about a third of teams with high wins also had high attendance

	
			




--Do teams that win the world series see a boost in attendance the following year?
WITH wswinners AS 
(SELECT yearid,name AS team,AVG(attendance) AS avg_attendance_wy, AVG(w) AS avg_win_wy,SUM(yearid+1) AS next_year
FROM teams
WHERE wswin = 'Y' AND yearid > 2005
GROUP BY yearid,name)

SELECT yearid AS winning_year,
team,
ROUND(AVG(attendance),2) AS wy_avg_attendance,
ROUND(AVG(w),2) AS wy_avg_wins,
ROUND((SELECT AVG(attendance) FROM teams WHERE yearid = next_year AND name = team),2) AS ny_avg_attendance,
ROUND((SELECT AVG(w) FROM teams WHERE name = team AND yearid = next_year),2) AS ny_avg_wins,
CASE WHEN (SELECT AVG(attendance) FROM teams WHERE yearid = next_year AND name = team) > AVG(attendance) THEN 'Higher attendance after winning' 
	 WHEN (SELECT AVG(attendance) FROM teams WHERE yearid = next_year AND name = team) < AVG(attendance) THEN 'Lower attendance after winning' 
	 ELSE 'Unknown' 
	 END AS attendance_after_winning
FROM teams
INNER JOIN wswinners
USING(yearid)
WHERE yearid > 2005
GROUP BY yearid,team,next_year



-- What about teams that made the playoffs? 
-- Making the playoffs means either being a division winner or a wild card winner.</li>
-- WHERE WCWin and DIV win = Y



























