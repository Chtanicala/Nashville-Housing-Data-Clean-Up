-- Cleaning Data

SELECT *
FROM NashvilleHousingProject..NashvilleHousingData

-- Standardize Date

SELECT SaleDate, CONVERT(Date,SaleDate), SaleDateConversion
FROM NashvilleHousingProject..NashvilleHousingData

Update NashvilleHousingData
Set SaleDate = Convert(Date,SaleDate)

Alter Table NashvilleHousingData
Add SaleDateConversion Date;

Update NashvilleHousingData
Set SaleDateConversion = Convert(Date,SaleDate)

--Populate Property Addres Data
SELECT *
FROM NashvilleHousingProject..NashvilleHousingData
--Where PropertyAddress is NUll
Order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousingProject..NashvilleHousingData as A
--Where PropertyAddress is NUll
join NashvilleHousingProject..NashvilleHousingData as B
	on a.ParcelID = b. ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousingProject..NashvilleHousingData as A
--Where PropertyAddress is NUll
join NashvilleHousingProject..NashvilleHousingData as B
	on a.ParcelID = b. ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]

-- Breaking Out Address into Individual Columns (address, city, state)

SELECT 
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, Substring(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM NashvilleHousingProject..NashvilleHousingData

Alter Table NashvilleHousingData
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousingData
Set PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter Table NashvilleHousingData
Add PropertySplitCity nvarchar(255);

Update NashvilleHousingData
Set PropertySplitCity = Substring(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select PropertySplitAddress, PropertySplitCity
FROM NashvilleHousingProject..NashvilleHousingData

-- Owner Address Split
Select OwnerAddress
FROM NashvilleHousingProject..NashvilleHousingData

Select
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
FROM NashvilleHousingProject..NashvilleHousingData

Alter Table NashvilleHousingData
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousingData
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter Table NashvilleHousingData
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousingData
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

Alter Table NashvilleHousingData
Add OwnerSplitState nvarchar(255);

Update NashvilleHousingData
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

Select OwnerSplitState, OwnerSplitCity, OwnerSplitAddress
FROM NashvilleHousingProject..NashvilleHousingData

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select distinct(SoldAsVacant)
from NashvilleHousingProject..NashvilleHousingData

Select SoldAsVacant,
	CASE When SoldAsVacant = 'Y' Then 'Yes'
		 When SoldAsVacant = 'N' Then 'No'
		 Else SoldAsVacant
	END
FROM NashvilleHousingProject..NashvilleHousingData

UPDATE NashvilleHousingData
Set SoldAsVacant =
	CASE When SoldAsVacant = 'Y' Then 'Yes'
		 When SoldAsVacant = 'N' Then 'No'
		 Else SoldAsVacant
	END
FROM NashvilleHousingProject..NashvilleHousingData

-- Remove Duplicates
WITH RowNumCTE As(
Select *,
	ROW_NUMBER() over (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) as Row_Num
FROM NashvilleHousingProject..NashvilleHousingData
)
Select *
FROM RowNumCTE
Where row_num > 1

--Delete Unused Columns
Select *
From NashvilleHousingProject..NashvilleHousingData

Alter Table NashvilleHousingProject..NashvilleHousingData
Drop Column SaleDate
