/*
	Cleaning data in sql query
*/


select * 
from NashvilleHousing

--Standadize data format
--if it doesn't update properly
select SaleDate, CONVERT(date,SaleDate)
from NashvilleHousing

Update NashvilleHousing
set SaleDate = CONVERT(date,SaleDate)

alter table NashvilleHousing --tambah column pada table
add SaleDateConverted Date; 

Update NashvilleHousing
set SaleDateConverted = CONVERT(date,SaleDate)

select SaleDateConverted, CONVERT(date,SaleDate)
from NashvilleHousing

---------------------------------------------------------------------
--Populate property address data

select *
from NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
-- menyamakan address dimana null dengan addess yang sama dengan yg null
update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


---------------------------------------------------------------------
--breaking out address into individual colums (address, city, state)
select PropertyAddress
from NashvilleHousing

select
SUBSTRING(propertyaddress, 1, CHARINDEX(',',propertyaddress) -1) as address,
SUBSTRING(propertyaddress, CHARINDEX(',',propertyaddress) + 1, Len(propertyaddress)) as address
--,CHARINDEX(',',propertyaddress)
from NashvilleHousing

alter table NashvilleHousing --tambah column pada table
add PropertySplitAddress nvarchar(255); 

Update NashvilleHousing
set PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',',propertyaddress) -1)

alter table NashvilleHousing --tambah column pada table
add PropertySplitCity nvarchar(255); 

Update NashvilleHousing
set PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',',propertyaddress) + 1, Len(propertyaddress))

select *
from NashvilleHousing




select owneraddress
from NashvilleHousing

--1808  FOX CHASE DR, GOODLETTSVILLE, TN

select
PARSENAME(Replace(ownerAddress,',','.'),3),
PARSENAME(Replace(ownerAddress,',','.'),2),
PARSENAME(Replace(ownerAddress,',','.'),1)
from NashvilleHousing


alter table NashvilleHousing --tambah column pada table
add OwnerSplitAddress nvarchar(255); 

Update NashvilleHousing
set OwnerSplitAddress = PARSENAME(Replace(ownerAddress,',','.'),3)

alter table NashvilleHousing --tambah column pada table
add OwnerSplitCity nvarchar(255); 

Update NashvilleHousing
set OwnerSplitCity = PARSENAME(Replace(ownerAddress,',','.'),2)

alter table NashvilleHousing --tambah column pada table
add OwnerSplitState nvarchar(255); 

Update NashvilleHousing
set OwnerSplitState = PARSENAME(Replace(ownerAddress,',','.'),1)

select *
from NashvilleHousing


---------------------------------------------------------------------
--change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
	case 
		when SoldAsVacant = 'Y' Then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
	end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case 
		when SoldAsVacant = 'Y' Then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
	end



---------------------------------------------------------------------
--Remove Duplicates

select *
from NashvilleHousing

with RowNumCTE as
(
select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				propertyAddress,
				saleprice,
				saleDate,
				legalreference
				order by
					uniqueid 
				) row_num
from NashvilleHousing
)

select *
from RowNumCTE
where row_num >1
order by propertyaddress

--delete
--from RowNumCTE
--where row_num >1




---------------------------------------------------------------------
--Delete Unused Columns

select *
from NashvilleHousing

alter table NashvilleHousing
drop column owneraddress, taxdistrict,propertyaddress

alter table NashvilleHousing
drop column saledate

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO



