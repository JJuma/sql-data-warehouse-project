/*
===============================================
Create Database and Schemas
===============================================
Script purpose:
  This script creates a new database named 'datawarehouse' after checking if it already exists.
  If the database exists, it is dropped and recreated. Additionally, the script sets up three 
  schemas within the database: 'bronze', 'silver' and 'gold'.
WARNING:
  Running this script will drop the entire 'datawarehouse' database if it exists.

*/

-- Connect to the default database (usually postgres)
\c postgres;

-- Drop the datawarehouse database if it exists
DO $$
BEGIN
   IF EXISTS (
      SELECT 1 FROM pg_database WHERE datname = 'datawarehouse'
   ) THEN
      RAISE NOTICE 'Dropping existing database: datawarehouse';
      PERFORM pg_terminate_backend(pid) 
      FROM pg_stat_activity 
      WHERE datname = 'datawarehouse'
        AND pid <> pg_backend_pid();  -- terminate other connections

      EXECUTE 'DROP DATABASE datawarehouse';
   END IF;
END
$$;

-- Create a new datawarehouse database
CREATE DATABASE datawarehouse
  WITH OWNER = CURRENT_USER
       ENCODING = 'UTF8'
       CONNECTION LIMIT = -1;

COMMENT ON DATABASE datawarehouse IS 'Data warehouse database for ETL layers: bronze, silver, gold';

-- Connect to the new database
\c datawarehouse;

-- Create bronze schema
CREATE SCHEMA bronze AUTHORIZATION CURRENT_USER;
COMMENT ON SCHEMA bronze IS 'Schema for raw ingested data (bronze layer)';

-- Create silver schema
CREATE SCHEMA silver AUTHORIZATION CURRENT_USER;
COMMENT ON SCHEMA silver IS 'Schema for cleaned and enriched data (silver layer)';

-- Create gold schema
CREATE SCHEMA gold AUTHORIZATION CURRENT_USER;
COMMENT ON SCHEMA gold IS 'Schema for curated data ready for analytics (gold layer)';
