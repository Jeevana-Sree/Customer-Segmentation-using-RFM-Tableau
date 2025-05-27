create database retail_rfm;
use retail_rfm;
ALTER TABLE transactions_cleaned
CHANGE COLUMN `ï»¿Invoice` Invoice VARCHAR(20);

show columns from transactions_cleaned;

SELECT Invoice, InvoiceDate FROM transactions_cleaned LIMIT 5;

SELECT count(*) FROM transactions_cleaned LIMIT 5;

SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 'ON';
SHOW GLOBAL VARIABLES LIKE 'local_infile';

ALTER TABLE transactions_cleaned
CHANGE COLUMN `Customer ID` CustomerID INT;

show columns from transactions_cleaned;

SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/retail_2011_cleaned.csv'
INTO TABLE transactions_cleaned
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
  Invoice, StockCode, Description, Quantity, @InvoiceDate, Price, CustomerID, Country, TotalPrice
)
SET InvoiceDate = STR_TO_DATE(@InvoiceDate, '%d-%m-%Y %H:%i');

select * from transactions_cleaned limit 5;

-- View max invoice date (to confirm reference)
SELECT MAX(InvoiceDate) FROM transactions_cleaned;

-- First lets create RFM Score TAble 
 
CREATE TABLE rfm_scores AS
SELECT
  CustomerID,
  DATEDIFF('2011-12-10', MAX(InvoiceDate)) AS Recency,
  COUNT(DISTINCT Invoice) AS Frequency,
  ROUND(SUM(TotalPrice), 2) AS Monetary
FROM transactions_cleaned
GROUP BY CustomerID;

-- Add score columns
ALTER TABLE rfm_scores ADD COLUMN RecencyScore INT;
ALTER TABLE rfm_scores ADD COLUMN FrequencyScore INT;
ALTER TABLE rfm_scores ADD COLUMN MonetaryScore INT;

-- Recency: lower days = higher score
UPDATE rfm_scores
SET RecencyScore = CASE
  WHEN Recency <= 30 THEN 4
  WHEN Recency <= 60 THEN 3
  WHEN Recency <= 90 THEN 2
  ELSE 1
END;

-- Frequency: more orders = higher score
UPDATE rfm_scores
SET FrequencyScore = CASE
  WHEN Frequency >= 20 THEN 4
  WHEN Frequency >= 10 THEN 3
  WHEN Frequency >= 5 THEN 2
  ELSE 1
END;

-- Monetary: more spend = higher score
UPDATE rfm_scores
SET MonetaryScore = CASE
  WHEN Monetary >= 2000 THEN 4
  WHEN Monetary >= 1000 THEN 3
  WHEN Monetary >= 500 THEN 2
  ELSE 1
END;

select * from rfm_scores;
