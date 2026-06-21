-- Create the table schema --
CREATE SCHEMA nova_fire_ops
	AUTHORIZATION postgres;

-- Enable post GIS --
CREATE EXTENSION postgis;

-- Create the enums --
CREATE TYPE nova_fire_ops.department_type AS ENUM ('CAREER', 'CAREER/VOLUNTEER');

-- Create the departments table --
CREATE TABLE nova_fire_ops.departments
(
    dept_id                  INTEGER,
    department_name          TEXT          NOT NULL,
    headquarters_address     TEXT          NOT NULL,
    fire_chief               TEXT,
    career_uniformed_members INTEGER,
    civilian_admin_staff     INTEGER,
    volunteer_count          INTEGER,
    department_type          nova_fire_ops.department_type NOT NULL,
    latitude                 NUMERIC(9, 6) NOT NULL,
    longitude                NUMERIC(9, 6) NOT NULL,
    department_border        geometry(MultiPolygon, 4326),
    PRIMARY KEY (dept_id)
);