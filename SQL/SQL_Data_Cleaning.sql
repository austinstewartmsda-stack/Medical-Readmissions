CREATE TABLE readmit_no_duplicates AS SELECT DISTINCT * FROM
    readmit_raw;

UPDATE readmit_no_duplicates 
SET 
    Service_Month = TRIM(Service_Month),
    Service_Month_Date = TRIM(Service_Month_Date),
    Import_Note = TRIM(Import_Note),
    Review_Status = TRIM(Review_Status),
    Batch_ID = TRIM(Batch_ID);



CREATE TABLE readmit_no_duplicates AS SELECT DISTINCT * FROM
    readmit_raw;



UPDATE readmit_no_duplicates 
SET 
    Service_Month = TRIM(Service_Month);

UPDATE readmit_no_duplicates 
SET 
    Service_Month_Date = TRIM(Service_Month_Date);

UPDATE readmit_no_duplicates 
SET 
    Import_Note = TRIM(Import_Note);

UPDATE readmit_no_duplicates 
SET 
    Review_Status = TRIM(Review_Status);

UPDATE readmit_no_duplicates 
SET 
    Batch_ID = TRIM(Batch_ID);



UPDATE readmit_no_duplicates 
SET 
    Service_Month = CONCAT(UPPER(LEFT(LOWER(Service_Month), 1)),
            SUBSTRING(LOWER(Service_Month), 2));



UPDATE readmit_no_duplicates 
SET 
    Index_Stays = REPLACE(Index_Stays, ',', '');

UPDATE readmit_no_duplicates 
SET 
    Readmission_Stays = REPLACE(Readmission_Stays, ',', '');



ALTER TABLE readmit_no_duplicates
ADD COLUMN Index_Stays_Num INT;

ALTER TABLE readmit_no_duplicates
ADD COLUMN Readmission_Stays_Num INT;

ALTER TABLE readmit_no_duplicates
ADD COLUMN Index_Stays_Clean INT;

ALTER TABLE readmit_no_duplicates
ADD COLUMN Readmission_Stays_Clean INT;



UPDATE readmit_no_duplicates 
SET 
    Index_Stays_Num = CAST(Index_Stays AS UNSIGNED);

UPDATE readmit_no_duplicates 
SET 
    Readmission_Stays_Num = CAST(Readmission_Stays AS UNSIGNED);

UPDATE readmit_no_duplicates 
SET 
    Index_Stays_Clean = CAST(Index_Stays AS UNSIGNED);

UPDATE readmit_no_duplicates 
SET 
    Readmission_Stays_Clean = CAST(Readmission_Stays AS UNSIGNED);



ALTER TABLE readmit_no_duplicates
ADD COLUMN Service_Date DATE;

UPDATE readmit_no_duplicates 
SET 
    Service_Date = STR_TO_DATE(Service_Month_Date, '%Y-%m-%d');



ALTER TABLE readmit_no_duplicates
ADD COLUMN Calculated_Readmission_Rate DECIMAL(5,2);

UPDATE readmit_no_duplicates 
SET 
    Calculated_Readmission_Rate = ROUND((Readmission_Stays_Clean / Index_Stays_Clean) * 100,
            2);


CREATE TABLE readmit_clean (
    service_month VARCHAR(20),
    index_stays INT,
    readmission_stays INT,
    readmission_rate DECIMAL(5 , 2 ),
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

