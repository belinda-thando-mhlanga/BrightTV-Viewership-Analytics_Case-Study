SELECT 
    -- PRIMARY KEY
    v.UserID,
    
    -- USER DEMOGRAPHICS (because of inconsistencies in the data, I use UPPER)
    CASE 
        WHEN UPPER(u.Gender) = 'MALE' THEN 'Male'
        WHEN UPPER(u.Gender) = 'FEMALE' THEN 'Female'
        ELSE 'Unknown'
    END AS Gender,
    
    CASE 
        WHEN u.Race IS NULL OR UPPER(u.Race) = 'NONE' THEN 'Not Specified'
        WHEN UPPER(u.Race) = 'BLACK' THEN 'Black'
        WHEN UPPER(u.Race) = 'WHITE' THEN 'White'
        WHEN UPPER(u.Race) = 'COLOURED' THEN 'Coloured'
        WHEN UPPER(u.Race) = 'INDIAN' THEN 'Indian'
        ELSE 'Other'
    END AS Race,
    
    u.Age,
    
    CASE 
        WHEN u.Age BETWEEN 0 AND 12 THEN 'Child (0-12)'
        WHEN u.Age BETWEEN 13 AND 19 THEN 'Teenager (13-19)'
        WHEN u.Age BETWEEN 20 AND 39 THEN 'Young Adult (20-39)'
        WHEN u.Age BETWEEN 40 AND 64 THEN 'Adult (40-64)'
        WHEN u.Age >= 65 THEN 'Pensioner (65+)'
        ELSE 'Unknown'
    END AS Age_Group,
    
    u.Province,
    
    -- VIEWERSHIP DATA
    v.Channel2 AS Channel,
    
    -- TIME DIMENSIONS (SA Time = UTC+2) 
    TO_TIMESTAMP(v.RecordDate2, 'YYYY/MM/DD HH24:MI') AS RecordDate_UTC,
    DATEADD(HOUR, 2, TO_TIMESTAMP(v.RecordDate2, 'YYYY/MM/DD HH24:MI')) AS RecordDate_SA,
    
    -- Date Components
    EXTRACT(YEAR FROM DATEADD(HOUR, 2, TO_TIMESTAMP(v.RecordDate2, 'YYYY/MM/DD HH24:MI'))) AS Year,
    EXTRACT(MONTH FROM DATEADD(HOUR, 2, TO_TIMESTAMP(v.RecordDate2, 'YYYY/MM/DD HH24:MI'))) AS Month_Number,
    MONTHNAME(DATEADD(HOUR, 2, TO_TIMESTAMP(v.RecordDate2, 'YYYY/MM/DD HH24:MI'))) AS Month_Name,
    EXTRACT(DAY FROM DATEADD(HOUR, 2, TO_TIMESTAMP(v.RecordDate2, 'YYYY/MM/DD HH24:MI'))) AS Day_of_Month,
    
    -- Weekday Components
    DAYOFWEEK(DATEADD(HOUR, 2, TO_TIMESTAMP(v.RecordDate2, 'YYYY/MM/DD HH24:MI'))) AS Weekday_Number,
    DAYNAME(DATEADD(HOUR, 2, TO_TIMESTAMP(v.RecordDate2, 'YYYY/MM/DD HH24:MI'))) AS Weekday_Name,
    
    CASE 
        WHEN DAYNAME(DATEADD(HOUR, 2, TO_TIMESTAMP(v.RecordDate2, 'YYYY/MM/DD HH24:MI'))) IN ('Sat', 'Sun') THEN 'Weekend'
        ELSE 'Weekday'
    END AS Day_Type,
    
    -- Hour Components
    EXTRACT(HOUR FROM DATEADD(HOUR, 2, TO_TIMESTAMP(v.RecordDate2, 'YYYY/MM/DD HH24:MI'))) AS Hour,
    
    -- Time Bucket (Morning/Afternoon/Evening/Night)
    CASE 
        WHEN EXTRACT(HOUR FROM DATEADD(HOUR, 2, TO_TIMESTAMP(v.RecordDate2, 'YYYY/MM/DD HH24:MI'))) BETWEEN 6 AND 11 THEN 'Morning (06:00-11:59)'
        WHEN EXTRACT(HOUR FROM DATEADD(HOUR, 2, TO_TIMESTAMP(v.RecordDate2, 'YYYY/MM/DD HH24:MI'))) BETWEEN 12 AND 17 THEN 'Afternoon (12:00-17:59)'
        WHEN EXTRACT(HOUR FROM DATEADD(HOUR, 2, TO_TIMESTAMP(v.RecordDate2, 'YYYY/MM/DD HH24:MI'))) BETWEEN 18 AND 23 THEN 'Evening (18:00-23:59)'
        ELSE 'Night (00:00-05:59)'
    END AS Time_Bucket,

FROM 
    BRIGHT_TV.CASESTUDY.VIEWERSHIP AS v
    
INNER JOIN 
    BRIGHT_TV.CASESTUDY.USERPROFILES AS u
    ON v.UserID = u.UserID

WHERE 
    -- Filter out invalid sessions
 RecordDate2 IS NOT NULL

ORDER BY 
    RecordDate_SA DESC,
    v.UserID;
