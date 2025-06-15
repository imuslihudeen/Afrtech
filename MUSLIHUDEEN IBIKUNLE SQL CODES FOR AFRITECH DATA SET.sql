CREATE DATABASE AfriTechDB;

CREATE TABLE StagingData(
   CustomerID INT,
   CustomerName VARCHAR(255),
   Region VARCHAR(100),
   Age INT,
   Income DECIMAL(10,2),
   CustomerType VARCHAR(50),
   TransactionYear INT,
   TransactionDate DATE,
   ProductPurchased VARCHAR(200),
   PurchaseAmount DECIMAL(10,2),
   ProductRecalled BOOLEAN,
   Competitor_x VARCHAR(200),
   InteractionDate DATE,
   Platform VARCHAR(100),
   PostType VARCHAR(100),
   EngagementLikes INT,
   EngagementShares INT,
   EngagementComments INT,
   UserFollowers INT,
   InfluencerScore DECIMAL(10, 4),
   CompetitorMention BOOLEAN,
   BrandMention BOOLEAN,
   Sentiment VARCHAR(50),
   CrisisEventTime DATE,
   FirstResponseTime DATE,
   ResolutionStatus BOOLEAN,
   NPSResponse INT
   );
Select * from public.StagingData

Drop Table StagingData

________Create Customer Table________
CREATE TABLE CustomerData(
	CustomerID INT PRIMARY KEY,
	CustomerName VARCHAR(255),
	Region VARCHAR(255),
	Age INT,
	Income Numeric(10,2),
	CustomerType VARCHAR(50)
);
Select * from public.CustomerData


Drop Table CustomerData

________Create Transaction Table________

CREATE TABLE Transactions	(
	TransactionID SERIAL PRIMARY KEY,
	CustomerID INT,
	TransactionYear VARCHAR(4),
	TransactionDate DATE,
   	ProductPurchased VARCHAR(255),
   	PurchaseAmount DECIMAL(10,2),
   	ProductRecalled BOOLEAN,
   	Competitor_x VARCHAR(255),
	FOREIGN KEY (CustomerID) REFERENCES CustomerData(CustomerID)
);
Drop Table Transactions

________Create SocialMedia Table________
CREATE TABLE SocialMedia	(
	PostID SERIAL PRIMARY KEY,
	CustomerID INT,
	InteractionDate DATE,
   	Platform VARCHAR(50),
  	PostType VARCHAR(50),
    EngagementLikes INT,
   	EngagementShares INT,
   	EngagementComments INT,
	UserFollowers INT,
   	InfluencerScore DECIMAL(10, 2),
   	CompetitorMention BOOLEAN,
   	BrandMention BOOLEAN,
   	Sentiment VARCHAR(50),
	Competitor_x VARCHAR(255),
   	CrisisEventTime DATE,
   	FirstResponseTime DATE,
   	ResolutionStatus BOOLEAN,
   	NPSResponse INT,
	FOREIGN KEY (CustomerID) REFERENCES CustomerData(CustomerID)
);
Drop Table SocialMedia

-------Insert Customer data-----
INSERT into CustomerData(CustomerID, CustomerName, Region, Age, Income, CustomerType)
SELECT DISTINCT CustomerID, CustomerName, Region, Age, Income, CustomerType
FROM StagingData;
Select * from public.CustomerData

-------Insert transaction data-----
INSERT into Transactions(CustomerID, TransactionYear, TransactionDate, ProductPurchased, PurchaseAmount, ProductRecalled, Competitor_x) 
SELECT CustomerID, TransactionYear, TransactionDate, ProductPurchased, PurchaseAmount, ProductRecalled, Competitor_x 
FROM StagingData WHERE TransactionDate IS NOT NULL;
Select * from public.Transactions


-------Insert social media data-----
INSERT into SocialMedia	(CustomerID, InteractionDate, Platform, PostType, EngagementLikes, EngagementShares, EngagementComments, UserFollowers, InfluencerScore, BrandMention, CompetitorMention, Sentiment, Competitor_x, CrisisEventTime, FirstResponseTime, ResolutionStatus, NPSResponse)
SELECT CustomerID, InteractionDate, Platform, PostType, EngagementLikes, EngagementShares, EngagementComments, UserFollowers, InfluencerScore, BrandMention, CompetitorMention, Sentiment, Competitor_x, CrisisEventTime, FirstResponseTime, ResolutionStatus, NPSResponse
FROM StagingData WHERE InteractionDate IS NOT NULL
Select * from public.SocialMedia

Select socialmedia WHERE ResolutionStatus = 'TRUE'


_____Limit__________
Select * 
from Transactions
Limit 5

Select * 
from Socialmedia
Limit 5

_____Data Validation_____
SELECT COUNT(*) 
FROM CustomerData;

SELECT COUNT(*) 
FROM SocialMedia;

SELECT COUNT(*) 
FROM Transactions;

____Checking for Null Values(Identiying Missing columns)___
SELECT COUNT (*) FROM customerdata
WHERE Customerid is NULL

SELECT COUNT (*) FROM socialmedia
WHERE competitor_x is NULL

SELECT COUNT (*) FROM socialmedia
WHERE crisiseventtime is NULL

SELECT COUNT (*) FROM socialmedia
WHERE npsresponse is NULL

SELECT COUNT (*) FROM socialmedia
WHERE resolutionstatus is NULL

SELECT COUNT (*) FROM transactions
WHERE competitor_x is NULL

SELECT COUNT(DISTINCT customerid) AS UniqueCustomer
FROM customerdata;

SELECT 'CustomerName' AS columnName, COUNT(*) AS Nullcount
FROM CustomerData
WHERE CustomerName is NOT NULL
UNION
SELECT 'region' as ColumnName, COUNT (*) As Nullcount
FROM CustomerData
WHERE region IS NOT NULL;

----Transaction EDA-----
SELECT
	AVG(purchaseamount) AS AveragePurchaseAmount,
	MIN(purchaseamount) AS MinPurchaseAmount,
	MAX(purchaseamount) AS MaxPurchaseAmount,
	SUM(purchaseamount) AS TotalSales
FROM Transactions;

SELECT
	TO_CHAR(AVG(purchaseamount),'$999,999,999.99') AS AveragePurchaseAmount,
	TO_CHAR(MIN(purchaseamount),'$999,999,999.99') AS MinPurchaseAmount,
	TO_CHAR(MAX(purchaseamount),'$999,999,999.99') AS MaxPurchaseAmount,
	TO_CHAR(SUM(purchaseamount),'$9,999,999,99.99') AS TotalSales
FROM Transactions;

SELECT
	ProductPurchased,
	COUNT (*) AS NumberofSales,
	SUM(PurchaseAmount) AS TotalSales
FROM transactions
GROUP BY ProductPurchased;

SELECT
	ProductPurchased,
	COUNT (*) AS TransactionCount,
	SUM(PurchaseAmount) AS TotalAmount
FROM transactions
WHERE ProductPurchased IS NOT NULL
GROUP BY ProductPurchased;

SELECT
	Productrecalled,
	COUNT (*) AS TransactioCount,
	AVG(PurchaseAmount) AS AverageAmount
FROM transactions
WHERE PurchaseAmount IS NOT NULL
GROUP BY Productrecalled;

----SocailMedia EDA-----
SELECT
	Platform,
	AVG(engagementlikes) AS AverageLikes,
	SUM(engagementlikes) AS TotalLikes
	FROM socialmedia
GROUP BY platform;

SELECT
	Platform,
	ROUND(AVG(engagementlikes), 2) AS AverageLikes,
	ROUND(SUM(engagementlikes), 2)  AS TotalLikes
	FROM socialmedia
GROUP BY platform;

SELECT
	Sentiment,
	COUNT (*) AS COUNT
	FROM socialmedia
	WHERE Sentiment is NOT NULL
GROUP BY Sentiment;

SELECT 'platform' AS columnName,
COUNT (*) AS NullCount
FROM socialmedia
WHERE platform is NOT NULL
UNION
SELECT 'sentiment' AS columnName,
COUNT (*) AS NullCount
FROM socialmedia
WHERE sentiment is NOT NULL

----Count the total number of brand mentions across socail media platforms-----
SELECT COUNT(*) AS VolumeofMentions
FROM SocialMedia
WHERE Brandmention = 'TRUE'
GROUP BY Platform;

SELECT platform, COUNT(*) AS VolumeOfMentions
FROM SocialMedia
WHERE brandmention = 'TRUE'
GROUP BY platform;

----Sentiment Score--------
SELECT sentiment, COUNT(*) * 100.0 /
(SELECT COUNT(*) FROM SocialMedia) AS Percentage
FROM SocialMedia
GROUP BY sentiment;

----Engagement Rate--------
SELECT AVG((EngagementLikes + Engagementshares+ Engagementcomments)/
NULLIF(Userfollowers,0)) AS EmgagementRate
FROM SocialMedia;

----Brand mention by Competition mention--------
SELECT SUM(CASE WHEN Brandmention = 'TRUE'THEN 1 ELSE 0 END) AS Brandmentions,
SUM(CASE WHEN competitormention = 'TRUE'THEN 1 ELSE 0 END) AS competitormentions
FROM socialmedia;

---Influence score------
SELECT ROUND(AVG(influencerscore), 2) AS averageinfluencescore
FROM socialmedia

---TIME TREND ANALYSIS------
SELECT TO_CHAR(DATE_TRUNC ('month', interactiondate), 'YYYY-MM') AS MONTH,
COUNT(*) AS Mentions
FROM SocialMedia
WHERE brandmention = 'TRUE'
GROUP BY Month;

SELECT TO_CHAR(DATE_TRUNC ('month', interactiondate), 'YYYY-MM') AS MONTH,
COUNT(*) AS Mentions, platform
FROM SocialMedia
WHERE brandmention = 'TRUE'
GROUP BY Month, platform;

-----CRisis Response Time-----
SELECT AVG(
	DATE_PART('epoch', (CAST(FirstResponseTime AS TIMESTAMP) - CAST(CrisisEventTime AS TIMESTAMP)))/ 3600)
AS AverageResponseTimeHours
FROM SocialMedia
WHERE CrisisEventTime is NOT NULL AND FirstResponseTime IS NOT NULL;

------Resolution Rate------
SELECT COUNT(*) * 100.0 / 
(SELECT COUNT(*) FROM socialmedia WHERE CrisisEventTime is NOT NULL) AS ResolutionRate
FROM socialmedia
WHERE resolutionstatus = 'True'; 

-------Top Influencess:
SELECT CustomerID, ROUND(AVG(InfluencerScore), 0) AS InfluencerScore
FROM socialmedia
GROUP BY CustomerID
ORDER BY Influencerscore DESC
LIMIT 10;

------ Content Effectiveness:
SELECT PostType, ROUND(AVG(EngagementLikes + Engagementshares+ Engagementcomments)) AS EmgagementRate
FROM SocialMedia
GROUP BY PostType;

------TotalRevenue by platform-------
SELECT s.platform, SUM(t.purchaseamount) as Totalrevenue
FROM SocialMedia s
LEFT JOIN Transactions t ON s.CustomerID = t.CustomerID
WHERE t.purchaseamount IS NOT NULL
GROUP BY s.platform
ORDER BY Totalrevenue DESC;

----Top buying customers and region----
SELECT
	c.CustomerID,
	c.CustomerName,
	c.Region,
	COALESCE(SUM(t.purchaseamount), 0) AS TotalPurchaseAmount
FROM CustomerData c
LEFT JOIN Transactions t ON c.CustomerID = t.CustomerID
GROUP BY c.customerID, c.customerName, c.Region IS NOT NULL
ORDER BY TotalPurchaseAmount DESC
LIMIT 10;

----Average engagement metrics by product----
SELECT
	t.ProductPurchased,
	AVG(s.EngagementLikes) AS AvgLikes,
	AVG(s.EngagementShares) AS AvgShares,
	AVG(s.EngagementComments) AS AvgComments
FROM Transactions t
LEFT JOIN SocialMedia s ON t.CustomerID = s.CustomerID
GROUP BY t.ProductPurchased
ORDER BY AvgLikes DESC, AvgShares DESC, AvgComments DESC;

----Product with negative customer buzz and products recalls with negative buzz and recalls----
---EXample of CT you can store query temporarily-----
Product WITH negative customer buzz and product recalls 
WITH NegativeBuzzAndRecalls AS (
	SELECT
		t.ProductPurchased,
		COUNT(DISTINCT CASE WHEN s.Sentiment = 'Negative' THEN s.CustomerID END) AS NegativeBuzzCount,
		COUNT(DISTINCT CASE WHEN t.ProductRecalled = TRUE THEN t.CustomerID END) As RecalledCount
FROM Transactions t
LEFT JOIN SocialMedia s ON t.CustomerID = s.CustomerID
GROUP BY t.ProductPurchased
)
SELECT
	n.ProductPurchased,
	n.NegativeBuzzCount,
	n.RecalledCount
FROM NegativeBuzzAndRecalls n
WHERE n.NegativeBuzzCount > 0 OR n.RecalledCount > 0;

-------Creating Views-------
CREATE OR REPLACE VIEW BrandMentions AS
SELECT
	InteractionDate,
	COUNT (*) AS BrandMentionCount
FROM SocialMedia
WHERE BrandMention
GROUP BY InteractionDate
ORDER BY InteractionDate;

SELECT * FROM BrandMentions;


----Stored procedure for crisis response time---
CREATE OR REPLACE FUNCTION CalculateAvgResponseTime() RETURNS TABLE (
	Platform VARCHAR(50),
	AvgResponseTimeHours NUMERIC
) AS $$
BEGIN
	RETURN QUERY 
		SELECT
			s.platform, 
			AVG(EXTRACT(EPOCH FROM ((CAST(FirstResponseTime AS TIMESTAMP) - CAST(CrisisEventTime AS TIMESTAMP)))
		FROM SocialMedia s
		WHERE s.CrisisEventTime is NOT NULL AND s.FirstResponseTime is NOT NULL
		GROUP BY s.Platform
	);
END;
$$ LANGUAGE plpgsql;

SELECT * FROM CalculateAvgResponseTime();
	


CREATE OR REPLACE FUNCTION CalculateAvgResponseTime()
  RETURNS TABLE (
    Platform               VARCHAR(50),
    AvgResponseTimeHours   NUMERIC
  )
AS $$
BEGIN
  RETURN QUERY
  SELECT
    s.Platform,
    AVG(
      EXTRACT(
        EPOCH
        FROM (
          CAST(s.FirstResponseTime AS TIMESTAMP)
          - CAST(s.CrisisEventTime  AS TIMESTAMP)
        )
      )
      / 3600.0
    ) AS AvgResponseTimeHours
  FROM SocialMedia s
  WHERE s.CrisisEventTime  IS NOT NULL
    AND s.FirstResponseTime IS NOT NULL
  GROUP BY s.Platform;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM CalculateAvgResponseTime();