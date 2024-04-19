SELECT *
  FROM [Nashville Housing Dataset].[dbo].[Nashvillehousing]

  -- STANDARDISE THE DATE FORMAT

  SELECT SaleDate, CONVERT(DATE,SaleDate)
  FROM [Nashville Housing Dataset].[dbo].[Nashvillehousing]

  ALTER TABLE [Nashville Housing Dataset].[dbo].[Nashvillehousing]
  ADD SALESDATECONVERTED DATE

  UPDATE [Nashville Housing Dataset].[dbo].[Nashvillehousing]
  SET SALESDATECONVERTED = CONVERT(DATE, SALEDATE)

  SELECT SALESDATECONVERTED
  FROM [Nashville Housing Dataset].[dbo].[Nashvillehousing]

  -- POPULATE PROPERTY ADDRESS

  SELECT PropertyAddress
  FROM [Nashville Housing Dataset].[dbo].[Nashvillehousing]
  WHERE PropertyAddress IS NULL

  SELECT A.PARCELID, A.PROPERTYADDRESS,  B.PARCELID, B.PROPERTYADDRESS, ISNULL(A.PROPERTYADDRESS, B.PROPERTYADDRESS)  -- ISNULL(IF THAT COLUMN IS NULL, REPLACE WITH VALUES OF THAT COLUMN TO MENTIONED COLUMN HERE)
  FROM [Nashville Housing Dataset].[dbo].[Nashvillehousing] A
  JOIN [Nashville Housing Dataset].[dbo].[Nashvillehousing] B
  ON A.PARCELID = B.PARCELID
  AND A.[UniqueID ]<>B.[UniqueID ]
  WHERE A.PropertyAddress IS NULL

  UPDATE A
  SET PROPERTYADDRESS = ISNULL(A.PROPERTYADDRESS, B.PROPERTYADDRESS)  
  FROM [Nashville Housing Dataset].[dbo].[Nashvillehousing] A
  JOIN [Nashville Housing Dataset].[dbo].[Nashvillehousing] B
  ON A.PARCELID = B.PARCELID
  AND A.[UniqueID ]<>B.[UniqueID ]
  WHERE A.PropertyAddress IS NULL

  -- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

  SELECT PropertyAddress
  FROM [Nashville Housing Dataset].[dbo].[Nashvillehousing]
  
  SELECT 
  SUBSTRING(PROPERTYADDRESS, 1, CHARINDEX(',', PROPERTYADDRESS)) AS ADDRESS
  FROM [Nashville Housing Dataset].[dbo].[Nashvillehousing]

  SELECT
  SUBSTRING(PROPERTYADDRESS, 1, CHARINDEX(',', PROPERTYADDRESS) -1 ) AS ADDRESS  -- USING, -1, WHERE THAT COMMA WILL BE REMOVED.
  FROM [Nashville Housing Dataset].[dbo].[Nashvillehousing]

  SELECT 
  SUBSTRING(PROPERTYADDRESS, CHARINDEX(',', PROPERTYADDRESS) +1, LEN(PROPERTYADDRESS)) AS  ADDRESS -- USING, +1, LEN(COLUMN), WHERE REMAINING TEXT WILL GO TO OTHER COLUMN
  FROM [Nashville Housing Dataset].[dbo].[Nashvillehousing]

  SELECT
  SUBSTRING(PROPERTYADDRESS, 1, CHARINDEX(',', PROPERTYADDRESS) -1) AS ADDRESS,
  SUBSTRING(PROPERTYADDRESS, CHARINDEX(',', PROPERTYADDRESS) +1, LEN(PROPERTYADDRESS)) AS ADDRESS
  FROM [Nashville Housing Dataset].[dbo].[Nashvillehousing]

  ALTER TABLE [Nashville Housing Dataset].[dbo].[Nashvillehousing]
  ADD PROPERTYSPLITADDRESS NVARCHAR(255)

  ALTER TABLE [Nashville Housing Dataset].[dbo].[Nashvillehousing]
  ADD PROPERTYSPLITCITY NVARCHAR(255)

  UPDATE [Nashville Housing Dataset].[dbo].[Nashvillehousing]
  SET PROPERTYSPLITADDRESS = SUBSTRING(PROPERTYADDRESS, 1, CHARINDEX(',', PROPERTYADDRESS) -1)

    UPDATE [Nashville Housing Dataset].[dbo].[Nashvillehousing]
  SET PROPERTYSPLITCITY = SUBSTRING(PROPERTYADDRESS, CHARINDEX(',', PROPERTYADDRESS) +1, LEN(PROPERTYADDRESS))

  SELECT *
  FROM [Nashville Housing Dataset].[dbo].[Nashvillehousing]

  -- OWNER ADDRESS SPLIT

  SELECT OwnerName
  FROM [Nashville Housing Dataset].[dbo].[Nashvillehousing]
  -- WE CAN USE PARSENAME, INSTEAD OF SUBSTRING AS WELL, WHERE IT WILL SEPARATE, IF VALUES CONSISTS OF '.'
  -- IF THAT VALUE HAS NO '.', WE CAN REPLACE WITH ','

  SELECT 
  PARSENAME(REPLACE(OWNERADDRESS,',','.'),3),
  PARSENAME(REPLACE(OWNERADDRESS,',','.'),2),
  PARSENAME(REPLACE(OWNERADDRESS,',','.'),1)
  FROM [Nashville Housing Dataset].[dbo].[Nashvillehousing]

  ALTER TABLE [Nashville Housing Dataset].[dbo].[Nashvillehousing]
  ADD OWNERSPLITADDRESS NVARCHAR(255)

  UPDATE [Nashville Housing Dataset].[dbo].[Nashvillehousing]
  SET OWNERSPLITADDRESS = PARSENAME(REPLACE(OWNERADDRESS, ',', '.'),3)

  ALTER TABLE [Nashville Housing Dataset].[dbo].[Nashvillehousing]
  ADD OWNERSPLITCITY NVARCHAR(255)

  UPDATE [Nashville Housing Dataset].[dbo].[Nashvillehousing]
  SET OWNERSPLITCITY = PARSENAME(REPLACE(OWNERADDRESS, ',', '.'), 2)

  ALTER TABLE [Nashville Housing Dataset].[dbo].[Nashvillehousing]
  ADD OWNERSPLITSTATE NVARCHAR(255)

  UPDATE [Nashville Housing Dataset].[dbo].[Nashvillehousing]
  SET OWNERSPLITSTATE = PARSENAME(REPLACE(OWNERADDRESS, ',', '.'), 1)

  SELECT * 
  FROM [Nashville Housing Dataset].[dbo].[Nashvillehousing]

  -- CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT"  FIELD

  SELECT DISTINCT(SOLDASVACANT), COUNT(SOLDASVACANT)
  FROM [Nashville Housing Dataset].[dbo].[Nashvillehousing]
  GROUP BY SOLDASVACANT
  ORDER BY 2

  SELECT SOLDASVACANT,
	CASE WHEN SOLDASVACANT = 'Y' THEN 'YES'
		 WHEN SOLDASVACANT = 'N' THEN 'NO'
		 ELSE SOLDASVACANT
	END
  FROM [Nashville Housing Dataset].[dbo].[Nashvillehousing]

  UPDATE [Nashville Housing Dataset].[dbo].[Nashvillehousing]
  SET SoldAsVacant = CASE WHEN SOLDASVACANT = 'Y' THEN 'YES'
		 WHEN SOLDASVACANT = 'N' THEN 'NO'
		 ELSE SOLDASVACANT
	END

SELECT DISTINCT(SOLDASVACANT)
FROM [Nashville Housing Dataset].[dbo].[Nashvillehousing]

-- REMOVE DUPLICATES

WITH ROWNUMCTE AS (
SELECT *,
ROW_NUMBER() OVER (PARTITION BY PARCELID, PROPERTYADDRESS, SALEPRICE, SALEDATE, LEGALREFERENCE ORDER BY UNIQUEID) ROW_NUM
FROM [Nashville Housing Dataset].[dbo].[Nashvillehousing]
--ORDER BY PARCELID
)

SELECT *
FROM ROWNUMCTE
WHERE ROW_NUM >1
-- WILL SHOW IF DUPLICATES THERE OR NOT.

WITH ROWNUMCTE AS (
SELECT *,
ROW_NUMBER() OVER (PARTITION BY PARCELID, PROPERTYADDRESS, SALEPRICE, SALEDATE, LEGALREFERENCE ORDER BY UNIQUEID) ROW_NUM
FROM [Nashville Housing Dataset].[dbo].[Nashvillehousing]
--ORDER BY PARCELID
)

DELETE 
FROM ROWNUMCTE
WHERE ROW_NUM >1
-- WILL DELETE THE DUPLICATES


-- DELETE UNUSED COLUMNS

SELECT *
FROM [Nashville Housing Dataset].[dbo].[Nashvillehousing]

ALTER TABLE [Nashville Housing Dataset].[dbo].[Nashvillehousing]
DROP COLUMN OWNERADDRESS, PROPERTYADDRESS