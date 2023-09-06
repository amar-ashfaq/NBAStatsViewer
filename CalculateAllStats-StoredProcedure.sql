USE [NBA]
GO
/****** Object:  StoredProcedure [dbo].[CalculateAllStats]    Script Date: 06/09/2023 19:29:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CalculateAllStats]
AS
SELECT
    T.Name AS TeamName,
    T.Stadium,
    T.Logo,
    T.URL,
    COUNT(*) AS Played,
    SUM(CASE WHEN G.HomeScore > G.AwayScore THEN 1 ELSE 0 END) AS Won,
    SUM(CASE WHEN G.HomeScore < G.AwayScore THEN 1 ELSE 0 END) AS Lost,
    SUM(CASE WHEN G.HomeTeamID = T.TeamID THEN 1 ELSE 0 END) AS PlayedHome,
    SUM(CASE WHEN G.AwayTeamID = T.TeamID THEN 1 ELSE 0 END) AS PlayedAway,

    (
        SELECT TOP 1
            CASE
                WHEN G.HomeTeamID = T.TeamID AND G.HomeScore > G.AwayScore THEN
                    CONVERT(VARCHAR(10), G.HomeScore) + '-' + CONVERT(VARCHAR(10), G.AwayScore)
                WHEN G.AwayTeamID = T.TeamID AND G.AwayScore > G.HomeScore THEN
                    CONVERT(VARCHAR(10), G.AwayScore) + '-' + CONVERT(VARCHAR(10), G.HomeScore)
                ELSE
                    ''
            END
        FROM
            Games G
        WHERE
            (
                (G.HomeTeamID = T.TeamID AND G.HomeScore > G.AwayScore)
                OR
                (G.AwayTeamID = T.TeamID AND G.AwayScore > G.HomeScore)
            )
        ORDER BY
            ABS(G.HomeScore - G.AwayScore) DESC
    ) AS BiggestWin,

    (
        SELECT TOP 1
            CASE
                WHEN (G.HomeTeamID = T.TeamID AND G.HomeScore < G.AwayScore) OR
                        (G.AwayTeamID = T.TeamID AND G.AwayScore < G.HomeScore) THEN
                    CASE
                        WHEN G.HomeTeamID = T.TeamID THEN
                            CONVERT(VARCHAR(10), G.HomeScore) + '-' + CONVERT(VARCHAR(10), G.AwayScore)
                        ELSE
                            CONVERT(VARCHAR(10), G.AwayScore) + '-' + CONVERT(VARCHAR(10), G.HomeScore)
                    END
            END
        FROM
            Games G
        WHERE
            ((G.HomeTeamID = T.TeamID AND G.HomeScore < G.AwayScore) OR
                (G.AwayTeamID = T.TeamID AND G.AwayScore < G.HomeScore))
        ORDER BY
            CASE
                WHEN (G.HomeTeamID = T.TeamID AND G.HomeScore < G.AwayScore) OR
                        (G.AwayTeamID = T.TeamID AND G.AwayScore < G.HomeScore) THEN
                    ABS(
                        CASE
                            WHEN G.HomeTeamID = T.TeamID THEN
                                G.HomeScore - G.AwayScore
                            ELSE
                                G.AwayScore - G.HomeScore
                        END
                    )
                ELSE
                    NULL  -- Return NULL for games that don't match the criteria
            END DESC
    ) AS BiggestLoss,

    MAX(T.Stadium) AS LastGameStadium,
    MAX(G.GameDateTime) AS LastGameDate,
    (
        SELECT TOP 1 P.Name
        FROM Players P
        WHERE P.PlayerID IN (SELECT PlayerID FROM Team_Player WHERE TeamID = T.TeamID)
    ) AS MVP
FROM
    Teams T
LEFT JOIN
    Games G ON T.TeamID = G.HomeTeamID OR T.TeamID = G.AwayTeamID
GROUP BY
    T.Name,
    T.Stadium,
    T.Logo,
    T.URL,
    T.TeamID;
