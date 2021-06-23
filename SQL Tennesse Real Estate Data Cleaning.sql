Select *
from PortfolioProject.dbo.[NashvilleHousing]



-- Standardize Date Format 

Select SaleDateConverted, convert(date, Saledate)
from PortfolioProject.dbo.[NashvilleHousing]

update [NashvilleHousing]
set saledate = convert(date, saledate)

Alter table NashvilleHousing 
Add SaleDateConverted date;

update [NashvilleHousing]
set saledateconverted = convert(date, saledate)



-- Populate Property address data


Select *
from PortfolioProject.dbo.[NashvilleHousing]
--Where propertyaddress is null
order by parcelId



Select a.parcelID,a.PropertyAddress, b.parcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.[NashvilleHousing] a
join PortfolioProject.dbo.[NashvilleHousing] b
 on a.parcelID = b.parcelID
and a.uniqueID <> b.uniqueID
Where a.propertyaddress is null


Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.[NashvilleHousing] a
join PortfolioProject.dbo.[NashvilleHousing] b
 on a.parcelID = b.parcelID
and a.uniqueID <> b.uniqueID



-- Breaking out address into individual columns (Address, City, State) 





Select PropertyAddress
from PortfolioProject.dbo.[NashvilleHousing]
--Where propertyaddress is null
-- order by parcelId

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) as Address

from PortfolioProject.dbo.[NashvilleHousing]


Alter table NashvilleHousing 
Add PropertySplitAddress Nvarchar(255);

update [NashvilleHousing]
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


Alter table NashvilleHousing 
Add PropertySplitCity Nvarchar(255);

update [NashvilleHousing]
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress))


Select *
from PortfolioProject.dbo.[NashvilleHousing]





Select OwnerAddress
from PortfolioProject.dbo.[NashvilleHousing]


Select 
PARSENAME(Replace(owneraddress, ',', '.') ,3)
, PARSENAME(Replace(owneraddress, ',', '.') ,2)
, PARSENAME(Replace(owneraddress, ',', '.') ,1)
from PortfolioProject.dbo.[NashvilleHousing]



Alter table NashvilleHousing 
Add OwnerSplitAddress Nvarchar(255);

update [NashvilleHousing]
set OwnerSplitAddress = PARSENAME(Replace(owneraddress, ',', '.') ,3)


Alter table NashvilleHousing 
Add OwnerSplitCity Nvarchar(255);

update [NashvilleHousing]
set OwnerSplitCity = PARSENAME(Replace(owneraddress, ',', '.') ,2)


Alter table NashvilleHousing 
Add OwnerSplitState Nvarchar(255);

update [NashvilleHousing]
set OwnerSplitState = PARSENAME(Replace(owneraddress, ',', '.') ,1)


Select *
from PortfolioProject.dbo.[NashvilleHousing]


--- Change Y and N to Yes and No in "Sold as Vacant" field



Select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.[NashvilleHousing]
Group by SoldAsVacant
order by 2



select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
  when SoldAsVacant = 'N' then 'No'
  else SoldAsVacant
  end
from PortfolioProject.dbo.[NashvilleHousing]


update NashvilleHousing
Set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
  when SoldAsVacant = 'N' then 'No'
  else SoldAsVacant
  end




-- Remove Duplicates

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

from PortfolioProject.dbo.[NashvilleHousing]
-- ORDER BY ParcelID
)
Select *
from RowNumCTE
Where row_num > 1 
order by PropertyAddress




-- Delete unused columns 

Select *
from PortfolioProject.dbo.[NashvilleHousing]

ALTER TABLE PortfolioProject.dbo.[NashvilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.[NashvilleHousing]
DROP COLUMN SaleDate
