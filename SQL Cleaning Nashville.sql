-- 1) Cleaning Data in SQL Series

Select *
From [Portfolio Project]..NashvilleHousing

-----------------------------------------------------------------------------------
-- 2) Standardize Date Format

Select SaleDateConverted, CONVERT(date,saledate)
From [Portfolio Project]..NashvilleHousing;

Update NashvilleHousing
Set SaleDate = CONVERT(Date,saledate);

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(date,Saledate);

-----------------------------------------------------------------------------------
-- 3) Populate Property Address Data

Select *
From [Portfolio Project]..NashvilleHousing
--Where PropertyAddress is null
order by ParcelID 

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project]..NashvilleHousing a
JOIN [Portfolio Project]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project]..NashvilleHousing a
JOIN [Portfolio Project]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-----------------------------------------------------------------------------------
-- 4) Breaking out Address Into Individual Columns (Address, City, Sate)

Select PropertyAddress
From [Portfolio Project]..NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From [Portfolio Project]..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(225);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))

Select *
From [Portfolio Project]..NashvilleHousing

-- PARSENAME TO SEPARATE COLUMN

Select 
PARSENAME(Replace(OwnerAddress,',', '.') ,3)
,PARSENAME(Replace(OwnerAddress,',', '.') ,2)
,PARSENAME(Replace(OwnerAddress,',', '.') ,1)
From [Portfolio Project]..NashvilleHousing

-- Update Table

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',', '.') ,3)

ALTER TABLE NashvilleHousing
Add OwnerySplitCity Nvarchar(225);

Update NashvilleHousing
Set OwnerySplitCity = PARSENAME(Replace(OwnerAddress,',', '.') ,2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',', '.') ,1)

-- Verification

Select *
From [Portfolio Project]..NashvilleHousing

------------------------------------------------------------------------------------
-- 5) Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From [Portfolio Project]..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
	when SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
From [Portfolio Project]..NashvilleHousing

--Update Table

UPDATE NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	when SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

-- Verification

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From [Portfolio Project]..NashvilleHousing
Group by SoldAsVacant
Order by 2

----------------------------------------------------------------------------------------
-- 6) Remove Duplicates

WITH RowNumCTE as(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY
		UniqueID
		) row_num			

From [Portfolio Project]..NashvilleHousing
)
DELETE 
From RowNumCTE
WHERE row_num > 1 

-- Verification

WITH RowNumCTE as(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY
		UniqueID
		) row_num			

From [Portfolio Project]..NashvilleHousing
)
Select *
From RowNumCTE
WHERE row_num > 1 
Order by PropertyAddress

--------------------------------------------------------------------------------------
-- Delete Unused Colomns ( not from Raw Data )

Select *
From [Portfolio Project]..NashvilleHousing

Alter Table [Portfolio Project]..NashvilleHousing
Drop Column OwnerAddress,TaxDistrict,PropertyAddress

Alter Table [Portfolio Project]..NashvilleHousing
Drop Column SaleDate



