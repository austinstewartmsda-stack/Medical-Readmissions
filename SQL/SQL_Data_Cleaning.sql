USE readmissions_portfolio;

-- I removed duplicate records

CREATE TABLE readmit_no_duplicates AS
SELECT DISTINCT *
FROM readmit_raw;

-- I removed leading and trailing spaces

UPDATE readmit_no_duplicates
SET
    Service_Month = TRIM(Service_Month),
    Service_Month_Date = TRIM(Service_Month_Date),
    Import_Note = TRIM(Import_Note),
    Review_Status = TRIM(Review_Status),
    Batch_ID = TRIM(Batch_ID);

-- I standardized the month formatting

UPDATE readmit_no_duplicates
SET Service_Month =
CONCAT(
    UPPER(LEFT(LOWER(Service_Month),1)),
    SUBSTRING(LOWER(Service_Month),2)
);

-- I removed commas from the numeric fields

UPDATE readmit_no_duplicates
SET Index_Stays = REPLACE(Index_Stays, ',', '');

UPDATE readmit_no_duplicates
SET Readmission_Stays = REPLACE(Readmission_Stays, ',', '');

-- I created integer versions of the stay counts

ALTER TABLE readmit_no_duplicates
ADD COLUMN Index_Stays_Clean INT;

ALTER TABLE readmit_no_duplicates
ADD COLUMN Readmission_Stays_Clean INT;

UPDATE readmit_no_duplicates
SET Index_Stays_Clean = CAST(Index_Stays AS UNSIGNED);

UPDATE readmit_no_duplicates
SET Readmission_Stays_Clean = CAST(Readmission_Stays AS UNSIGNED);

-- I converted the service month into a date field

ALTER TABLE readmit_no_duplicates
ADD COLUMN Service_Date DATE;

UPDATE readmit_no_duplicates
SET Service_Date =
STR_TO_DATE(Service_Month_Date,'%Y-%m-%d');

-- I recalculated the readmission rate

ALTER TABLE readmit_no_duplicates
ADD COLUMN Calculated_Readmission_Rate DECIMAL(5,2);

UPDATE readmit_no_duplicates
SET Calculated_Readmission_Rate =
ROUND(
    (Readmission_Stays_Clean / Index_Stays_Clean) * 100,
    2
);

-- I created the final cleaned table

CREATE TABLE readmit_clean (
    service_month VARCHAR(20),
    index_stays INT,
    readmission_stays INT,
    readmission_rate DECIMAL(5,2),
    service_month_date DATE
);

INSERT INTO readmit_clean
SELECT
    TRIM(Service_Month),
    Index_Stays_Clean,
    Readmission_Stays_Clean,
    Calculated_Readmission_Rate,
    Service_Date
FROM readmit_no_duplicates
ORDER BY Service_Date;

-- I performed a few validation checks

SELECT COUNT(*) AS total_rows
FROM readmit_clean;

SELECT
    service_month_date,
    COUNT(*) AS row_count
FROM readmit_clean
GROUP BY service_month_date
HAVING COUNT(*) > 1;

DESCRIBE readmit_clean;

SELECT
    MIN(service_month_date) AS first_month,
    MAX(service_month_date) AS last_month
FROM readmit_clean;

SELECT *
FROM readmit_clean
ORDER BY service_month_date
LIMIT 10;
