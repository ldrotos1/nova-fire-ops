-- Create the table schema --
CREATE SCHEMA nova_fire_ops
	AUTHORIZATION postgres;

-- Enable post GIS --
CREATE EXTENSION postgis;

-- Create the enums --
CREATE TYPE nova_fire_ops.department_type AS ENUM ('CAREER', 'CAREER/VOLUNTEER');

-- Create the address table --
CREATE TABLE nova_fire_ops.address
(
    address_id INTEGER,
    street     TEXT          NOT NULL,
    city       TEXT          NOT NULL,
    state      TEXT          NOT NULL,
    zip_code   TEXT          NOT NULL,
    latitude   NUMERIC(9, 6) NOT NULL,
    longitude  NUMERIC(9, 6) NOT NULL,
    PRIMARY KEY (address_id)
);

-- Create the departments table --
CREATE TABLE nova_fire_ops.departments
(
    dept_id                  INTEGER,
    department_name          TEXT          NOT NULL,
    department_short_name    TEXT          NOT NULL,
    department_abbreviation  TEXT          NOT NULL,
    PRIMARY KEY (dept_id)
);

-- Create the nova_department table --
CREATE TABLE nova_fire_ops.nova_department
(
    dept_id                  INTEGER       REFERENCES nova_fire_ops.departments (dept_id),
    address_id               INTEGER       NOT NULL REFERENCES nova_fire_ops.address (address_id),
    fire_chief               TEXT,
    career_uniformed_members INTEGER,
    civilian_admin_staff     INTEGER,
    volunteer_count          INTEGER,
    department_type          nova_fire_ops.department_type NOT NULL,
    department_border        geometry(MultiPolygon, 4326),
    PRIMARY KEY (dept_id)
);