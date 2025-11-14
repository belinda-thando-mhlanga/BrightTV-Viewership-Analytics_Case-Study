-- Database: BRIGHT_TV.CASESTUDY----view tables provided:
SELECT * FROM BRIGHT_TV.CASESTUDY.VIEWERSHIPLIMIT 100;

SELECT * FROM  BRIGHT_TV.CASESTUDY.USERPROFILES LIMIT 100;

-- SECTION 1: INITIAL DATA EXPLORATION
-- ------------------------------------------------------------------------------------------------------------------------------------------------
-- Check record counts
SELECT COUNT(*) AS total_records FROM BRIGHT_TV.CASESTUDY.USERPROFILES;
SELECT COUNT(*) AS total_records FROM BRIGHT_TV.CASESTUDY.VIEWERSHIP;

-- Check unique users
SELECT COUNT(DISTINCT UserID) AS unique_users FROM BRIGHT_TV.CASESTUDY.USERPROFILES;
SELECT COUNT(DISTINCT UserID) AS unique_users FROM BRIGHT_TV.CASESTUDY.VIEWERSHIP;

-- Check age range
SELECT 
    MIN(Age) AS youngest_age,
    MAX(Age) AS oldest_age
FROM BRIGHT_TV.CASESTUDY.USERPROFILES;

-- Check date range
SELECT 
    MIN(TO_TIMESTAMP(RecordDate2, 'YYYY/MM/DD HH24:MI')) AS first_record,
    MAX(TO_TIMESTAMP(RecordDate2, 'YYYY/MM/DD HH24:MI')) AS last_record
FROM BRIGHT_TV.CASESTUDY.VIEWERSHIP;

---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- I used CTE (Common Table Expression) to:
---Remove duplicates once
---Calculate SA date/time once
--This will allow me to reuse the short version everywhere 

WITH Base AS (
    SELECT
        v.*,
        u.Gender,
        u.Race,
        u.Age,
        u.Province,

-- Convert once to South African time (UTC+2)
        DATEADD(HOUR, 2, TO_TIMESTAMP(v.RecordDate2, 'YYYY/MM/DD HH24:MI')) AS RecordDate_SA
    FROM BRIGHT_TV.CASESTUDY.VIEWERSHIP AS v
    INNER JOIN BRIGHT_TV.CASESTUDY.USERPROFILES AS u
        ON v.UserID = u.UserID
    WHERE v.RecordDate2 IS NOT NULL
        AND v.Duration2 != '00:00:00'
)
SELECT
--BASIC RAW FIELDS
    UserID,
    IFNULL(Gender, 'Not Specified') AS Gender,
    IFNULL(Race, 'Not Specified') AS Race,
    Age,
    IFNULL(Province, 'Not Specified') AS Province,
    IFNULL(Channel2, 'Unknown Channel') AS Channel,
    IFNULL(Duration2, '00:00:00') AS Duration,
    
-- DATE/TIME (Using pre-calculated RecordDate_SA) 
    RecordDate_SA,
    CAST(RecordDate_SA AS DATE) AS Date_SA,
    CAST(RecordDate_SA AS TIME) AS Time_SA,
    
-- Time & date components 
    EXTRACT(YEAR FROM RecordDate_SA) AS Year,
    EXTRACT(MONTH FROM RecordDate_SA) AS Month_Number,
    MONTHNAME(RecordDate_SA) AS Month_Name,
    EXTRACT(DAY FROM RecordDate_SA) AS Day_of_Month,
    DAYNAME(RecordDate_SA) AS Weekday_Name,
    DAYOFWEEK(RecordDate_SA) AS Weekday_Number,
    EXTRACT(HOUR FROM RecordDate_SA) AS Hour,
    
--Analysing columns using CASE STATEMENTS
    CASE 
        WHEN DAYNAME(RecordDate_SA) IN ('Sat', 'Sun') THEN 'Weekend'
        ELSE 'Weekday'
    END AS Day_Type,
    
-- Time of Day Buckets
    CASE 
        WHEN EXTRACT(HOUR FROM RecordDate_SA) BETWEEN 6  AND 11 THEN 'Morning (06:00-11:59)'
        WHEN EXTRACT(HOUR FROM RecordDate_SA) BETWEEN 12 AND 17 THEN 'Afternoon (12:00-17:59)'
        WHEN EXTRACT(HOUR FROM RecordDate_SA) BETWEEN 18 AND 23 THEN 'Evening (18:00-23:59)'
        ELSE 'Night (00:00-05:59)'
    END AS Time_of_day,
    
-- Cleaned Gender
    CASE 
        WHEN UPPER(Gender) = 'MALE' THEN 'Male'
        WHEN UPPER(Gender) = 'FEMALE' THEN 'Female'
        ELSE 'Unknown'
    END AS Gender_Cleaned,
    
-- Cleaned Race
    CASE 
        WHEN Race IS NULL OR UPPER(Race) = 'NONE' THEN 'Not Specified'
        WHEN UPPER(Race) = 'BLACK' THEN 'Black'
        WHEN UPPER(Race) = 'WHITE' THEN 'White'
        WHEN UPPER(Race) = 'COLOURED' THEN 'Coloured'
        WHEN UPPER(Race) = 'INDIAN' THEN 'Indian'
        ELSE 'Other'
    END AS Race_Cleaned,
    
-- Age Group
    CASE 
        WHEN Age BETWEEN 0 AND 12 THEN 'Child (0-12)'
        WHEN Age BETWEEN 13 AND 19 THEN 'Teenager (13-19)'
        WHEN Age BETWEEN 20 AND 39 THEN 'Young Adult (20-39)'
        WHEN Age BETWEEN 40 AND 64 THEN 'Adult (40-64)'
        WHEN Age >= 65 THEN 'Pensioner (65+)'
        ELSE 'Unknown'
    END AS Age_Group,
    
-- Watch Time Category
    CASE
        WHEN Duration2 BETWEEN '00:00:00' AND '02:59:59' THEN '0-3 Hours'
        WHEN Duration2 BETWEEN '03:00:00' AND '05:59:59' THEN '3-6 Hours'
        WHEN Duration2 BETWEEN '06:00:00' AND '08:59:59' THEN '6-9 Hours'
        ELSE '9-12 Hours'
    END AS Watch_Time_Category

FROM Base
ORDER BY RecordDate_SA DESC, UserID;
