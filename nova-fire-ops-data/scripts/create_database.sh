#!/bin/bash
echo "|--------------------------------------------------------------------|"
echo "| This script will create the nova fire operations postgres database |"
echo "|--------------------------------------------------------------------|"

if ! [ -f ~/.nova-fire-ops/.dbconnprops ]; then
  printf "\nRequired ~/.nova-fire-ops/.dbconnprops file doesn't exist"
  printf "\nRun set_conn_props.sh to create"
  exit 1
fi

if ! [ -f ~/.nova-fire-ops/.pgpass ]; then
  printf "\nRequired ~/.nova-fire-ops/.pgpass file doesn't exist"
  printf "\nRun set_conn_props.sh to create"
  exit 1
fi

IFS=":"
read -ra conn_info < ~/.nova-fire-ops/.dbconnprops

if ! [ ${#conn_info[@]} = 3 ]; then
  printf "\nThe ~/.nova-fire-ops/.dbconnprops file is corrupted"
  printf "\nRun set_conn_props.sh to recreate"
  exit 1
fi

host=${conn_info[0]}
port=${conn_info[1]}
user=${conn_info[2]}

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CREATE_DB_FILE="${SCRIPT_DIR}/../sql/schema/create_database.sql"
CREATE_TABLES_FILE="${SCRIPT_DIR}/../sql/schema/create_tables.sql"
DEPARTMENT_DATA="${SCRIPT_DIR}/../sql/seed/departments.csv"

echo "Creating database and table schema"
psql -U "$user" -h "$host" -p "$port" -f "$CREATE_DB_FILE"
psql -U "$user" -h "$host" -p "$port" -d nova-fire-ops -f "$CREATE_TABLES_FILE"

echo "Loading department data"
DEPARTMENT_DATA=$(echo "$DEPARTMENT_DATA" | tr / \\\\)
DEPARTMENT_DATA="c:$(echo "$DEPARTMENT_DATA" | cut -c 3-)"
psql -U "$user" -h "$host" -p "$port" -d nova-fire-ops \
  -c "\\copy nova_fire_ops.departments from '$DEPARTMENT_DATA' WITH DELIMITER ',' CSV HEADER;"

echo "Loading department borders"
BORDERS_FILE="${SCRIPT_DIR}/../sql/seed/department_borders.geojson"

psql -U "$user" -h "$host" -p "$port" -d nova-fire-ops <<ENDSQL
UPDATE nova_fire_ops.departments AS d
SET department_border = sub.geom
FROM (
    SELECT
        (feature -> 'properties' ->> 'dept_id')::integer AS dept_id,
        ST_GeomFromGeoJSON(feature -> 'geometry')::geometry(MultiPolygon, 4326) AS geom
    FROM json_array_elements(\$\$$(cat "$BORDERS_FILE")\$\$::json -> 'features') AS feature
) sub
WHERE d.dept_id = sub.dept_id;
ENDSQL

echo "Database created"