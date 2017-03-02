ALTER USER postgres WITH PASSWORD 'P@ssw0rd1';
CREATE DATABASE project1;
CREATE USER project1 WITH PASSWORD 'P@ssw0rd1';
ALTER ROLE project1 SET client_encoding TO 'utf8';
ALTER ROLE project1 SET default_transaction_isolation TO 'read committed';
ALTER ROLE project1 SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE project1 TO project1;
