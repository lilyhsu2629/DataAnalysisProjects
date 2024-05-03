# US Household Income Data Cleaning
CREATE SCHEMA IF NOT EXISTS US_Household_Income;
USE US_Household_Income;

SELECT *
FROM us_household_income;

SELECT *
FROM us_household_income_statistics;



ALTER TABLE us_household_income_statistics RENAME COLUMN `嚜磨d` TO id;



SELECT COUNT(*)
FROM us_household_income;

SELECT COUNT(*)
FROM us_household_income_statistics;

# Remove Duplicates
SELECT id, COUNT(id)
FROM us_household_income
GROUP BY id
HAVING COUNT(id) > 1;

SELECT row_id, row_num
FROM(SELECT row_id,
		id,
		ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) row_num
	 FROM us_household_income) duplicates
WHERE row_num > 1;

DELETE FROM us_household_income
WHERE row_id IN(
	SELECT row_id
	FROM(SELECT row_id,
			id,
			ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) row_num
		 FROM us_household_income) duplicates
	WHERE row_num > 1);

SELECT id, COUNT(id)
FROM us_household_income_statistics
GROUP BY id
HAVING COUNT(id) > 1;



# Fix State_Name typo & upper/lower case
SELECT COUNT(DISTINCT State_Name)
FROM us_household_income;

SELECT DISTINCT State_Name
FROM us_household_income;

UPDATE us_household_income
SET State_Name = 'Georgia'
WHERE State_Name = 'georia';

SELECT State_Name, 
	UPPER(LEFT(State_Name, 1)), 
    LOWER(RIGHT(State_Name, LENGTH(State_Name)-1)),
    CONCAT(UPPER(LEFT(State_Name, 1)), LOWER(RIGHT(State_Name, LENGTH(State_Name)-1)))
FROM us_household_income;

UPDATE us_household_income
SET State_Name = CONCAT(UPPER(LEFT(State_Name, 1)), LOWER(RIGHT(State_Name, LENGTH(State_Name)-1)));

# Check State_ab
SELECT COUNT(DISTINCT State_ab)
FROM us_household_income;



# Fix Blanks
SELECT *
FROM us_household_income
WHERE Place = ''
OR Place IS NULL;

SELECT *
FROM us_household_income
WHERE County = 'Autauga County'
AND City = 'Vinemont';

UPDATE us_household_income
SET Place = 'Autaugaville'
WHERE County = 'Autauga County'
AND City = 'Vinemont';



# Fix Type typo
SELECT Type, COUNT(Type)
FROM us_household_income
GROUP BY Type
ORDER BY Type;

UPDATE us_household_income
SET Type = 'Borough'
WHERE Type = 'Boroughs';



# Check ALand & AWater
SELECT DISTINCT ALand
FROM us_household_income
WHERE ALand IN(0, '', NULL);

SELECT DISTINCT AWater
FROM us_household_income
WHERE AWater IN(0, '', NULL);

SELECT *
FROM us_household_income
WHERE ALand IN(0, '', NULL)
AND AWater IN(0, '', NULL);



SELECT *
FROM us_household_income;

SELECT *
FROM us_household_income_statistics;