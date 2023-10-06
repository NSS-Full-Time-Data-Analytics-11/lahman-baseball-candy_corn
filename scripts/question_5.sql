-- Find the average number of strikeouts per game by decade since 1920. 
-- Round the numbers you report to 2 decimal places. 
-- Do the same for home runs per game. Do you see any trends?

-- LOOKING FOR: avg strikeouts per game by decade since 1920, round to 2 decimal places. Then do the same for home runs.
-- KEYS: Year ID
-- TABLES: Batting
-- FIELDS: Decade column, Game, Avg Strikeouts

SELECT *,
CASE 
	WHEN yearid LIKE '%187%' THEN '1870s'
	WHEN yearid LIKE '188%' THEN '1880s'
	WHEN yearid Like '189%' THEN '1890s'
	WHEN yearid LIKE '190%' THEN '1900s'
	WHEN yearid LIKE '191%' THEN '1910s'
	WHEN yearid LIKE '192%' THEN '1920s'
	WHEN yearid LIKE '193%' THEN '1930s'
	WHEN yearid LIKE '194%' THEN '1940s'
	WHEN yearid LIKE '195%' THEN '1950s'
	WHEN yearid LIKE '196%' THEN '1960s'
	WHEN yearid LIKE '197%' THEN '1970s'
	WHEN yearid LIKE '198%' THEN '1980s'
	WHEN yearid LIKE '199%' THEN '1990s'
	WHEN yearid LIKE '200%' THEN '2000s'
	WHEN yearid LIKE '201%' THEN '2010s'
	END AS decade
FROM batting

SELECT 
FROM pitching