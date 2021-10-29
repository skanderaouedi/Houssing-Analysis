--cleaning missing data 
--analyse somedata ana d populate property address data
select a.PropertyAddress ,a.ParcelID ,b.PropertyAddress ,b.ParcelID,
isnull(a.propertyaddress,b.PropertyAddress)
from portfolioproject..villehoussing as a
join portfolioproject..villehoussing  as b 
on a.ParcelID=b.ParcelID  and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a set propertyaddress=isnull(a.propertyaddress,b.PropertyAddress)
from portfolioproject..villehoussing as a
join portfolioproject..villehoussing  as b 
on a.ParcelID=b.ParcelID  and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null
--test:
select * from PortfolioProject..villehoussing where PropertyAddress is null
--breaking out address into individual columns(address ,city,state)
select PropertyAddress
from PortfolioProject..villehoussing
--create new column for the property address
  alter table portfolioproject..villehoussing
 add propertysplitaddress nvarchar(255);

--create new column for the property city 
alter table portfolioproject..villehoussing
 add propertycity nvarchar(255);
 --test  to see what the split look like
select SUBSTRING(propertyaddress,1,CHARINDEX(',',PropertyAddress)-1) as adress,
SUBSTRING(propertyaddress,CHARINDEX(',',PropertyAddress)+1,len(propertyaddress) )as city
from PortfolioProject..villehoussing
 --add the  property adress to the property address slited 
 update PortfolioProject..villehoussing set propertysplitaddress=
SUBSTRING(propertyaddress,1,CHARINDEX(',',PropertyAddress)-1) 
--add the  property city to the property city slited 
update PortfolioProject..villehoussing set propertycity=
SUBSTRING(propertyaddress,CHARINDEX(',',PropertyAddress)+1,len(propertyaddress)) 
--test
select * from PortfolioProject..villehoussing
--delete the old property address 
alter table portfolioproject..villehoussing
drop column propertyaddress
--test
select* from portfolioproject..villehoussing
--split the owner address
--first let's test
select  PARSENAME(replace(owneraddress,',','.'),3),PARSENAME(replace(owneraddress,',','.'),2),
PARSENAME(replace(owneraddress,',','.'),1)
from portfolioproject..villehoussing
--create new column for the owner address
  alter table portfolioproject..villehoussing
 add ownersplitaddress nvarchar(255);
--create new column for the owner city 
alter table portfolioproject..villehoussing
 add ownercity nvarchar(255);
 --create new column for the owner state
alter table portfolioproject..villehoussing
 add ownerstate nvarchar(255);
 --add the owner adress to the owner address slited 
 update PortfolioProject..villehoussing set ownersplitaddress=
PARSENAME(replace(owneraddress,',','.'),3)
--add the  owner city to the owner city slited 
update PortfolioProject..villehoussing set ownercity=
PARSENAME(replace(owneraddress,',','.'),2)
--add the  owner state to the owner state slited 
update PortfolioProject..villehoussing set ownerstate=
PARSENAME(replace(owneraddress,',','.'),1) 
--test 
select * from PortfolioProject..villehoussing

--change Y and N to yes and NO  "sold as vacant" field
select distinct  (SoldAsVacant),count(soldasvacant)
from PortfolioProject..villehoussing
group by SoldAsVacant
order by 2
select SoldAsVacant ,
case when soldasvacant ='Y' THEN 'yes'
when soldasvacant ='N' then 'NO'
else SoldAsVacant end

from PortfolioProject..villehoussing
order by SoldAsVacant
update PortfolioProject..villehoussing set SoldAsVacant=case when soldasvacant ='Y' THEN 'yes'
when soldasvacant ='N' then 'NO'
else SoldAsVacant end
--test 
select * from PortfolioProject..villehoussing
select distinct soldasvacant , count (soldasvacant )from PortfolioProject..villehoussing
group by SoldAsVacant

--Remove duplicates by cte
with rownumcte as (
select *,
ROW_NUMBER()over (
partition by  parcelid , propertysplitaddress,saleprice,legalreference,
saledate order by uniqueid)row_num
from PortfolioProject..villehoussing --order by ParcelID desc
)
select* from rownumcte 
select* from PortfolioProject..villehoussing