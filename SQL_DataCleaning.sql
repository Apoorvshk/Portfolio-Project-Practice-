/*

Cleaning data in SQL Queries

*/

SELECT *
FROM [Portfolio Project]..NashvilleHousing

---------------------------------------------------------------------------

--Standardize Date Format

ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD SaleDateConverted Date

SELECT SaleDate--, CONVERT(Date, SaleDate)
FROM [Portfolio Project]..NashvilleHousing

UPDATE [Portfolio Project]..NashvilleHousing
SET	SaleDateConverted = CONVERT(Date, SaleDate)



---------------------------------------------------------------------------

--Populate Property Address data

SELECT * --PropertyAddress 
FROM [Portfolio Project]..NashvilleHousing
WHERE PropertyAddress is null

SELECT  count(DISTINCT ParcelID)--, PropertyAddress
FROM [Portfolio Project]..NashvilleHousing

SELECT count(*)
FROM [Portfolio Project]..NashvilleHousing


SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM [Portfolio Project]..NashvilleHousing A
JOIN [Portfolio Project]..NashvilleHousing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM [Portfolio Project]..NashvilleHousing A
JOIN [Portfolio Project]..NashvilleHousing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is NULL


---------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address1,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)-1) as Address2
FROM [Portfolio Project]..NashvilleHousing

ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255), PropertySplitCity NVARCHAR(255)


--ALTER TABLE [Portfolio Project]..NashvilleHousing ALTER COLUMN Address1 VARCHAR(255)

UPDATE [Portfolio Project]..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1),
PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)-1)

SELECT PropertySplitAddress, PropertySplitCity
FROM [Portfolio Project]..NashvilleHousing

SELECT *
FROM [Portfolio Project]..NashvilleHousing

SELECT OwnerAddress
FROM [Portfolio Project]..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as OwnerSplitAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as OwnerSplitCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as OwnerSplitState
FROM [Portfolio Project]..NashvilleHousing


ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE [Portfolio Project]..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD OwnerSplitcity NVARCHAR(255)

UPDATE [Portfolio Project]..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE [Portfolio Project]..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM [Portfolio Project]..NashvilleHousing

SELECT *
FROM [Portfolio Project]..NashvilleHousing



---------------------------------------------------------------------------

-- Change Y and n to Yes and in "Sold as Vacant" field

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM [Portfolio Project]..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM [Portfolio Project]..NashvilleHousing

UPDATE [Portfolio Project]..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END

---------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM [Portfolio Project]..NashvilleHousing 
)

--SELECT *
--FROM RowNumCTE
--WHERE row_num > 1
--ORDER BY PropertyAddress

DELETE 
FROM RowNumCTE
WHERE row_num > 1


---------------------------------------------------------------------------

--Delete Unused Columns

SELECT *
FROM [Portfolio Project]..NashvilleHousing

ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP COLUMN SaleDate