USE Housing_DB

select *
from Housing

--standardization date field

Update Housing
Set SaleDate = CONVERT(date,SaleDate)

--Populate property address data

select *
from Housing
where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from Housing a
Join Housing b
	ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

Update a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Housing a
Join Housing b
	ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

--Divide address to state, city, address

select propertyaddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) State
from Housing

Alter table Housing
ADD Address nvarchar(255), City nvarchar(255);

Update Housing
Set Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1),
	City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

Select *
from Housing

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from Housing

Alter table Housing
ADD Owner_Address nvarchar(255), Owner_City nvarchar(255),Owner_State nvarchar(255);

Update Housing
Set Owner_Address = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	Owner_City = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	Owner_State = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select *
from Housing

--Changing Y & N to Yes and No

Select Distinct(SoldAsVacant)
from Housing

--Remove Duplicates

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

From Housing
--order by ParcelID
)
Select * 
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From Housing


ALTER TABLE housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


Select *
From Housing