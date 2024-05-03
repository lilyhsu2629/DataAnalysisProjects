# US Household Income Exploratory Data Analysis
USE US_Household_Income;

SELECT *
FROM us_household_income;

SELECT *
FROM us_household_income_statistics;



# States with largest Land/Water
SELECT State_Name, SUM(ALand)
FROM us_household_income
GROUP BY State_Name
ORDER BY SUM(ALand) DESC
LIMIT 10;

SELECT State_Name, SUM(AWater)
FROM us_household_income
GROUP BY State_Name
ORDER BY SUM(AWater) DESC
LIMIT 10;


SELECT *
FROM us_household_income u
JOIN us_household_income_statistics us
	ON u.id = us.id
WHERE Mean != 0
AND Median != 0
AND Stdev != 0
AND sum_w != 0;



# States & Avg_Mean_Income / States & Avg_Median_Income
SELECT u.State_Name, ROUND(AVG(Mean),1), ROUND(AVG(Median),1) 
FROM us_household_income u
JOIN us_household_income_statistics us
	ON u.id = us.id
WHERE Mean != 0
AND Median != 0
AND Stdev != 0
AND sum_w != 0
GROUP BY u.State_Name
ORDER BY 1
;



# Types & Avg_Mean_Income / Types & Avg_Median_Income
SELECT Type, COUNT(Type), ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_household_income u
JOIN us_household_income_statistics us
	ON u.id = us.id
WHERE Mean != 0
AND Median != 0
AND Stdev != 0
AND sum_w != 0
GROUP BY Type
ORDER BY COUNT(Type) DESC;



# Types like Community, place, Urban rank the lowest in both avg_mean & avg_median
# Check which state does these types locate
SELECT *
FROM us_household_income u
JOIN us_household_income_statistics us
	ON u.id = us.id
WHERE Type IN ('Community', 'place', 'urban');



# Highest Income City
SELECT u.State_Name, City, ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_household_income u
JOIN us_household_income_statistics us
	ON u.id = us.id
WHERE Mean != 0
AND Median != 0
AND Stdev != 0
AND sum_w != 0
GROUP BY u.State_Name, City
ORDER BY ROUND(AVG(Mean),1) DESC;