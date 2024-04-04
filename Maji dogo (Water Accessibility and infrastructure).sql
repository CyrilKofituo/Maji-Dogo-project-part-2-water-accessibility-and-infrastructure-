-- looking up the employee column
SELECT *
FROM employee
limit 5 ;


-- creating the new email address
SELECT
CONCAT(
LOWER(REPLACE(employee_name, ' ', '.')), '@ndogowater.gov') AS new_email 
FROM
employee;

-- updating the email column with the new email address
SET SQL_SAFE_UPDATES = 0;
UPDATE employee
SET email= CONCAT(
LOWER(REPLACE(employee_name, ' ', '.')), '@ndogowater.gov') ;

SELECT
LENGTH(phone_number)
FROM
employee;

select
length(TRIM(phone_number)) AS NEW_TELEPHONE
FROM employee;

UPDATE employee
SET phone_number = TRIM(phone_number) ;

-- lookup the visit table
SELECT*
FROM visits;

-- selecting the top 3 employees with the most visits by using their IDs
SELECT
    assigned_employee_id,
    count(visit_count) AS total_visit_count
FROM visits
GROUP BY assigned_employee_id
ORDER BY total_visit_count DESC
limit 3;

--  quering the name, email and phone number of the top 3 employees by using their IDs.
SELECT
employee_name,
email,
phone_number
FROM employee
WHERE assigned_employee_id IN (1,30,34) ;

-- looking up the location table 
SELECT *
FROM location
LIMIT 10;

-- records collected per town
SELECT 
town_name,
COUNT(location_type) AS records_per_town
FROM location
GROUP BY town_name
ORDER BY COUNT(location_type) DESC;

-- records collected per province
SELECT 
province_name,
COUNT(location_type) AS reords_per_province
FROM location
GROUP BY province_name
ORDER BY COUNT(location_type) DESC;

-- shows records collected, it then group them base on their town and province and then arranges the records in each province based on the towns in it
SELECT
province_name,
town_name,
COUNT(town_name) AS records_per_town
FROM location
GROUP BY province_name, town_name
ORDER BY records_per_town DESC;

-- shows the number of data collected from both rural and urban communities
SELECT
location_type,
count(location_type) as numb_sources
FROM location
GROUP BY location_type;

-- looking up the water source table
SELECT *
FROM water_source
LIMIT 10;

-- checking the number of people served by the water sources
SELECT
SUM(number_of_people_served) AS TOTAL_PEOPLE_SURVEYED
FROM water_source;

-- checking the toatal number of each water source
SELECT
type_of_water_source,
COUNT(type_of_water_source) AS NUMBER_OF_SOURCES
FROM water_source
GROUP BY type_of_water_source ;

-- calculating the average number of people served by each water type
SELECT
type_of_water_source,
ROUND(AVG(number_of_people_served), 0) AS AVG_NUMB_OF_PPLE_SERVED
FROM water_source
GROUP BY type_of_water_source;

-- total number of people that get water from each water source
SELECT 
type_of_water_source,
SUM(number_of_people_served) AS TOTAL_POPULATION_SERVED
FROM water_source
GROUP BY type_of_water_source
ORDER BY TOTAL_POPULATION_SERVED DESC;

-- number of people that use the various water sources
SELECT 
SUM(number_of_people_served) AS TOTAL_POPULATION_SERVED
FROM water_source;

-- percentage of the population that use each water sources
SELECT 
    type_of_water_source,
   ROUND((SUM(number_of_people_served) / (SELECT SUM(number_of_people_served) FROM water_source)) * 100) AS TOTAL_PCT_POPULATION_SERVED
FROM water_source
GROUP BY type_of_water_source
ORDER BY TOTAL_PCT_POPULATION_SERVED DESC;

-- ranking the sources base on the number of people that use it
SELECT 
type_of_water_source,
SUM(number_of_people_served) AS TOTAL_POPULATION_SERVED,
RANK() OVER (ORDER BY SUM(number_of_people_served)DESC) AS RANKING
FROM water_source
GROUP BY type_of_water_source
ORDER BY TOTAL_POPULATION_SERVED DESC ;

-- using rank to determine where to start from when we start working on the various sources e.g which shared tape to start with
SELECT
source_id,
type_of_water_source,
number_of_people_served,
RANK() OVER ( PARTITION BY type_of_water_source ORDER BY number_of_people_served desc) AS Priority_Ranking
FROM water_source
ORDER BY Priority_Ranking desc, type_of_water_source ;

-- looking up the visit table
SELECT *
FROM visits
LIMIT 10;

-- using the min and max to determine the 1st and last day of the survey 
SELECT
MIN(time_of_record) AS FRIST_DATE,
MAX(time_of_record) AS LAST_DATE
FROM visits;

-- calculatin the duration of the survey
SELECT
datediff( MAX(time_of_record), MIN(time_of_record)) AS DURATION_OF_SURVEY
FROM visits;

-- checking the time in queue, excluding sources that dont have any queue time
SELECT 
time_in_queue,
NULLIF(time_in_queue,0) AS NEW_TIME_IN_QUEUE
FROM visits;

-- calculating the averge time in queue
SELECT 
AVG(NULLIF(time_in_queue,0)) AS TOTAL_QUEUE_TIME
FROM visits;

-- average queue time per day
SELECT
dayname(time_of_record) AS DAY_OF_THE_WEEK,
ROUND(AVG(NULLIF(time_in_queue,0))) AS TOTAL_QUEUE_TIME
FROM visits
GROUP BY DAY_OF_THE_WEEK;

-- our of the day and the queue time
SELECT
TIME_FORMAT(TIME(time_of_record), '%H:00') AS HOUR_OF_DAY,
ROUND(AVG(NULLIF(time_in_queue,0))) AS TOTAL_QUEUE_TIME
FROM visits
GROUP BY HOUR_OF_DAY;

-- checking the time in queue for each hour of each day
SELECT
TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
-- Sunday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
ELSE NULL
END
),0) AS Sunday,
-- Monday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue
ELSE NULL
END
),0) AS Monday,

ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue
ELSE NULL
END
),0) AS Tuesday,

ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue
ELSE NULL
END
),0) AS Wednesday,

ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue
ELSE NULL
END
),0) AS Thursday,

ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue
ELSE NULL
END
),0) AS Friday,

ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue
ELSE NULL
END
),0) AS Saturday
FROM
visits
WHERE
time_in_queue != 0 -- this excludes other sources with 0 queue times
GROUP BY
hour_of_day
ORDER BY
hour_of_day;




