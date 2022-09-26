--Standartize Date Format by removing hours and changing the type from DATETIME to DATE 

Alter Table data_cleaning.backuptable
Modify column SaleDate Date

--Eliminating null values - populating Property Address data. 
--Updating the table to make empty data in Property Address to become NULL data

UPDATE data_cleaning.backuptable
SET PropertyAddress = NULLIF(PropertyAddress,"")

--Explanation - there are null date for PropertyAddress column which can be populated by ParcelID, as same Parcel IDs have same Property Adresses.
--script to check the theory in action 

select a.ParcelID, a.PropertyAddress as withNullAddress, b.PropertyAddress as withoutNullAddress
from data_cleaning.backuptable as a
join data_cleaning.backuptable as b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is Null

--updating the table, filling of null values in PropertyAddress column

Update data_cleaning.backuptable
inner join data_cleaning.backuptable as jointable on jointable.ParcelID =backuptable.ParcelID and jointable.UniqueID <> backuptable.UniqueID
Set backuptable.PropertyAddress = if(backuptable.PropertyAddress is null, jointable.PropertyAddress, backuptable.PropertyAddress)
where backuptable.PropertyAddress is null 

--Breaking out Address column data into seperate columns as ADDRESS, CITY, STATE
--Explanation - as per values in PropertyAddress address are seperated by "," we will seperate it into 2 section 1.before comma and 2.after comma 
--Explanation - as per values in OwnerAddress address city and states are seperated by "," we will seperate into 3 : 1. before 1 comma 2. in between 2 commas and 3.after last comma 
select
	PropertyAddress,
	SUBSTRING_index(PropertyAddress, "," ,1 ) as PropertyAddress,
    SUBSTRING_index(PropertyAddress, "," ,-1 ) as PropertyCity
From data_cleaning.backuptable

--Updating Table with new Columns PropertySplitAddress and PropertySplitCity

Alter Table backuptable 
ADD PropertySplitAddress Nvarchar(255)

update backuptable
set PropertySplitAddress = SUBSTRING_index(PropertyAddress, "," ,1 )

Alter Table backuptable 
ADD PropertySplitCity Nvarchar(255)

-checking the new columns 

select PropertyAddress, PropertySplitAddress, PropertySplitCity
from data_cleaning.backuptable

#seperating OwnerAdress

select
	OwnerAddress,
	SUBSTRING_index(OwnerAddress, "," ,1 ) as OwnerSplitAddress,
    SUBSTRING_INDEX(SUBSTRING_index(OwnerAddress, "," ,2 ),",",-1) as OwnerSplitCity,
    SUBSTRING_index(OwnerAddress, "," ,-1 ) as OwnerSplitState
From data_cleaning.backuptable

#Add new columns 

Alter table data_cleaning.backuptable
ADD	OwnerSplitAddress Nvarchar(255)

UPDATE backuptable 
Set OwnerSplitAddress = SUBSTRING_index(OwnerAddress, "," ,1 )

Alter table data_cleaning.backuptable
ADD	OwnerSplitCity Nvarchar(255)

UPDATE backuptable 
Set OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_index(OwnerAddress, "," ,2 ),",",-1)

Alter table data_cleaning.backuptable
ADD	OwnerSplitState Nvarchar(255)

UPDATE backuptable 
Set OwnerSplitState = SUBSTRING_index(OwnerAddress, "," ,-1 )

#checking results 

select OwnerAddress,OwnerSplitAddress,OwnerSplitCity, OwnerSplitState
from data_cleaning.backuptable

#changing Y and N to Yes and NO in SoldAsVacant
#first checking which values SoldAsVacant is consisted of and how many raws each value have

select distinct(SoldAsVacant),count(SoldAsVacant)
from data_cleaning.backuptable 
group by SoldAsVacant
order by count(SoldAsVacant)

#using case statement changing Y to YES and N to NO

select SoldAsVacant,
CASE SoldAsVacant
	when "Y" then "YES"
    when "N" then "NO"
    Else SoldAsVacant
    End as SoldAsVacantNew
From data_cleaning.backuptable

#updating SoldAsVacant column 

update backuptable
set SoldAsVacant = CASE SoldAsVacant
	when "Y" then "YES"
    when "N" then "NO"
    Else SoldAsVacant
    End;    
    
#checking updated Column   
 
select distinct(SoldAsVacant),count(SoldAsVacant)
from data_cleaning.backuptable 
group by SoldAsVacant
order by count(SoldAsVacant)

#remoting dublicates from table (not recommended if there is a unique data, valuable data can be deleted, 
#just for analysis purposes we can neglect unique data - UniqueID and see other dublicates)

with Dublicate_table as (
select *,
	row_number() over (
    Partition by ParcelID,
				PropertyAddress,
                SaleDate,
                LegalReference
                order by UniqueID
					) row_num 
from data_cleaning.backuptable
order by ParcelID
 )               

select * 
from dublicate_table 
where row_num > 1				

# 104 raws based on given criterias are dublicates (expect UniqueID) need to be deleted. 
# As in table with created with "with" statement it saved as new CSV file (dublicate_deleting.csv) for further actions in it  

with Dublicate_table as (
select *,
	row_number() over (
    Partition by ParcelID,
				PropertyAddress,
                SaleDate,
                LegalReference
                order by UniqueID
					) row_num 
from data_cleaning.backuptable
order by ParcelID
 )               
 
 
Delete 
from data_cleaning.dublicate_deleting 
where row_numbers > 1

#104 dublicated raws has been deleted. 	
 

#Export cleaned CSV file for further use

Select * 
from data_cleaning.dublicate_deleting 

