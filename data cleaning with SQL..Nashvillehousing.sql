--Project: Data cleanling with SQL queries

SELECT *
FROM PortfolioProject..nashvillehousing


--Standadize date format

SELECT saledateconverted --CONVERT(date, saledate) as SaleDate
FROM PortfolioProject..nashvillehousing

ALTER TABLE portfolioproject..Nashvillehousing
Add SaleDateconverted date;

UPDATE portfolioproject..Nashvillehousing
SET SaleDateconverted = CONVERT(date, saledate)


--Populate property address data

SELECT A.parcelid, A.propertyaddress, B.parcelid, B.propertyaddress, ISNULL(A.propertyaddress, B.propertyaddress)
FROM PortfolioProject..nashvillehousing as A
JOIN PortfolioProject..nashvillehousing as B
	on A.parcelid = b.parcelid
	AND A.[uniqueid] <> B.[uniqueid]
WHERE A.propertyaddress is null

UPDATE A
SET propertyaddress = ISNULL(A.propertyaddress, B.propertyaddress)
FROM PortfolioProject..nashvillehousing as A
JOIN PortfolioProject..nashvillehousing as B
	on A.parcelid = b.parcelid
	AND A.[uniqueid] <> B.[uniqueid]
WHERE A.propertyaddress is null


--Breaking out Address into individual columns (Address, City, State)

SELECT
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1) as Address,
SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1, LEN(propertyaddress)) as City
FROM PortfolioProject..nashvillehousing

ALTER TABLE portfolioproject..Nashvillehousing
Add preopertysplitaddress nvarchar(255);

UPDATE portfolioproject..Nashvillehousing
SET preopertysplitaddress =SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1)

ALTER TABLE portfolioproject..Nashvillehousing
Add propertycity nvarchar(255);

UPDATE portfolioproject..Nashvillehousing
SET propertycity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1, LEN(propertyaddress))



SELECT
PARSENAME(REPLACE(owneraddress, ',', '.'), 3),
PARSENAME(REPLACE(owneraddress, ',', '.'), 2),
PARSENAME(REPLACE(owneraddress, ',', '.'), 1)
FROM PortfolioProject..nashvillehousing


ALTER TABLE portfolioproject..Nashvillehousing
Add Owenersplitaddress nvarchar(255);

UPDATE portfolioproject..Nashvillehousing
SET Owenersplitaddress = PARSENAME(REPLACE(owneraddress, ',', '.'), 3)

ALTER TABLE portfolioproject..Nashvillehousing
Add ownercity nvarchar(255);

UPDATE portfolioproject..Nashvillehousing
SET ownercity = PARSENAME(REPLACE(owneraddress, ',', '.'), 2)

ALTER TABLE portfolioproject..Nashvillehousing
Add ownerstate nvarchar(255);

UPDATE portfolioproject..Nashvillehousing
SET ownerstate = PARSENAME(REPLACE(owneraddress, ',', '.'), 1)


--Change Y and N as Yes and No in 'Sold as vacant' field

SELECT soldasvacant
, CASE when soldasvacant = 'Y' THEN 'Yes'
	   when soldasvacant = 'N' THEN 'No'
	   ELSE soldasvacant
	   END
FROM PortfolioProject..Nashvillehousing

UPDATE PortfolioProject..Nashvillehousing
SET soldasvacant = CASE when soldasvacant = 'Y' THEN 'Yes'
	   when soldasvacant = 'N' THEN 'No'
	   ELSE soldasvacant
	   END


--Remove Dupliates

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY parcelid,
			propertyaddress,
			saleprice,
			saledate,
			legalReference
			ORDER BY 
			uniqueid) row_num

FROM PortfolioProject..Nashvillehousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


--Delete unused column

ALTER TABLE PortfolioProject..Nashvillehousing
DROP COLUMN propertyaddress, taxdistrict, owneraddress

ALTER TABLE PortfolioProject..Nashvillehousing
DROP COLUMN saledate

