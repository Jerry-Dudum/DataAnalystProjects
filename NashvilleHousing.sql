/*

Data Cleaning in SQL Queries

*/

-- View entire table to determine what data needs to be cleaned and transformed

Select *
From DataClean.dbo.NashvilleHousing

-- Standardizing Date Format


ALTER TABLE NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

Select *
From DataClean.dbo.NashvilleHousing

-- Popualte NULL Property Address Data utilizing ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From DataClean.dbo.NashvilleHousing a
JOIN DataClean.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From DataClean.dbo.NashvilleHousing a
JOIN DataClean.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

-- Splitting PropertyAddress into Address & City Columns

Select PropertyAddress
From DataClean.dbo.NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as PropertyAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as PropertyCity
From DataClean.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertyAddressUpdated Nvarchar(255)

Update NashvilleHousing
SET PropertyAddressUpdated = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
Add PropertyCity Nvarchar(255)

Update NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select *
From DataClean.dbo.NashvilleHousing

-- Splitting Owner Address into Address, City, and State

Select OwnerAddress
From NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From DataClean.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerAddressUpdated Nvarchar(255)

Update NashvilleHousing
SET OwnerAddressUpdated = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerCity Nvarchar(255)

Update NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerState Nvarchar(255)

Update NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From DataClean.dbo.NashvilleHousing

-- Change Y and N to Yes and No in Sold as Vacant field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From DataClean.dbo.NashvilleHousing
Group by SoldAsVacant

Select SoldAsVacant
, Case when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   End
From DataClean.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = Case when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   End
From DataClean.dbo.NashvilleHousing

-- Removing Duplicate Values using CTE

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
					UniqueID
					) row_num
From DataClean.dbo.NashvilleHousing
)

DELETE 
From RowNumCTE
Where row_num > 1

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
					UniqueID
					) row_num
From DataClean.dbo.NashvilleHousing
)

Select *
From RowNumCTE
Where row_num > 1

-- Create new table with columns in correct order

Select UniqueID, ParcelID, LandUse, PropertyAddressUpdated, PropertyCity, SaleDateConverted, SalePrice, LegalReference, SoldAsVacant, OwnerName, OwnerAddressUpdated, OwnerCity, OwnerState, Acreage, LandValue, BuildingValue, TotalValue, YearBuilt, Bedrooms, FullBath, HalfBath
INTO NashvilleHousingClean
From NashvilleHousing

-- Rename columns in Object Explorer the below code can be used as well
--EXEC sp_rename 'NashvilleHousingClean.PropertyAddressUpdate', 'PropertyAddress', 'COLUMN' repeat for neccessary columns

Select *
From NashvilleHousingClean

