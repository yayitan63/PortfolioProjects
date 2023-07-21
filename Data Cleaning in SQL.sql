/*
Cleaning Data in SQL Queries
*/

select *
from NashvilleHousing

----------------------------------------------------------------------

--Standaedize Data Format
select SaleDateConverted, convert(Date,Saledate)
from NashvilleHousing

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = convert(Date, Saledate)

select * 
from NashvilleHousing


--Populate Property Address data 
select PropertyAddress
from NashvilleHousing

select n1.ParcelID, n1.PropertyAddress, n2.ParcelID, n2.PropertyAddress, ISNULL(n1.PropertyAddress, n2.PropertyAddress)
from NashvilleHousing n1
join NashvilleHousing n2
on n1.ParcelID = n2.ParcelID
and n1.[UniqueID ] <> n2.[UniqueID ]
where n1.PropertyAddress is null 

update n1 -- when we use join in an update, we can't use the actual table name, we have to use it's alias 
set PropertyAddress = ISNULL(n1.PropertyAddress, n2.PropertyAddress)
from NashvilleHousing n1
join NashvilleHousing n2
on n1.ParcelID = n2.ParcelID
and n1.[UniqueID ] <> n2.[UniqueID ]
where n1.PropertyAddress is null 


--Breaking out Address into individual columns (Address, city, state)
select PropertyAddress
from NashvilleHousing
/*
select substring(PropertyAddress, 1, charindex(',',PropertyAddress)) 
-- we get everything from the frist value until the comma, we don't want the comma so we -1 
from NashvilleHousing
*/

select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
from NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) 


select *
from NashvilleHousing

select OwnerAddress
from NashvilleHousing

select PARSENAME(OwnerAddress,1) --parsename only can be used for period so we'll have to replace , to .
from NashvilleHousing

--Parsename works backwards so instead of 123, 321
--select PARSENAME(REPLACE(OwnerAddress, ',','.'), 1),
--PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
--PARSENAME(REPLACE(OwnerAddress, ',','.'),3)
--from NashvilleHousing

select PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
from NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255)

update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255)

update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)


select *
from NashvilleHousing


--Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
	     when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		        when SoldAsVacant = 'N' then 'No'
		        else SoldAsVacant
		    end

select *
from NashvilleHousing
---------------------------------------------------------------------------------

--Remove Duplicates
select *
from NashvilleHousing


with RowNumberCTE AS(
select *, ROW_NUMBER() over (
		  partition by 
		  ParcelID, 
		  PropertyAddress, 
		  SalePrice, 
		  SaleDate, 
		  LegalReference
		  order by UniqueID ) as Row_Num
from NashvilleHousing
)

--select * 
--from RowNumberCTE
--where Row_Num > 1

delete 
from RowNumberCTE
where Row_Num > 1

---------------------------------------------------------------------------------

--Delete Unused Columns
select *
from NashvilleHousing

alter table NashvilleHousing
drop column SaleDate, PropertyAddress ,OwnerAddress, TaxDistrict

