CREATE TABLE readmit_no_duplicates AS
    SELECT DISTINCT * FROM readmit_raw;

UPDATE readmit_no_duplicates
SET
    Service_Month = TRIM(Service_Month),
    Service_Month_Date = TRIM(Service_Month_Date),
    Import_Note = TRIM(Import_Note),
    Review_Status = TRIM(Review_Status),
    Batch_ID = TRIM(Batch_ID);

