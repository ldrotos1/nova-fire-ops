CREATE TYPE nova_fire_ops.department_type AS ENUM ('CAREER', 'CAREER/VOLUNTEER');

CREATE TABLE nova_fire_ops.departments (
    id                       INTEGER       PRIMARY KEY,
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
    CREATE INDEX department_border_index ON nova_fire_ops.departments USING GIST (department_border);
);
