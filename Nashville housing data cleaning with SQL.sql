--creating table nashville_housing and importing data from a csv file--
CREATE TABLE nashville_housing
(
UniqueID NUMERIC,
ParcelID VARCHAR,
LandUse	VARCHAR,
PropertyAddress	VARCHAR,
SaleDate DATE,
SalePrice NUMERIC,
LegalReference VARCHAR,
SoldAsVacant VARCHAR,
OwnerName VARCHAR,
OwnerAddress VARCHAR,
Acreage NUMERIC,
TaxDistrict VARCHAR,
LandValue NUMERIC,
BuildingValue NUMERIC,
TotalValue NUMERIC,
YearBuilt NUMERIC,
Bedrooms NUMERIC,
FullBath NUMERIC,
HalfBath NUMERIC
);

SELECT *
FROM nashville_housing;

/*
cleaning data in sql
*/

--checking the address data--

SELECT PropertyAddress
FROM nashville_housing;

--checking the records with missing property address-

SELECT *
FROM nashville_housing
WHERE PropertyAddress IS NULL
;
--populating property address data--

SELECT *
FROM nashville_housing
ORDER BY parcelid
;


SELECT a_.parcelid, a_.propertyaddress, b.parcelid, b.propertyaddress, 
CASE 
	WHEN a_.propertyaddress IS NULL THEN b.propertyaddress
	END 
FROM nashville_housing a_
JOIN nashville_housing b
	ON a_.parcelid = b.parcelid
	AND a_.uniqueid <> b.uniqueid
	WHERE a_.propertyaddress IS NULL;

UPDATE  nashville_housing AS a_
SET propertyaddress = COALESCE(b.propertyaddress,a_.propertyaddress)
FROM nashville_housing b
	WHERE a_.parcelid = b.parcelid
	AND a_.uniqueid <> b.uniqueid
	AND a_.propertyaddress IS NULL
;

--checking to be sure the null property addresses have been populated--

SELECT * 
FROM nashville_housing
WHERE propertyaddress IS NULL;

--splitting propertyaddress into individual columns(address, city, state)--

SELECT propertyaddress
FROM nashville_housing;

SELECT
SUBSTRING(propertyaddress, 1, STRPOS(propertyaddress, ',' )-1) AS address,
SUBSTRING(propertyaddress, STRPOS(propertyaddress, ',' )+1) AS address
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD propertysplitaddress VARCHAR;

UPDATE  nashville_housing AS a_
SET propertysplitaddress  = SUBSTRING(propertyaddress, 1, STRPOS(propertyaddress, ',' )-1);


ALTER TABLE nashville_housing
ADD propertysplitcity VARCHAR;


UPDATE  nashville_housing AS a_
SET propertysplitcity  = SUBSTRING(propertyaddress, STRPOS(propertyaddress, ',' )+1);

SELECT owneraddress
FROM nahville_housing

--trying a different method to split the owneraddress--

SELECT
SPLIT_PART(owneraddress,',', 1),
SPLIT_PART(owneraddress,',', 2),
SPLIT_PART(owneraddress,',', 3)
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD ownersplitaddress VARCHAR;

UPDATE nashville_housing
SET ownersplitaddress = SPLIT_PART(owneraddress,',', 1);

ALTER TABLE nashville_housing
ADD ownersplitcity VARCHAR;

UPDATE nashville_housing
SET ownersplitcity = SPLIT_PART(owneraddress,',', 2);

ALTER TABLE nashville_housing
ADD ownersplitstate VARCHAR;

UPDATE nashville_housing
SET ownersplitstate = SPLIT_PART(owneraddress,',', 3);

--change Y and N to YES and No in soldasvacant field--

SELECT DISTINCT (soldasvacant), COUNT(soldasvacant)
FROM nashville_housing
GROUP BY 1
ORDER BY 2;

SELECT soldasvacant
, CASE WHEN soldasvacant = 'Y' THEN 'Yes'
			WHEN soldasvacant = 'N' THEN 'No'
			ELSE soldasvacant
			END
FROM nashville_housing;

UPDATE nashville_housing
SET soldasvacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes'
			WHEN soldasvacant = 'N' THEN 'No'
			ELSE soldasvacant
			END;
			
			
--removing duplicates--

	WITH rownumcte AS (		
SELECT ctid,
	ROW_NUMBER() OVER (
	PARTITION BY parcelid, propertyaddress, saleprice, saledate, legalreference
		ORDER BY uniqueid
	) row_num
	FROM nashville_housing
)

DELETE
FROM nashville_housing
USING rownumcte
	WHERE rownumcte.row_num > 1
	AND rownumcte.ctid = nashville_housing.ctid;
ORDER BY propertyaddress;

--checking to be sure our duplicates have been deleted---

WITH rownumcte AS (		
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY parcelid, propertyaddress, saleprice, saledate, legalreference
		ORDER BY uniqueid
	) row_num
	FROM nashville_housing
)

DELETE
FROM rownumcte
	WHERE row_num > 1 ;
	
--deleting unused columns--

ALTER TABLE nashville_housing
DROP COLUMN owneraddress,
DROP COLUMN taxdistrict, 
DROP COLUMN propertyaddress;


