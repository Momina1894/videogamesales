CREATE DATABASE dbproject
USE dbproject

-- Adding reference foreign keys
ALTER TABLE games ADD CONSTRAINT FK_Games_Platform FOREIGN KEY (Platform_ID) REFERENCES Platforms(Platform_ID)
ALTER TABLE games ADD CONSTRAINT FK_Games_Publisher FOREIGN KEY (Publisher_ID) REFERENCES Publishers(Publisher_ID)
ALTER TABLE games ADD CONSTRAINT FK_Games_Developer FOREIGN KEY (Developer_ID) REFERENCES Developers(Developer_ID)
ALTER TABLE scores ADD CONSTRAINT FK_Scores_Game FOREIGN KEY (Game_ID) REFERENCES Games(Game_ID)

-- Viewing the data
SELECT * FROM developers
SELECT * FROM games
SELECT * FROM platforms
SELECT * FROM publishers
SELECT * FROM scores

-- (Overall View of Data)
SELECT TOP 10 
	games.Game_ID,
    games.Name,
    platforms.Platform,
    publishers.Publisher,
    developers.Developer,
    scores.Total_Shipped,
    scores.Critic_Score,
    scores.User_Score
FROM games
JOIN platforms ON games.Platform_ID = platforms.Platform_ID
JOIN publishers ON games.Publisher_ID = publishers.Publisher_ID
JOIN developers ON games.Developer_ID = developers.Developer_ID
JOIN scores ON games.Game_ID = scores.Game_ID
WHERE scores.Critic_Score IS NOT NULL AND scores.User_Score IS NOT NULL
ORDER BY scores.Total_Shipped DESC

-- Task 1 (Sum of total units shipped, average critic score, average user score)
SELECT COUNT (DISTINCT(games.Name)) AS Number_Of_Games, SUM(scores.Total_Shipped) AS Total_Units_Shipped, AVG(scores.Critic_Score) AS Average_Critic_Score, AVG(scores.User_Score) AS Average_User_Score
FROM games
JOIN scores ON games.Game_ID = scores.Game_ID
WHERE scores.Critic_Score IS NOT NULL AND scores.User_Score IS NOT NULL

-- Task 2 (Identify the top-selling games based on total shipped across different years and platforms)
SELECT games.Year, platforms.Platform, games.Name AS Most_Shipped_Game, scores.Total_Shipped
FROM games
JOIN scores ON games.Game_ID = scores.Game_ID
JOIN platforms ON games.Platform_ID = platforms.Platform_ID
WHERE scores.Total_Shipped IN (SELECT MAX(s1.Total_Shipped) FROM games g1
JOIN scores s1 ON g1.Game_ID = s1.Game_ID
WHERE g1.Year = games.Year OR g1.Platform_ID = games.Platform_ID
GROUP BY g1.Year, g1.Platform_ID)
ORDER BY scores.Total_Shipped DESC

-- Task 3 (Average critic and user scores across different platforms)
SELECT platforms.Platform, 
       ROUND(AVG(scores.Critic_Score), 2) AS Avg_Critic_Score, 
       ROUND(AVG(scores.User_Score), 2) AS Avg_User_Score
FROM games 
JOIN scores ON games.Game_ID = scores.Game_ID
JOIN platforms ON games.Platform_ID = platforms.Platform_ID
WHERE scores.Critic_Score IS NOT NULL AND scores.User_Score IS NOT NULL
GROUP BY platforms.Platform
ORDER BY Avg_Critic_Score DESC

-- Task 4 (Examine the top publishers and developers based on the number of games released and their average scores, 
-- highlighting those with the highest-rated and most successful games.)
SELECT developers.Developer, publishers.Publisher, COUNT(games.Game_ID) AS Games_Released, ROUND(AVG(ISNULL(scores.Critic_Score, 0)), 2) 
AS Avg_Critic_Score, ROUND(AVG(ISNULL(scores.User_Score, 0)), 2) AS Avg_User_Score, ROUND(SUM(ISNULL(scores.Total_Shipped, 0)), 2) AS Total_Shipped
FROM games JOIN developers ON games.Developer_ID = developers.Developer_ID JOIN publishers ON games.Publisher_ID = publishers.Publisher_ID
JOIN scores ON scores.Game_ID = games.Game_ID
WHERE scores.Critic_Score IS NOT NULL AND scores.User_Score IS NOT NULL
GROUP BY developers.Developer, publishers.Publisher
ORDER BY Games_Released DESC

-- Task 5 (Analyse total units shipped and the number of games released per year to identify peak periods in the video game industry.)
SELECT SUM(scores.Total_Shipped) AS Total_Units_Shipped, COUNT(games.Game_ID) AS Games_Released, games.Year
FROM games JOIN scores ON scores.Game_ID = games.Game_ID
GROUP BY games.Year
ORDER BY games.Year DESC

-- Task 6 (Compare Critic vs. User scores)
SELECT games.Name AS Game_Name, platforms.Platform, developers.Developer, scores.Critic_Score, scores.User_Score, (scores.Critic_Score - scores.User_Score) AS Score_Discrepancy
FROM games JOIN scores ON games.Game_ID = scores.Game_ID JOIN platforms ON games.Platform_ID = platforms.Platform_ID
JOIN developers ON developers.Developer_ID = games.Developer_ID
WHERE scores.Critic_Score IS NOT NULL AND scores.User_Score IS NOT NULL
ORDER BY Score_Discrepancy DESC, Game_Name

-- Task 7 (Group games into broad categories based on their titles or known genres and analyse sales distribution among these groups)
CREATE TABLE GameCategories (
    Total_Sales FLOAT,
    Category NVARCHAR(150)
)

-- Inserting data for 'Sports Games'
INSERT INTO GameCategories (Total_Sales, Category)
SELECT SUM(scores.Total_Shipped), 'Sports Games'
FROM games 
JOIN scores ON games.Game_ID = scores.Game_ID
WHERE games.Name LIKE '%Sports%';

-- Inserting data for 'Platformers'
INSERT INTO GameCategories (Total_Sales, Category)
SELECT SUM(scores.Total_Shipped), 'Platformers'
FROM games 
JOIN scores ON games.Game_ID = scores.Game_ID
WHERE games.Name LIKE '%Mario%';

-- Inserting data for 'Shooter/Multiplayer'
INSERT INTO GameCategories (Total_Sales, Category)
SELECT SUM(scores.Total_Shipped), 'Shooter/Multiplayer'
FROM games 
JOIN scores ON games.Game_ID = scores.Game_ID
WHERE games.Name LIKE '%Counter-Strike%' OR games.Name LIKE '%Battlegrounds%'

-- Inserting data for 'RPG'
INSERT INTO GameCategories (Total_Sales, Category)
SELECT SUM(scores.Total_Shipped), 'RPG'
FROM games 
JOIN scores ON games.Game_ID = scores.Game_ID
WHERE games.Name LIKE '%Final Fantasy%' OR games.Name LIKE '%Dragon Age%' OR games.Name LIKE '%The Witcher%'

-- Inserting data for 'Horror/Survival'
INSERT INTO GameCategories (Total_Sales, Category)
SELECT SUM(scores.Total_Shipped), 'Horror/Survival'
FROM games 
JOIN scores ON games.Game_ID = scores.Game_ID
WHERE games.Name LIKE '%Resident Evil%' OR games.Name LIKE '%Silent Hill%' OR games.Name LIKE '%Outlast%'

-- Inserting data for 'Action/Adventure'
INSERT INTO GameCategories (Total_Sales, Category)
SELECT SUM(scores.Total_Shipped), 'Action/Adventure'
FROM games 
JOIN scores ON games.Game_ID = scores.Game_ID
WHERE games.Name LIKE '%Zelda%' OR games.Name LIKE '%Uncharted%' OR games.Name LIKE '%Tomb Raider%'

-- Inserting data for 'Racing Games'
INSERT INTO GameCategories (Total_Sales, Category)
SELECT SUM(scores.Total_Shipped), 'Racing Games'
FROM games 
JOIN scores ON games.Game_ID = scores.Game_ID
WHERE games.Name LIKE '%Need for Speed%' OR games.Name LIKE '%Gran Turismo%' OR games.Name LIKE '%Mario Kart%'

SELECT * FROM GameCategories

-- Task 8 (Highest & Lowest Rated games)
-- Highest Rated Games
SELECT TOP 5 games.Name, scores.Critic_Score, scores.User_Score, scores.Total_Shipped 
FROM games INNER JOIN scores ON games.Game_ID = scores.Game_ID
WHERE scores.Critic_Score IS NOT NULL AND scores.User_Score IS NOT NULL
ORDER BY scores.Critic_Score DESC

-- Lowest Rated Games
SELECT TOP 5 games.Name, scores.Critic_Score, scores.User_Score, scores.Total_Shipped 
FROM games INNER JOIN scores ON games.Game_ID = scores.Game_ID
WHERE scores.Critic_Score IS NOT NULL AND scores.User_Score IS NOT NULL
ORDER BY scores.Critic_Score ASC

-- Task 9 (Correlation calculation whether there is a relationship between high critic/user scores and higher sales)
SELECT games.Name, scores.Critic_Score, scores.User_Score, scores.Total_Shipped
FROM games JOIN scores ON games.Game_ID = scores.Game_ID
WHERE (scores.Critic_Score >= 9.0 OR scores.User_Score >= 9.0) 
  AND scores.Critic_Score IS NOT NULL 
  AND scores.User_Score IS NOT NULL
ORDER BY scores.Total_Shipped DESC

-- Task 10 (performance of individual developers over time by examining their average critic and user scores for each year)
SELECT developers.Developer, games.Year, ROUND(AVG(scores.Critic_Score), 2) AS Avg_Critic_Score, ROUND(AVG(scores.User_Score), 2) AS Avg_User_Score
FROM games
JOIN scores ON games.Game_ID = scores.Game_ID
JOIN developers ON games.Developer_ID = developers.Developer_ID
WHERE scores.Critic_Score IS NOT NULL AND scores.User_Score IS NOT NULL
GROUP BY developers.Developer, games.Year
ORDER BY games.Year DESC

-- Top developers
SELECT developers.Developer AS Developer_Name, ROUND(SUM(scores.Total_Shipped), 2) AS Total_Units_Shipped
FROM games
JOIN scores ON games.Game_ID = scores.Game_ID
JOIN developers ON games.Developer_ID = developers.Developer_ID
GROUP BY developers.Developer
ORDER BY Total_Units_Shipped DESC

-- Task 11 (Highlight standout years for the gaming industry by reviewing the number of high-scoring games and total units shipped)
SELECT games.Year, COUNT(*) AS High_Scoring_Games, ROUND(SUM(scores.Total_Shipped), 2) AS Total_Units_Shipped
FROM games
JOIN scores ON games.Game_ID = scores.Game_ID
WHERE (scores.Critic_Score >= 8.0 OR scores.User_Score >= 8.0)
GROUP BY games.Year 
ORDER BY High_Scoring_Games DESC, Total_Units_Shipped DESC

-- Task 12 (How popularity of different platforms has evolved by looking at the number of games released and their respective sales over the years.)
SELECT platforms.Platform, games.Year, COUNT(games.Game_ID) AS Games_Released, ROUND(SUM(scores.Total_Shipped), 2) AS Total_Units_Shipped
FROM games JOIN scores ON games.Game_ID = scores.Game_ID JOIN platforms ON games.Platform_ID = platforms.Platform_ID
GROUP BY platforms.Platform, games.Year 
ORDER BY Games_Released DESC

-- Top platforms by units shipped of games
SELECT platforms.Platform AS Platform_Name, ROUND(SUM(scores.Total_Shipped), 2) AS Total_Units_Shipped
FROM platforms
JOIN games ON platforms.Platform_ID = games.Platform_ID
JOIN scores ON games.Game_ID = scores.Game_ID
WHERE scores.Total_Shipped IS NOT NULL
GROUP BY platforms.Platform
ORDER BY Total_Units_Shipped DESC

-- Task 13 (Segment the data by decade to see which games and platforms were leaders in their respective time periods.)
SELECT (games.Year/10) * 10 AS Decade, games.Name AS Leading_Game, platforms.Platform AS Leading_Platform, publishers.Publisher AS Leading_Publisher, ROUND(scores.Total_Shipped, 2) AS Units_Shipped
FROM games JOIN scores ON games.Game_ID = scores.Game_ID JOIN platforms ON games.Platform_ID = platforms.Platform_ID 
JOIN publishers ON games.Publisher_ID = publishers.Publisher_ID
WHERE scores.Total_Shipped = (SELECT MAX(s1.Total_Shipped) FROM games g1 JOIN scores s1 ON g1.Game_Id = s1.Game_ID 
WHERE (g1.Year/10) * 10 = (games.Year / 10) * 10) 
ORDER BY Decade

-- Task 14 (Focus on games with high user scores to understand which titles resonate most with players, offering potential insights into 
-- customer preferences.)
SELECT TOP 10 games.Name AS Game_Name, platforms.Platform AS Platform, ROUND(scores.User_Score, 2) AS User_Score, ROUND(scores.Total_Shipped, 2) AS Units_Shipped
FROM games JOIN scores ON games.Game_ID = scores.Game_ID JOIN platforms ON platforms.platform_ID = games.Platform_ID 
WHERE scores.User_Score IS NOT NULL
ORDER BY scores.User_Score DESC

