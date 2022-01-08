/*

Cleaning Data with SQL Queries

*/

SELECT *
FROM PortfolioProject.dbo.NashVilleHousing

-- Standardize Date Format (from Datetime to Date)


ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE

UPDATE NashVilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

SELECT SaleDateConverted
FROM NashVilleHousing


-- Populate Property Address Data


SELECT *
FROM NashVilleHousing
WHERE PropertyAddress IS NULL

SELECT Nash1.ParcelID, Nash1.PropertyAddress, 
		Nash2.ParcelID, Nash2.PropertyAddress,
		ISNULL(Nash1.PropertyAddress, Nash2.PropertyAddress)
FROM NashVilleHousing Nash1
JOIN NashVilleHousing Nash2
	ON Nash1.ParcelID = Nash2.ParcelID
	AND Nash1.[UniqueID ] <> Nash2.[UniqueID ] 
WHERE Nash1.PropertyAddress IS NULL

UPDATE Nash1
SET PropertyAddress = ISNULL(Nash1.PropertyAddress, Nash2.PropertyAddress)
FROM NashVilleHousing Nash1
JOIN NashVilleHousing Nash2
	ON Nash1.ParcelID = Nash2.ParcelID
	AND Nash1.[UniqueID ] <> Nash2.[UniqueID ] 
WHERE Nash1.PropertyAddress IS NULL


-- Breaking out Address ino Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM NashVilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM NashVilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE NashVilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

UPDATE NashVilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT OwnerAddress
FROM NashVilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashVilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE NashVilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE NashVilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE NashVilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


--Change Y and N to Yes and No in "Sold as Vacant" field


SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM NashVilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		 WHEN SoldAsVacant = 'N' THEN 'NO'
		 ELSE SoldAsVacant
		 END
FROM NashVilleHousing

UPDATE NashVilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		 WHEN SoldAsVacant = 'N' THEN 'NO'
		 ELSE SoldAsVacant
		 END
FROM NashVilleHousing


--Remove Duplicates


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

FROM PortfolioProject.dbo.NashVilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


--Delete Unused Columns


SELECT *
FROM NashVilleHousing

ALTER TABLE NashVilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashVilleHousing
DROP COLUMN SaleDate
