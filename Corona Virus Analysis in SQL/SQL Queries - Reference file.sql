
-- To avoid any errors, check missing value / null value 
-- Q1. Write a code to check NULL values

SELECT *
FROM corona_dataset
WHERE 
"Province" IS NULL 	OR 	"Country/Region" IS NULL OR 
"Latitude" IS NULL 	OR 	"Longitude" 	 IS NULL OR 
"Date" 	   IS NULL 	OR 	"Confirmed"      IS NULL OR 
"Deaths"   IS NULL 	OR 	"Recovered"      IS NULL

--Q2. If NULL values are present, update them with zeros for all columns. 

UPDATE corona_dataset
SET 
    "Province" 		= COALESCE("Province", '0'),
    "Country/Region"= COALESCE("Country/Region", '0'),
    "Latitude" 		= COALESCE("Latitude" , 0),
	"Longitude" 	= COALESCE("Longitude" , 0),
	"Date" 			= COALESCE("Date" , 0),
	"Confirmed" 	= COALESCE("Confirmed" , 0),
	"Deaths" 		= COALESCE("Deaths" , 0),
	"Recovered" 	= COALESCE("Recovered" , 0);

-- Q3. check total number of rows

SELECT COUNT(*) AS total_rows
FROM corona_dataset;

-- Q4. Check what is start_date and end_date

SELECT MIN("Date") AS start_date ,  MAX("Date") AS end_date
FROM corona_dataset;

-- Q5. Number of month present in dataset

SELECT COUNT(DISTINCT DATE_TRUNC('month', "Date")) AS num_months
FROM corona_dataset;

-- Q6. Find monthly average for confirmed, deaths, recovered

SELECT EXTRACT(MONTH FROM t."Date") as month , EXTRACT(YEAR FROM  "Date") AS year, 
AVG("Confirmed") AS AVG_CONFIRMED,
AVG("Deaths") AS AVG_DEATHS,
AVG("Recovered") AS AVG_RECOVERED
FROM corona_dataset t
GROUP BY month, year
order by year, month

-- Q7. Find most frequent value for confirmed, deaths, recovered each month 

WITH MonthlyStats AS (
    SELECT 
        EXTRACT(YEAR FROM "Date") AS "Year",
        EXTRACT(MONTH FROM "Date") AS "Month",
        "Confirmed",
        "Deaths",
        "Recovered",
        ROW_NUMBER() OVER (PARTITION BY EXTRACT(YEAR FROM "Date"), EXTRACT(MONTH FROM "Date") ORDER BY COUNT(*) DESC) AS rn
    FROM 
        corona_dataset
    GROUP BY 
        EXTRACT(YEAR FROM "Date"),
        EXTRACT(MONTH FROM "Date"),
        "Confirmed",
        "Deaths",
        "Recovered"
)

SELECT 
    TO_CHAR(TO_DATE("Month"::text, 'MM'), 'Month') AS "Month",
    "Year",
    "Confirmed" AS "MostFrequentConfirmed",
    "Deaths" AS "MostFrequentDeaths",
    "Recovered" AS "MostFrequentRecovered"
FROM 
    MonthlyStats
WHERE 
    rn = 1;

-- Q8. Find minimum values for confirmed, deaths, recovered per year

SELECT 
    EXTRACT(YEAR FROM "Date") AS "Year",
    MIN("Confirmed") AS "MinConfirmed",
    MIN("Deaths") AS "MinDeaths",
    MIN("Recovered") AS "MinRecovered"
FROM 
    corona_dataset
GROUP BY "Year";

-- Q9. Find maximum values of confirmed, deaths, recovered per year

SELECT 
    EXTRACT(YEAR FROM "Date") AS "Year",
    MAX("Confirmed") AS "MaxConfirmed",
    MAX("Deaths") AS "MaxDeaths",
    MAX("Recovered") AS "MaxRecovered"
FROM 
    corona_dataset
GROUP BY "Year";

-- Q10. The total number of case of confirmed, deaths, recovered each month


SELECT 
    EXTRACT(YEAR FROM "Date") AS "Year",
    EXTRACT(MONTH FROM "Date") AS "Month",
    SUM("Confirmed") AS "TotalConfirmed",
    SUM("Deaths") AS "TotalDeaths",
    SUM("Recovered") AS "TotalRecovered"
FROM 
    corona_dataset
GROUP BY 
	"Year" , "Month"
ORDER BY 
    "Year", "Month";

-- Q11. Check how corona virus spread out with respect to confirmed case
--      (Eg.: total confirmed cases, their average, variance & STDEV )

WITH Stats AS (
    SELECT 
        SUM("Confirmed") AS TotalConfirmedCases,
        AVG("Confirmed") AS AverageConfirmedCases,
        VARIANCE("Confirmed") AS VarianceConfirmedCases,
        STDDEV("Confirmed") AS StandardDeviationConfirmedCases
    FROM 
        corona_dataset
)

SELECT 
    TotalConfirmedCases,
    AverageConfirmedCases,
    VarianceConfirmedCases,
    StandardDeviationConfirmedCases
FROM 
    Stats;

-- Q12. Check how corona virus spread out with respect to death case per month
--      (Eg.: total confirmed cases, their average, variance & STDEV )

WITH MonthlyDeathStats AS (
    SELECT 
        EXTRACT(YEAR FROM "Date") AS "Year",
        EXTRACT(MONTH FROM "Date") AS "Month",
        SUM("Deaths") AS "TotalDeaths",
	 	AVG("Deaths")  AS "AverageDeaths",
   	    VARIANCE("Deaths")  AS "VarianceDeaths",
   		STDDEV("Deaths") AS "StandardDeviationDeaths"
    FROM 
        corona_dataset
    GROUP BY 
	"Year", "Month"
	ORDER BY
	"Year", "Month"
)

SELECT 
    TO_CHAR(TO_DATE("Month"::text, 'MM'), 'Month') AS "Month",
    "Year",
    "TotalDeaths",
	"AverageDeaths",
   	"VarianceDeaths",
   	"StandardDeviationDeaths"
FROM 
    MonthlyDeathStats;

-- Q13. Check how corona virus spread out with respect to recovered case
--      (Eg.: total confirmed cases, their average, variance & STDEV )

WITH Stats AS (
    SELECT 
        SUM("Recovered") AS TotalRecoveredCases,
        AVG("Recovered") AS AverageRecoveredCases,
        VARIANCE("Recovered") AS VarianceRecoveredCases,
        STDDEV("Recovered") AS StandardDeviationRecoveredCases
    FROM 
        corona_dataset
)

SELECT 
    TotalRecoveredCases,
    AverageRecoveredCases,
    VarianceRecoveredCases,
    StandardDeviationRecoveredCases
FROM 
    Stats;

-- Q14. Find Country having highest number of the Confirmed case


SELECT 
    "Country/Region" AS "Country",
    MAX("Confirmed") AS "HighestConfirmedCases"
FROM 
    corona_dataset
GROUP BY 
    "Country/Region"
ORDER BY 
    "HighestConfirmedCases" DESC
LIMIT 1;

-- Q15. Find Country having lowest number of the death case

SELECT 
    "Country/Region" AS "Country",
    MIN("Deaths") AS "LowestDeathCases"
FROM 
    corona_dataset
GROUP BY 
    "Country/Region"
ORDER BY 
    "LowestDeathCases" ASC
LIMIT 1;

-- Q16. Find top 5 countries having highest recovered case

SELECT 
    "Country/Region" AS "Country",
    SUM("Recovered") AS "TotalRecoveredCases"
FROM 
    corona_dataset
GROUP BY 
    "Country/Region"
ORDER BY 
    "TotalRecoveredCases" DESC
LIMIT 5;