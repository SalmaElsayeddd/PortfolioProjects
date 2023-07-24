/* 

Cleaning Data Using SQL Queries 

*/ 

SELECT * 
FROM PortfolioProjects..[dbo.NashvilleHousingData];

--Standardize Date Format  

ALTER TABLE [dbo.NashvilleHousingData]
ADD SaleDateConverted Date;

Update [dbo.NashvilleHousingData]
SET SaleDateConverted = CONVERT(Date,SaleDate)

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Populate the Property Address Data 

SELECT *
FROM [dbo.NashvilleHousingData]
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.propertyaddress) 
FROM [dbo.NashvilleHousingData] AS A
JOIN [dbo.NashvilleHousingData] AS B
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL 


UPDATE A
SET PropertyAddress = ISNULL(A.propertyaddress, b.propertyaddress) 
FROM [dbo.NashvilleHousingData] AS A
JOIN [dbo.NashvilleHousingData] AS B
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL 

---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Property Address into individual columns (Address, City, State) using SUBSTRING

SELECT PropertyAddress
FROM [dbo.NashvilleHousingData]
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
FROM [dbo.NashvilleHousingData]


ALTER TABLE [dbo.NashvilleHousingData]
ADD PropertySplitAddress NVARCHAR(255);


UPDATE [dbo.NashvilleHousingData]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE [dbo.NashvilleHousingData]
ADD PropertySplitCity NVARCHAR(255);


UPDATE [dbo.NashvilleHousingData]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Owner Address into individual columns (Address, City, State) using PARSNAME 

SELECT OwnerAddress
FROM [dbo.NashvilleHousingData]


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM [dbo.NashvilleHousingData]


ALTER TABLE [dbo.NashvilleHousingData]
ADD OwnerSplitAddress NVARCHAR(255);


UPDATE [dbo.NashvilleHousingData]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE [dbo.NashvilleHousingData]
ADD OwnerSplitCity NVARCHAR(255);


UPDATE [dbo.NashvilleHousingData]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE [dbo.NashvilleHousingData]
ADD OwnerSplitState NVARCHAR(255);


UPDATE [dbo.NashvilleHousingData]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


-------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)  
FROM [dbo.NashvilleHousingData]
GROUP BY SoldAsVacant
ORDER BY 1

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM [dbo.NashvilleHousingData]

UPDATE [dbo.NashvilleHousingData]
SET SoldAsVacant = 
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Remove duplicate data 

;WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                         PropertyAddress,
                         SalePrice,
                         SaleDate,
                         LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM [dbo.NashvilleHousingData]
)
SELECT * FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete unused columns 

SELECT *
FROM [dbo.NashvilleHousingData]

ALTER TABLE [dbo.NashvilleHousingData]
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDate 