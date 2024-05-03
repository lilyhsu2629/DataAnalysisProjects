# Automated Data Cleaning
USE bakery;

SELECT * 
FROM us_household_income;

SELECT COUNT(*)
FROM us_household_income;


# CREATE PROCEDURE
DROP PROCEDURE IF EXISTS Copy_and_Clean_Data;
DELIMITER $$
CREATE PROCEDURE Copy_and_Clean_Data()
BEGIN


# 1. Create a copy of the Table
	CREATE TABLE IF NOT EXISTS `us_household_income_Cleaned` (
	  `row_id` int DEFAULT NULL,
	  `id` int DEFAULT NULL,
	  `State_Code` int DEFAULT NULL,
	  `State_Name` text,
	  `State_ab` text,
	  `County` text,
	  `City` text,
	  `Place` text,
	  `Type` text,
	  `Primary` text,
	  `Zip_Code` int DEFAULT NULL,
	  `Area_Code` int DEFAULT NULL,
	  `ALand` int DEFAULT NULL,
	  `AWater` int DEFAULT NULL,
	  `Lat` double DEFAULT NULL,
	  `Lon` double DEFAULT NULL,
	  `TimeStamp` TIMESTAMP DEFAULT NULL
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
    
    
    
# 2. Copy Date to New Table
	INSERT INTO us_household_income_Cleaned
    SELECT *, CURRENT_TIMESTAMP
    FROM us_household_income;



# 3. Data Cleanig Process
  # 1. Remove Duplicates
	DELETE FROM us_household_income_Cleaned
	WHERE row_id IN(
					SELECT row_id
					FROM(SELECT row_id, id, 
							ROW_NUMBER() OVER(PARTITION BY id, `TimeStamp` ORDER BY id, `TimeStamp`) row_num
						 FROM us_household_income_Cleaned) duplicates
					WHERE row_num > 1);

  # 2. Standardization
	UPDATE us_household_income_Cleaned
	SET State_Name = 'Georgia'
	WHERE State_Name = 'georia';

	UPDATE us_household_income_Cleaned
	SET State_Name = UPPER(State_Name);

	UPDATE us_household_income_Cleaned
	SET County = UPPER(County);

	UPDATE us_household_income_Cleaned
	SET City = UPPER(City);

	UPDATE us_household_income_Cleaned
	SET Place = UPPER(Place);

	UPDATE us_household_income_Cleaned
	SET Type = 'Borough'
	WHERE Type = 'Boroughs';

	UPDATE us_household_income_Cleaned
	SET Type = 'CDP'
	WHERE Type = 'CPD';

	SELECT *
    FROM us_household_income_Cleaned;
	
END $$
DELIMITER ;


call bakery.Copy_and_Clean_Data();

SELECT DISTINCT(TimeStamp) 
    FROM us_household_income_Cleaned;



# DEBUGGING or CHECKING if Stored Procedure works
# Original Data Info:
SELECT row_id, id, row_num
FROM(
	SELECT row_id, id, 
		ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) row_num
	FROM us_household_income
    ) duplicates
WHERE row_num > 1;

SELECT COUNT(row_id)
FROM us_household_income;

SELECT State_Name, COUNT(State_Name)
FROM us_household_income
GROUP BY State_Name;

# After the CleaningProcedure Info:
SELECT row_id, id, row_num
FROM(
	SELECT row_id, id, 
		ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) row_num
	FROM us_household_income_Cleaned
    ) duplicates
WHERE row_num > 1;

SELECT COUNT(row_id)
FROM us_household_income_Cleaned;

SELECT State_Name, COUNT(State_Name)
FROM us_household_income_Cleaned
GROUP BY State_Name;





# CREATE EVENT
DROP EVENT IF EXISTS run_data_cleaning;
CREATE EVENT run_data_cleaning
ON SCHEDULE EVERY 1 MINUTE
DO CALL Copy_and_Clean_Data();


SELECT *
FROM bakery.us_household_income_Cleaned;

SELECT DISTINCT TimeStamp 
FROM bakery.us_household_income_Cleaned;

