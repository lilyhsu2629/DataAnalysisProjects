DROP DATABASE IF EXISTS data_cleaning_nashvillehousing;
CREATE DATABASE IF NOT EXISTS data_cleaning_nashvillehousing;

USE data_cleaning_nashvillehousing;


-- Create Table --
DROP TABLE IF EXISTS nashville_housing;
CREATE TABLE nashville_housing(
UniqueID INT NOT NULL,
ParcelID VARCHAR(255),
LandUse VARCHAR(255),
PropertyAddress VARCHAR(255),
SaleDate DATE,
SalePrice INT,
LegalReference VARCHAR(255),
SoldAsVacant VARCHAR(3),
OwnerName VARCHAR(255),
OwnerAddress VARCHAR(255),
Acreage DECIMAL(6,2),
TaxDistrict VARCHAR(255),
LandValue INT,
BuildingValue INT,
TotalValue INT,
YearBuilt INT,
Bedrooms INT,
FullBath INT,
HalfBath INT
);

SHOW COLUMNS FROM nashville_housing;

SHOW VARIABLES LIKE '%secure%';
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Nashville Housing Data for Data Cleaning.csv'
INTO TABLE nashville_housing
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES(
UniqueID,
ParcelID,
LandUse,
PropertyAddress,
SaleDate,
SalePrice,
LegalReference,
SoldAsVacant,
OwnerName,
OwnerAddress,
Acreage,
TaxDistrict,
LandValue,
BuildingValue,
TotalValue,
YearBuilt,
Bedrooms,
FullBath,
HalfBath
);

SELECT *
FROM nashville_housing
ORDER BY UniqueID;





-- Populate Property Address data --
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, COALESCE(a.PropertyAddress, b.PropertyAddress)
FROM nashville_housing a
JOIN nashville_housing b ON a.ParcelID = b.ParcelID 
						 AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE nashville_housing a
JOIN nashville_housing b ON a.ParcelID = b.ParcelID 
						 AND a.UniqueID != b.UniqueID
SET a.PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;





-- Breaking out Property Address into Individual Columns (Address, City) --
SELECT PropertyAddress
FROM nashville_housing;

SELECT SUBSTR(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1) AS Address,
	   SUBSTR(PropertyAddress, INSTR(PropertyAddress, ',') + 2, LENGTH(PropertyAddress)) AS City
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD PropertySplitAddress VARCHAR(255);

UPDATE nashville_housing
SET PropertySplitAddress = TRIM(SUBSTR(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1));

ALTER TABLE nashville_housing
ADD PropertySplitCity VARCHAR(255);

UPDATE nashville_housing
SET PropertySplitCity = TRIM(SUBSTR(PropertyAddress, INSTR(PropertyAddress, ',') + 2, LENGTH(PropertyAddress)));





-- Breaking out Owner Address into Individual Columns (Address, City, State) --
SELECT OwnerAddress
FROM nashville_housing;

SELECT SUBSTRING_INDEX(OwnerAddress, ',', 1) AS Address,
	   SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS City,
       SUBSTRING_INDEX(OwnerAddress, ',', -1) AS State
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD OwnerSplitAddress VARCHAR(255);

UPDATE nashville_housing
SET OwnerSplitAddress = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1));

ALTER TABLE nashville_housing
ADD OwnerSplitCity VARCHAR(255);

UPDATE nashville_housing
SET OwnerSplitCity = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1));

ALTER TABLE nashville_housing
ADD OwnerSplitState VARCHAR(255);

UPDATE nashville_housing
SET OwnerSplitState = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1));





-- Change Y and N to Yes and No in SoldAsVacant Field --
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM nashville_housing
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant);

SELECT SoldAsVacant,
	   CASE
			WHEN SoldAsVacant = 'Y' THEN 'Yes'
            WHEN SoldAsVacant = 'N' THEN 'No'
            ELSE SoldAsVacant
		END SoldAsVacant_mod
FROM nashville_housing;

UPDATE nashville_housing
SET SoldAsVacant = CASE
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
					END;





-- Modify LandUse Field --
SELECT DISTINCT(LandUse), COUNT(LandUse)
FROM nashville_housing
GROUP BY LandUse
ORDER BY COUNT(LandUse) DESC;

SELECT CASE
         WHEN LandUse = 'VACANT RES LAND' THEN 'VACANT RESIDENTIAL LAND'
         WHEN LandUse = 'VACANT RESIENTIAL LAND' THEN 'VACANT RESIDENTIAL LAND'
         WHEN LandUse = 'RESIDENTIAL CONDO' THEN 'CONDO'
         WHEN LandUse = 'SINGLE FAMILY' THEN 'SINGLE FAMILY'
         WHEN LandUse = 'VACANT RESIDENTIAL LAND' THEN 'VACANT RESIDENTIAL LAND'
         WHEN LandUse = 'ZERO LOT LINE' THEN 'ZERO LOT LINE'
		 WHEN LandUse = 'DUPLEX' THEN 'DUPLEX/TRIPLEX/QUADPLEX'
		 WHEN LandUse = 'TRIPLEX' THEN 'DUPLEX/TRIPLEX/QUADPLEX'
		 WHEN LandUse = 'QUADPLEX' THEN 'DUPLEX/TRIPLEX/QUADPLEX'
		 ELSE 'OTHER'
	   END LandUse_Group,
       COUNT(LandUse)
FROM nashville_housing
GROUP BY LandUse_Group
ORDER BY COUNT(LandUse) DESC;

UPDATE nashville_housing
SET LandUse = CASE
				WHEN LandUse = 'VACANT RES LAND' THEN 'VACANT RESIDENTIAL LAND'
				WHEN LandUse = 'VACANT RESIENTIAL LAND' THEN 'VACANT RESIDENTIAL LAND'
				WHEN LandUse = 'RESIDENTIAL CONDO' THEN 'CONDO'
				WHEN LandUse = 'SINGLE FAMILY' THEN 'SINGLE FAMILY'
				WHEN LandUse = 'VACANT RESIDENTIAL LAND' THEN 'VACANT RESIDENTIAL LAND'
				WHEN LandUse = 'ZERO LOT LINE' THEN 'ZERO LOT LINE'
				WHEN LandUse = 'DUPLEX' THEN 'DUPLEX/TRIPLEX/QUADPLEX'
                WHEN LandUse = 'TRIPLEX' THEN 'DUPLEX/TRIPLEX/QUADPLEX'
                WHEN LandUse = 'QUADPLEX' THEN 'DUPLEX/TRIPLEX/QUADPLEX'
			    ELSE 'OTHER'
			 END;





-- Modify LandUse Field --
SELECT PropertySplitCity,
	   COUNT(*)
FROM nashville_housing
GROUP BY PropertySplitCity;

SELECT PropertySplitAddress, 
	   PropertySplitCity
FROM nashville_housing
WHERE PropertySplitCity = 'UNKNOWN';

SELECT DISTINCT(PropertySplitCity)
FROM nashville_housing
WHERE PropertySplitAddress LIKE '%5TH AVE N%';

SELECT PropertySplitCity,
	   CASE
		 WHEN PropertySplitCity = 'UNKNOWN' THEN 'NASHVILLE'
         ELSE PropertySplitCity
	   END PropertySplitCity_mod
FROM nashville_housing
WHERE PropertySplitCity = 'UNKNOWN';

UPDATE nashville_housing
SET PropertySplitCity = CASE
						  WHEN PropertySplitCity = 'UNKNOWN' THEN 'NASHVILLE'
						  ELSE PropertySplitCity
						 END;





-- Modify OwnerSplitState Field --
SELECT DISTINCT(OwnerSplitState)
FROM nashville_housing;

UPDATE nashville_housing
SET OwnerSplitState = 'TN';





-- Save Duplicates in a Temp Table & Remove Duplicates --
DROP TEMPORARY TABLE IF EXISTS duplicates;
CREATE TEMPORARY TABLE IF NOT EXISTS duplicates AS
WITH RowNumCTE AS (
SELECT *,
	   ROW_NUMBER() OVER (
       PARTITION BY ParcelID,
					PropertyAddress,
                    SalePrice,
                    SaleDate,
                    LegalReference
                    ORDER BY
						UniqueID
                        ) row_num
FROM nashville_housing
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1;

SELECT *
FROM duplicates;

DELETE FROM nashville_housing
WHERE (UniqueID,
       ParcelID,
	   PropertyAddress,
       SalePrice,
       SaleDate,
       LegalReference)
IN (
SELECT UniqueID,
	   ParcelID,
	   PropertyAddress,
	   SalePrice,
	   SaleDate,
	   LegalReference
FROM duplicates);

SELECT *
FROM nashville_housing;