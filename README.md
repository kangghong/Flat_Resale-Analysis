### Flat Resale Analysis with SQL(postgreSQL)

#### Frameworks:
  - pgadmin4
  - postgresql

#### Data Cleaning
- Imported flat resale information in Singapore in CSV format into PostgreSQL Database
- standardized format of data for columns, break up data into different functional columns
- replaced short forms values
- utilized CTEs and partitions to remove duplicates
- created new columns with useful data derived from imported data
- created concise table to store new cleaned data

#### Exploratory Data Analysis
- resale prices throughout the years
- general trend of resale prices throughout the years for different flat_models
- identify most prominent flat_type and flat_models of resale units
- identify town with highest resale units and price
- relationship between resale prices and floor area, remaining lease, storeys, block number, flat_type, flat_model
- average resale prices in different towns
- percentage change of resale prices throughout the years, in different towns
