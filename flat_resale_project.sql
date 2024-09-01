SELECT * 
FROM public."flat_resale_project"

ALTER TABLE public."flat_resale_project"
DROP COLUMN month_of_resale, 
DROP COLUMN year_of_resale,
DROP COLUMN years_of_lease_left,
DROP COLUMN year_group_of_lease_left

---------------------
-- Data Cleaning

-- standardize date format

SELECT month, substring(month, 1, 4) as year_of_resale, substring(month, 6, 2) as month_of_resale
FROM public."flat_resale_project"

ALTER TABLE public."flat_resale_project"
ADD year_of_resale integer,
ADD month_of_resale integer

UPDATE public."flat_resale_project"
SET year_of_resale = CAST(SUBSTRING(month, 1, 4) as int)

UPDATE public."flat_resale_project"
SET month_of_resale = CAST(SUBSTRING(month, 6, 2) as int)

SELECT remaining_lease, SUBSTRING(remaining_lease, 1, 2) as remaining_years_of_lease
FROM public."flat_resale_project"

AlTER TABLE public."flat_resale_project"
ADD remaining_years_of_lease integer

UPDATE public."flat_resale_project"
SET remaining_years_of_lease = CAST(SUBSTRING(remaining_lease, 1, 2) as int)

AlTER TABLE public."flat_resale_project"
DROP COLUMN yeargroup_of_lease

SELECT remaining_years_of_lease, 
CASE
	WHEN remaining_years_of_lease > 0 and remaining_years_of_lease <= 9 THEN '0 to 10 years left'
	WHEN remaining_years_of_lease > 10 and remaining_years_of_lease <= 20 THEN '10 to 20 years left'
	WHEN remaining_years_of_lease > 20 and remaining_years_of_lease <= 30 THEN '20 to 30 years left'
	WHEN remaining_years_of_lease > 30 and remaining_years_of_lease <= 40 THEN '30 to 40 years left'
	WHEN remaining_years_of_lease > 40 and remaining_years_of_lease <= 50 THEN '40 to 50 years left'
	WHEN remaining_years_of_lease > 50 and remaining_years_of_lease <= 60 THEN '50 to 60 years left'
	WHEN remaining_years_of_lease > 60 and remaining_years_of_lease <= 70 THEN '60 to 70 years left'
	WHEN remaining_years_of_lease > 70 and remaining_years_of_lease <= 80 THEN '70 to 80 years left'
	WHEN remaining_years_of_lease > 80 and remaining_years_of_lease <= 90 THEN '80 to 90 years left'
	WHEN remaining_years_of_lease > 90 and remaining_years_of_lease <= 99 THEN '90 to 99 years left'
END as yeargroup_of_lease
FROM public."flat_resale_project"

AlTER TABLE public."flat_resale_project"
ADD yeargroup_of_lease varchar(255)

UPDATE public."flat_resale_project"
SET yeargroup_of_lease = CASE
	WHEN remaining_years_of_lease > 0 and remaining_years_of_lease <= 9 THEN '0 to 10 years left'
	WHEN remaining_years_of_lease > 10 and remaining_years_of_lease <= 20 THEN '10 to 20 years left'
	WHEN remaining_years_of_lease > 20 and remaining_years_of_lease <= 30 THEN '20 to 30 years left'
	WHEN remaining_years_of_lease > 30 and remaining_years_of_lease <= 40 THEN '30 to 40 years left'
	WHEN remaining_years_of_lease > 40 and remaining_years_of_lease <= 50 THEN '40 to 50 years left'
	WHEN remaining_years_of_lease > 50 and remaining_years_of_lease <= 60 THEN '50 to 60 years left'
	WHEN remaining_years_of_lease > 60 and remaining_years_of_lease <= 70 THEN '60 to 70 years left'
	WHEN remaining_years_of_lease > 70 and remaining_years_of_lease <= 80 THEN '70 to 80 years left'
	WHEN remaining_years_of_lease > 80 and remaining_years_of_lease <= 90 THEN '80 to 90 years left'
	WHEN remaining_years_of_lease > 90 and remaining_years_of_lease <= 99 THEN '90 to 99 years left'
END

-- populate missing data

-- checking for null values in important columns
SELECT *
FROM public."flat_resale_project"
WHERE block IS NULL 
OR resale_price IS NULL
OR town IS NULL 
OR flat_type IS NULL
OR storey_range IS NULL
OR flat_model IS NULL
OR year_of_resale IS NULL
OR month_of_resale IS NULL
OR remaining_lease IS NULL

-- replace short forms

SELECT DISTINCT(flat_model)
FROM public."flat_resale_project"
-- by generation in which the flat was made

SELECT flat_model, REPLACE(flat_model, '3Gen', '3-Generation') as name
FROM public."flat_resale_project"
WHERE flat_model = '3Gen'

UPDATE public."flat_resale_project"
SET flat_model = REPLACE(flat_model, '3Gen', '3-Generation')

SELECT flat_model, REPLACE(flat_model, 'DBSS', 'Design, Build and Sell Scheme')
FROM public."flat_resale_project"
WHERE flat_model = 'DBSS'

UPDATE public."flat_resale_project"
SET flat_model = REPLACE(flat_model, 'DBSS', 'Design, Build and Sell Scheme')

SELECT *
FROM public."flat_resale_project"
WHERE flat_model = 'Type S1' or flat_model = 'Type S2'


SELECT DISTINCT(flat_type)
FROM public."flat_resale_project"
-- room size

SELECT DISTINCT(flat_model)
FROM public."flat_resale_project"
--WHERE flat_model = '2-room'
-- Classification of units by generation of which the flat was made

-- remove duplicates
WITH cte1 as (
	SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY 
		month, 
		flat_type, 
		block, 
		street_name, 
		storey_range, 
		flat_model, 
		resale_price, 
		remaining_lease
		) as row_num
	FROM public."flat_resale_project"
)
SELECT * 
FROM cte1
WHERE row_num = 1

create table concise_flat_resale as
  select * from public."flat_resale_project"
with no data

ALTER TABLE public."concise_flat_resale"
ADD row_num bigint

WITH cte1 as (
	SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY 
		month, 
		flat_type, 
		block, 
		street_name, 
		storey_range, 
		flat_model, 
		resale_price, 
		remaining_lease
		) as row_num
	FROM public."flat_resale_project"
)
INSERT INTO public."concise_flat_resale"(
	SELECT *
	FROM cte1
	WHERE row_num = 1
)

SELECT *
FROM public."concise_flat_resale"

-- delete unused columns

ALTER TABLE public."concise_flat_resale"
DROP COLUMN month

ALTER TABLE public."concise_flat_resale"
DROP COLUMN row_num

SELECT area_sqm, (resale_price/area_sqm) as price_per_sqm
FROM public."concise_flat_resale"

ALTER TABLE public."concise_flat_resale"
ADD price_per_sqm real

UPDATE public."concise_flat_resale"
SET price_per_sqm = (resale_price/area_sqm)

SELECT price_per_sqm, ROUND(CAST(price_per_sqm as numeric), 2)
FROM public."concise_flat_resale"

UPDATE public."concise_flat_resale"
SET price_per_sqm = ROUND(CAST(price_per_sqm as numeric), 2)

ALTER TABLE public."concise_flat_resale"
RENAME COLUMN resale_price TO resale_price_thousands

SELECT resale_price_thousands, resale_price_thousands/1000
FROM public."concise_flat_resale"

UPDATE public."concise_flat_resale"
SET resale_price_thousands = resale_price_thousands/1000

---------------------
-- Data Visualization
SELECT *
FROM public."concise_flat_resale"

-- general trend of resale prices throughout the years
SELECT year_of_resale, AVG(resale_price_thousands) average_resale_prices
FROM public."concise_flat_resale"
GROUP BY year_of_resale

-- general trend of resale prices throughout the years for different flat_models
SELECT year_of_resale, flat_model, AVG(resale_price_thousands) average_resale_price_for_model
FROM public."concise_flat_resale"
GROUP BY year_of_resale, flat_model
ORDER BY flat_model, year_of_resale

-- identify most prominent type of resale units
SELECT flat_type, COUNT(flat_type) as Quantity
FROM public."concise_flat_resale"
GROUP BY flat_type
--4-room resale units

SELECT flat_model, COUNT(flat_model) Quantity
FROM public."concise_flat_resale"
GROUP BY flat_model
ORDER BY Quantity DESC
-- Model A and Improved Units

-- most prominent resale town
SELECT town, COUNT(town) Quantity
FROM public."concise_flat_resale"
GROUP BY town
ORDER BY Quantity DESC
-- Sengkang, Punggol, Woodlands, Yishun, Tampines, Jurong West

-- resale prices vs floor area
SELECT area_sqm, ROUND(CAST(AVG(resale_price_thousands) as numeric),2) mean_resale_price_thousands
FROM public."concise_flat_resale"
GROUP BY area_sqm

-- for resale prices vs floor area in 4 ROOM flats
SELECT area_sqm, ROUND(CAST(AVG(resale_price_thousands) as numeric),2) mean_resale_price_thousands
FROM public."concise_flat_resale"
WHERE flat_type = '4 ROOM'
GROUP BY flat_type, area_sqm
ORDER BY area_sqm

-- remaining lease vs floor area
SELECT yeargroup_of_lease, AVG(area_sqm) mean_area_sqm
FROM public."concise_flat_resale"
GROUP BY yeargroup_of_lease
ORDER BY mean_area_sqm DESC

-- for prominent 4 ROOM resale units
SELECT yeargroup_of_lease, AVG(area_sqm) mean_area_sqm
FROM public."concise_flat_resale"
WHERE flat_type = '4 ROOM'
GROUP BY yeargroup_of_lease
ORDER BY mean_area_sqm DESC

-- median prices for flats in different towns
SELECT town, AVG(resale_price_thousands) mean_resale_price
FROM public."concise_flat_resale"
GROUP BY town
ORDER BY mean_resale_price DESC

-- storey vs price
SELECT storey_range, AVG(resale_price_thousands) mean_resale_price
FROM public."concise_flat_resale"
GROUP BY storey_range
ORDER BY mean_resale_price DESC

-- for 4 ROOMs 
SELECT storey_range, AVG(resale_price_thousands) mean_resale_price
FROM public."concise_flat_resale"
WHERE flat_type = '4 ROOM'
GROUP BY storey_range
ORDER BY mean_resale_price DESC

-- block number vs resale price
SELECT block, AVG(resale_price_thousands) mean_resale_price
FROM public."concise_flat_resale"
GROUP BY block
ORDER BY mean_resale_price DESC

-- flat type vs resale price
SELECT flat_type, AVG(resale_price_thousands) mean_resale_price
FROM public."concise_flat_resale"
GROUP BY flat_type
ORDER BY mean_resale_price DESC

-- prominent 4 ROOM flats prices over time
SELECT year_of_resale, AVG(resale_price_thousands) mean_resale_price
FROM public."concise_flat_resale"
WHERE flat_type = '4 ROOM'
GROUP BY year_of_resale
ORDER BY year_of_resale ASC

-- flat_model vs resale_price
SELECT flat_model, AVG(resale_price_thousands) mean_resale_price
FROM public."concise_flat_resale"
GROUP BY flat_model
ORDER BY mean_resale_price DESC

-- prominent model A flats
SELECT year_of_resale, AVG(resale_price_thousands) mean_resale_price
FROM public."concise_flat_resale"
WHERE flat_type = '4 ROOM'
GROUP BY year_of_resale
ORDER BY year_of_resale ASC

-- lease year vs resale price
SELECT yeargroup_of_lease, AVG(resale_price_thousands) mean_resale_price
FROM public."concise_flat_resale"
GROUP BY yeargroup_of_lease

-- percentage change in resale prices
SELECT year_of_resale, AVG(resale_price_thousands) price_changes
FROM public."concise_flat_resale"
GROUP BY year_of_resale

-- percentage change of resale price from 2017 - 2024
WITH cte AS(
	SELECT a.year_of_resale, ROUND(
	CAST(100*(AVG(a.resale_price_thousands)/(
		SELECT AVG(b.resale_price_thousands)
		FROM public."concise_flat_resale" b
		WHERE b.year_of_resale = a.year_of_resale -1
	) -1)as numeric), 2) change
	FROM public."concise_flat_resale" a
	GROUP BY a.year_of_resale
	ORDER BY a.year_of_resale ASC
) 
SELECT year_of_resale, COALESCE(change, 0) AS percentage_change
FROM cte

-- percentage change of resale price for different towns
WITH cte2 AS(
	SELECT a.town, a.year_of_resale, ROUND(
	CAST(100*(AVG(a.resale_price_thousands)/(
		SELECT AVG(b.resale_price_thousands)
		FROM public."concise_flat_resale" b
		WHERE a.town=b.town 
		AND b.year_of_resale = a.year_of_resale -1
	) -1)as numeric), 2) change
	FROM public."concise_flat_resale" a
	GROUP BY a.town, a.year_of_resale
	ORDER BY a.town ASC, a.year_of_resale ASC
) 
SELECT town, year_of_resale, COALESCE(change, 0) AS percentage_change
FROM cte2

-- Sengkang, Punggol, Woodlands, Yishun, Tampines, Jurong West
WITH cte3 AS(
	SELECT a.town, a.year_of_resale, ROUND(
	CAST(100*(AVG(a.resale_price_thousands)/(
		SELECT AVG(b.resale_price_thousands)
		FROM public."concise_flat_resale" b
		WHERE a.town=b.town 
		AND b.year_of_resale = a.year_of_resale -1
	) -1)as numeric), 2) change
	FROM public."concise_flat_resale" a
	GROUP BY a.town, a.year_of_resale
	ORDER BY a.town ASC, a.year_of_resale ASC
) 
SELECT town, year_of_resale, COALESCE(change, 0) AS percentage_change
FROM cte3
WHERE town = 'SENGKANG' 
OR town = 'PUNGGOL'
OR town = 'WOODLANDS'
OR town = 'YISHUN'
OR town = 'TAMPINES'
OR town = 'JURONG WEST'
-- resale prices all increased by large magnitude between 2020-2021

-- clementi
WITH cte4 AS(
	SELECT a.town, a.year_of_resale, ROUND(
	CAST(100*(AVG(a.resale_price_thousands)/(
		SELECT AVG(b.resale_price_thousands)
		FROM public."concise_flat_resale" b
		WHERE a.town=b.town 
		AND b.year_of_resale = a.year_of_resale -1
	) -1)as numeric), 2) change
	FROM public."concise_flat_resale" a
	GROUP BY a.town, a.year_of_resale
	ORDER BY a.town ASC, a.year_of_resale ASC
) 
SELECT town, year_of_resale, COALESCE(change, 0) AS percentage_change
FROM cte4
WHERE town = 'CLEMENTI'
