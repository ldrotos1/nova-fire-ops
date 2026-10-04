"""Validate all data files against _schema/ and check referential integrity.

Usage: python scripts/validate.py

Prints errors as `file:record-id: message` and exits non-zero if any are found.
Warnings (e.g. aid partners outside the covered set) are printed but don't fail.
"""

import datetime
import json
import sys
from pathlib import Path

import yaml
from jsonschema import Draft202012Validator
from referencing import Registry, Resource

ROOT = Path(__file__).resolve().parent.parent
SCHEMA_DIR = ROOT / "_schema"
TIER_ORDER = ["first_alarm", "working_fire", "second_alarm", "third_alarm", "fourth_alarm_plus"]

errors = []
warnings = []


def error(path, record_id, message):
    errors.append(f"{path.relative_to(ROOT).as_posix()}:{record_id}: {message}")


def warn(path, record_id, message):
    warnings.append(f"{path.relative_to(ROOT).as_posix()}:{record_id}: {message}")


def load_validators():
    schemas = {p.stem: json.loads(p.read_text(encoding="utf-8")) for p in SCHEMA_DIR.glob("*.json")}
    registry = Registry().with_resources(
        (f"{name}.json", Resource.from_contents(schema)) for name, schema in schemas.items()
    )
    return {
        name: Draft202012Validator(schema, registry=registry)
        for name, schema in schemas.items()
        if name != "common"
    }


def normalize(value):
    """YAML parses unquoted dates into date objects; schemas expect ISO strings."""
    if isinstance(value, dict):
        return {k: normalize(v) for k, v in value.items()}
    if isinstance(value, list):
        return [normalize(v) for v in value]
    if isinstance(value, (datetime.date, datetime.datetime)):
        return value.isoformat()[:10]
    return value


def load(path, validator):
    """Load and schema-check a YAML file. Returns the data, or None if it failed."""
    try:
        data = normalize(yaml.safe_load(path.read_text(encoding="utf-8")))
    except yaml.YAMLError as e:
        error(path, "-", f"YAML parse error: {e}")
        return None
    schema_errors = list(validator.iter_errors(data))
    for e in schema_errors:
        record_id = "-"
        if isinstance(data, list) and e.absolute_path and isinstance(e.absolute_path[0], int):
            record = data[e.absolute_path[0]]
            if isinstance(record, dict):
                record_id = record.get("id", f"[{e.absolute_path[0]}]")
        location = "/".join(str(p) for p in e.absolute_path) or "(root)"
        error(path, record_id, f"{location}: {e.message}")
    return None if schema_errors else data


def register_id(seen, path, record_id):
    if record_id in seen:
        error(path, record_id, f"duplicate id (also in {seen[record_id]})")
    else:
        seen[record_id] = path.relative_to(ROOT).as_posix()


def main():
    validators = load_validators()
    seen_ids = {}
    department_names = set()
    facility_ids = set()
    pending_home_refs = []  # (path, apparatus id, home_facility_id)
    pending_name_refs = []  # (path, record id, field, name)

    for dept_file in sorted(ROOT.glob("*/department.yaml")):
        dept_dir = dept_file.parent
        slug = dept_dir.name
        prefix = f"{slug}-"

        dept = load(dept_file, validators["department"])
        if dept is None:
            continue
        department_names.add(dept["name"])
        for partner in dept["aid_partners"]:
            pending_name_refs.append((dept_file, slug, "aid_partners", partner))

        company_ids = set()
        for company in dept.get("volunteer_companies", []):
            register_id(seen_ids, dept_file, company["id"])
            company_ids.add(company["id"])
            if not company["id"].startswith(prefix):
                error(dept_file, company["id"], f"volunteer company id must start with '{prefix}'")

        for kind in ("facilities", "apparatus"):
            path = dept_dir / f"{kind}.yaml"
            if not path.exists():
                continue
            records = load(path, validators[kind])
            if records is None:
                continue
            for record in records:
                rid = record["id"]
                register_id(seen_ids, path, rid)
                if not rid.startswith(prefix):
                    error(path, rid, f"id must start with '{prefix}'")
                if record["operator"] != dept["name"]:
                    error(path, rid, f"operator '{record['operator']}' does not match department name '{dept['name']}'")
                vol = record.get("volunteer_operator")
                if vol is not None and vol not in company_ids:
                    error(path, rid, f"volunteer_operator '{vol}' is not in {slug}/department.yaml volunteer_companies")
                if kind == "facilities":
                    facility_ids.add(rid)
                else:
                    pending_home_refs.append((path, rid, record["home_facility_id"]))

    hospitals_path = ROOT / "hospitals.yaml"
    if hospitals_path.exists():
        hospitals = load(hospitals_path, validators["hospitals"])
        for record in hospitals or []:
            register_id(seen_ids, hospitals_path, record["id"])
            for name in record["serves"]:
                pending_name_refs.append((hospitals_path, record["id"], "serves", name))

    incidents_path = ROOT / "incidents.yaml"
    if incidents_path.exists():
        incidents = load(incidents_path, validators["incidents"])
        incident_ids = set()
        for record in incidents or []:
            rid = record["id"]
            if rid in incident_ids:
                error(incidents_path, rid, "duplicate id")
            incident_ids.add(rid)
            tiers = [t["tier"] for t in record["response_tiers"]]
            if len(set(tiers)) != len(tiers):
                error(incidents_path, rid, "response_tiers contains a duplicate tier")
            elif tiers != sorted(tiers, key=TIER_ORDER.index):
                error(incidents_path, rid, f"response_tiers out of order; expected order {TIER_ORDER}")
            for tier in record["response_tiers"]:
                types = [r["apparatus_type"] for r in tier["response"]]
                if len(set(types)) != len(types):
                    error(incidents_path, rid, f"{tier['tier']}: apparatus_type listed more than once")

    for path, rid, home in pending_home_refs:
        if home not in facility_ids:
            error(path, rid, f"home_facility_id '{home}' does not match any facility")

    for path, rid, field, name in pending_name_refs:
        if name not in department_names:
            warn(path, rid, f"{field} name '{name}' does not match any department.yaml name")

    for w in warnings:
        print(f"warning: {w}")
    for e in errors:
        print(e)
    print(f"{len(errors)} error(s), {len(warnings)} warning(s)")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
