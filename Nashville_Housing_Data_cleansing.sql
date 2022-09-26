#Standartize Date Format by removing hours and changing the type from DATETIME to DATE 

Alter Table data_cleaning.nashville_housing_data
Modify column SaleDate Date

#Eliminating null values - populating Property Address data. 
#Updating the table to make empty data in Property Address to become NULL data
 
UPDATE data_cleaning.nashville_housing_data
SET PropertyAddress = NULLIF(PropertyAddress,"");

#Explanation - there are null date for PropertyAddress column which can be populated by ParcelID, as same Parcel IDs have same Property Adresses.

update data_cleaning.nashville_housing_data temp1, data_cleaning.nashville_housing_data temp2
SET temp1.PropertyAddress = temp2.PropertyAddress
where temp1.propertyAddress is null and temp1.ParcelID = temp2.ParcelID

Select Table1.ParcelID,Table2.PropertyAddress,Table1.PropertyAddress = IFNULL(Table2.PropertyAddress,Table1.PropertyAddress)
From data_cleaning.nashville_housing_data as Table1
Join data_cleaning.nashville_housing_data as Table2
	on Table1.ParcelID =Table2.ParcelID
    and Table1.UniqueID <> Table2.UniqueID
    Where Table1.PropertyAddress is Null

