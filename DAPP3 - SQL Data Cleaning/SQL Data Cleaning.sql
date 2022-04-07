select *
from [PortfolioProjekt]..[NashvilleHousing]
order by [UniqueID ]

-- SaleDate format change to date from datetime

select SaleDate, CONVERT(date, SaleDate)
from [PortfolioProjekt]..[NashvilleHousing]

ALTER TABLE PortfolioProjekt..NashvilleHousing
ALTER COLUMN SaleDate date

select SaleDate
from [PortfolioProjekt]..[NashvilleHousing]

-- Property Addres fill Null adresses
select *
from [PortfolioProjekt]..[NashvilleHousing]
WHERE PropertyAddress is null

select a.ParcelID, a.[UniqueID ], b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProjekt..NashvilleHousing a
JOIN PortfolioProjekt..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
--Where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProjekt..NashvilleHousing a
JOIN PortfolioProjekt..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null

-- BREAKING PROPERTYADDRES into INDIVIDUAL COLUMNS (ADRESS, CITY, STATE)

select PropertyAddress, LEN(PropertyAddress)
from [PortfolioProjekt]..[NashvilleHousing]

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS ADRESS,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM PortfolioProjekt..NashvilleHousing

ALTER TABLE PortfolioProjekt..NashvilleHousing
ADD PropertyAdresssplitted Nvarchar(255)

ALTER TABLE PortfolioProjekt..NashvilleHousing
ADD PropertyCitysplitted Nvarchar(255)

UPDATE PortfolioProjekt..NashvilleHousing
SET PropertyAdresssplitted = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

UPDATE PortfolioProjekt..NashvilleHousing
SET PropertyCitysplitted = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

select *
from [PortfolioProjekt]..[NashvilleHousing]

-- BREAKING OWNERADDRES into INDIVIDUAL COLUMNS (ADRESS, CITY, STATE)

select OwnerAddress
from [PortfolioProjekt]..[NashvilleHousing]

select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
from [PortfolioProjekt]..[NashvilleHousing]

ALTER TABLE PortfolioProjekt..NashvilleHousing
ADD OwnerAdresssplitted Nvarchar(255)

UPDATE PortfolioProjekt..NashvilleHousing
SET OwnerAdresssplitted = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE PortfolioProjekt..NashvilleHousing
ADD OwnerCitysplitted Nvarchar(255)

UPDATE PortfolioProjekt..NashvilleHousing
SET OwnerCitysplitted = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE PortfolioProjekt..NashvilleHousing
ADD OwnerStatesplitted Nvarchar(255)

UPDATE PortfolioProjekt..NashvilleHousing
SET OwnerStatesplitted = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

select *
from [PortfolioProjekt]..[NashvilleHousing]

--Change Y and N to YES and NO in "Sold as Vacant" field

select distinct SoldAsVacant, COUNT(SoldAsVacant)
from [PortfolioProjekt]..[NashvilleHousing]
GROUP BY SoldAsVacant
order by 2

Select SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'YES' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'YESes' THEN 'Yes'
	ELSE SoldAsVacant
	END
from [PortfolioProjekt]..[NashvilleHousing]

UPDATE PortfolioProjekt..NashvilleHousing
SET SoldAsVacant = 
CASE
	WHEN SoldAsVacant = 'YES' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'YESes' THEN 'Yes'
	ELSE SoldAsVacant
	END


--REMOVE Duplicates with CTE

select *
from [PortfolioProjekt]..[NashvilleHousing]
Order BY [UniqueID ]

Select a.[UniqueID ], b.[UniqueID ], a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, a.SaleDate, b.SaleDate, a. SalePrice, b.SalePrice, a.OwnerName, a.LegalReference, b.LegalReference
from [PortfolioProjekt]..[NashvilleHousing] a
JOIN [PortfolioProjekt]..[NashvilleHousing] b
	on a.[UniqueID ] <> b.[UniqueID ]
	AND a.ParcelID = b.ParcelID
	AND a.PropertyAddress = b.PropertyAddress
	AND a.SaleDate = b.SaleDate
	AND a. SalePrice = b.SalePrice
	AND a.LegalReference = b.LegalReference
Order BY a.[UniqueID ]



With RowNumCTE AS(
Select *,
		ROW_NUMBER() OVER (
		PARTITION BY	ParcelID,
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
						ORDER BY UniqueID 
						) Row#
from [PortfolioProjekt]..[NashvilleHousing]
--ORDER by ParcelID
)
Select *
--Delete
From RowNumCTE
Where Row# = 1
Order by [UniqueID ]

-- DELETE UNUSED COLUMNS

select *
from [PortfolioProjekt]..[NashvilleHousing]
Order BY [UniqueID ]  

ALTER TABLE [PortfolioProjekt]..[NashvilleHousing]
DROP COLUMN OwnerAddress, [TaxDistrict], [PropertyAddress], 