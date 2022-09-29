/*

Cleaning Data in SQL Queries

*/

Select * 
From PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Update PortfolioProject..NashvilleHousing
SET SaleDate = Convert(Date,SaleDate)

ALTER TABLE PortfolioProject..NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject..NashvilleHousing
SET SaleDateConverted = Convert(Date,SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

-- USING SUBSTRINGS

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


-- USING PARSENAME

Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3) AS Address,
PARSENAME(Replace(OwnerAddress, ',', '.'), 2) AS City,
PARSENAME(Replace(OwnerAddress, ',', '.'), 1) AS State
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group By SoldAsVacant
Order by 2

Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
SET SoldAsVacant =
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END;

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject..NashvilleHousing
)
Delete
From RowNumCTE
Where row_num > 1

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------