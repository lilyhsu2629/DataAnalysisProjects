USE data_cleaning_nashvillehousing;

SELECT *
FROM nashville_housing;


-- Quick Overview --
SELECT (SELECT DISTINCT(OwnerSplitState) FROM nashville_housing) AS State,
	   COUNT(*) AS TotalHousingSale,
	   AVG(SalePrice) AS AvgHousingSalePrice,
       MIN(SaleDate) AS StartDate,
       MAX(SaleDate) AS EndDate
FROM nashville_housing;





-- Sale Price Info by Year --
SELECT DISTINCT(YEAR(SaleDate)) AS SaleYear, 
	   COUNT(*) OVER(PARTITION BY YEAR(SaleDate)) AS NumOfSale,
       AVG(SalePrice) OVER(PARTITION BY YEAR(SaleDate))  AS AvgSalePrice_Year,
	   MAX(SalePrice) OVER(PARTITION BY YEAR(SaleDate))  AS MaxSalePrice_Year,
       MIN(SalePrice) OVER(PARTITION BY YEAR(SaleDate)) AS MinSalePrice_Year
FROM nashville_housing;





-- Highest/Lowest Sale Price Property --
SELECT LandUse,
	   SalePrice,
       SaleDate,
       SoldAsVacant,
       PropertySplitCity,
       LegalReference
FROM nashville_housing
WHERE SalePrice = (SELECT MAX(SalePrice)
				   FROM nashville_housing);

SELECT LandUse,
	   SalePrice,
       SaleDate,
       SoldAsVacant,
       PropertySplitCity,
       LegalReference
FROM nashville_housing
WHERE SalePrice = (SELECT MIN(SalePrice)
				   FROM nashville_housing);





-- Sale Price Info by LandUse --
SELECT DISTINCT(LandUse),
	   COUNT(*) OVER(PARTITION BY LandUse) AS NumOfSale,
	   AVG(SalePrice) OVER(PARTITION BY LandUse) AS AvgSalePrice_LandUse,
       MAX(SalePrice) OVER(PARTITION BY LandUse)  AS MaxSalePrice_LandUse,
       MIN(SalePrice) OVER(PARTITION BY LandUse) AS MinSalePrice_LandUse
FROM nashville_housing
ORDER BY NumOfSale DESC;





-- LandUse Percentage --
WITH LandUsePctCTE AS(
SELECT DISTINCT(LandUse),
	   COUNT(*) OVER(PARTITION BY LandUse) AS NumOfSale,
       COUNT(*) OVER() AS TotalSale
FROM nashville_housing
)
SELECT LandUse,
	   (NumOfSale / TotalSale)*100 AS LandUsePct
FROM LandUsePctCTE
ORDER BY LandUsePct DESC;





-- Sale Price Info by SoldAsVacant --
SELECT DISTINCT(SoldAsVacant), 
	   COUNT(*) OVER(PARTITION BY SoldAsVacant) AS NumOfSale,
	   AVG(SalePrice) OVER(PARTITION BY SoldAsVacant) AS AvgSalePrice_SoldAsVacant,
       MAX(SalePrice) OVER(PARTITION BY SoldAsVacant)  AS MaxSalePrice_SoldAsVacant,
       MIN(SalePrice) OVER(PARTITION BY SoldAsVacant) AS MinSalePrice_SoldAsVacant
FROM nashville_housing
ORDER BY NumOfSale DESC;





-- SoldAsVacantPercentage for each LandUse --
WITH VacantPctCTE AS(
SELECT LandUse,
	   CASE
		 WHEN SoldAsVacant = 'Yes' THEN 1
         ELSE 0
	   END Vacant
FROM nashville_housing
ORDER BY SalePrice
)
SELECT LandUse,
	   (SUM(Vacant) / COUNT(*))*100 AS SoldAsVacantPct
FROM VacantPctCTE
GROUP BY LandUse
ORDER BY SoldAsVacantPct DESC;





-- Sale Price Info by PropertySplitCity --
SELECT DISTINCT(PropertySplitCity),
	   COUNT(*) OVER(PARTITION BY PropertySplitCity) AS NumOfSale,
       AVG(SalePrice) OVER(PARTITION BY PropertySplitCity) AS AvgSalePrice_PropertySplitCity,
       MAX(SalePrice) OVER(PARTITION BY PropertySplitCity)  AS MaxSalePrice_PropertySplitCity,
       MIN(SalePrice) OVER(PARTITION BY PropertySplitCity) AS MinSalePrice_PropertySplitCity
FROM nashville_housing
ORDER BY NumOfSale DESC;





-- City vs State Percentage --
WITH PropertySplitCityCTE AS(
SELECT DISTINCT(PropertySplitCity),
	   COUNT(*) OVER(PARTITION BY PropertySplitCity) AS NumOfSale,
       COUNT(*) OVER() AS TotalSale,
       AVG(SalePrice) OVER(PARTITION BY PropertySplitCity) AS AvgSalePrice_PropertySplitCity,
       AVG(SalePrice) OVER() AS AvgSalePrice_TN
FROM nashville_housing
)
SELECT PropertySplitCity AS PropertyCity,
	   (NumOfSale / TotalSale)*100 AS NumOfSalePct_cityVSstate,
       ROUND(((AvgSalePrice_PropertySplitCity - AvgSalePrice_TN) / AvgSalePrice_TN)*100,4) AS AvgSalePricePctDiff_cityVSstate
FROM PropertySplitCityCTE
ORDER BY NumOfSalePct_cityVSstate DESC;