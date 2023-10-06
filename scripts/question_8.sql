-- 8. Using the attendance figures from the homegames table, 
-- find the teams and parks which had the top 5 average attendance per game in 2016 
-- (where average attendance is defined as total attendance divided by number of games). 
-- Only consider parks where there were at least 10 games played. 
-- Report the park name, team name, and average attendance. 
-- Repeat for the lowest 5 average attendance.

-- LOOKING FOR: Team and parks with the top 5 average attendance per game in 2016 total attendance/# of games 
-- Only consider parks where at least 10 games played 
-- RETURN the park name, team name, avg attendance
-- Find the lowest 5 avg attendance


SELECT attendance/games AS avg_attendance
FROM homegames
WHERE year = '2016'

SELECT *
FROM homegames 
