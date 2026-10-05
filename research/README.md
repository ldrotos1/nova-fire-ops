# NoVA Fire Ops — Research

Structured data on fire departments in Northern Virginia and surrounding jurisdictions — facilities, apparatus, hospitals, and incident response — compiled for GIS/mapping and response-time/coverage analysis. See [CLAUDE.md](CLAUDE.md) for the full schema, sourcing policy, and conventions.

## Layout

- `<department>/` — one directory per department: `department.yaml`, `facilities.yaml`, `apparatus.yaml`, `notes.md`
- `hospitals.yaml` / `hospitals-notes.md` — region-level emergency department catalog
- `incidents.yaml` / `incidents-notes.md` — region-level CAD call type and response catalog
- `_schema/` — JSON Schemas for every structured file
- `scripts/validate.py` — schema and referential-integrity checks

## Validation

```
pip install -r requirements.txt
python scripts/validate.py
```

## Status

Stages: `not started` → `facilities` → `apparatus` → `verified`

### Primary departments

| Department | Status |
|---|---|
| Fairfax County | apparatus |
| Fairfax City | not started |
| Fort Belvoir | not started |
| Arlington County | not started |
| City of Alexandria | not started |
| Joint Base Myer-Henderson Hall | not started |
| Metropolitan Airport Authority | not started |

### Supporting departments

| Department | Status |
|---|---|
| Prince William County | not started |
| Loudoun County | not started |
| Montgomery County | not started |
| Washington, D.C. | not started |
| Prince George's County | not started |
| Manassas City | not started |
| Manassas Park | not started |

### Shared catalogs

- **Incidents** (`incidents.yaml`): not started
- **Hospitals** (`hospitals.yaml`): not started
