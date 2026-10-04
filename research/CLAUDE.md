# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project purpose

This repository researches and compiles data about fire departments in Northern Virginia and surrounding jurisdictions. There is no application code — the repo is a structured data-collection effort, with Claude Code acting as the primary researcher/compiler. The eventual use of this data is GIS/mapping and response-time/coverage analysis, so structural consistency across departments matters more than narrative polish.

This is a one-time compile effort, not a maintained live feed — there is no enforced re-verification cadence.

### Departments covered

**Primary departments** (full data collection, including facility, apparatus, and incident/response data):
- Fairfax County
- Fairfax City
- Fort Belvoir
- Arlington County
- City of Alexandria
- Joint Base Myer-Henderson Hall
- Metropolitan Airport Authority

**Supporting departments** (facility and apparatus data only, for regional/mutual-aid context):
- Prince William County
- Loudoun County
- Montgomery County
- Washington, D.C.
- Prince George's County
- Manassas City
- Manassas Park

Independent volunteer fire companies (e.g. within Fairfax County) are in scope. They are nested under their county's directory, not split out separately — see `operator` / `volunteer_operator` fields below.

Fort Belvoir and JBM-HH are active military installations, but there is no OPSEC restriction here beyond normal sourcing rules (see below) — research them the same as any other department.

**Fairfax County is compiled first** and serves as the concrete example the rest follow.

## Sourcing policy

Priority order:
1. Official department/county/installation websites and open-data portals
2. Enthusiast wikis and reference sites (e.g. fire.fandom.com, Wikipedia)

`source` on every record is a **list** of `{url, confidence}` items, where `confidence` is the tier that source came from (`official` / `secondary`). A record's effective confidence is the best tier among its sources, so lower-confidence entries can be found and re-checked later without re-deriving confidence from the raw URL.

**When sources conflict, stop and ask the user** how to resolve it rather than picking one silently.

## Repository layout

Data is organized **by department** (kebab-case directory names, e.g. `fairfax-county/`, `arlington-county/`), not by data category. A facility record lives under the **operating** department's directory, even if it sits physically in another jurisdiction.

### IDs

Every record `id` is a readable slug: department directory name + record type + the unit's designation (e.g. `fairfax-county-station-421`, `fairfax-county-engine-421`), so references like `home_facility_id` stay legible when read in isolation. IDs are globally unique via the department prefix, so cross-department references are allowed.

- Departments in the Northern Virginia regional numbering scheme use their regional numbers (Arlington 101–110, Alexandria 201–210, Fairfax County 4xx, etc.).
- Departments outside that scheme (D.C., Montgomery, Prince George's, military installations) use their own designations verbatim.
- Records with no designation (maintenance shop, reserve unit without a reserve number) fall back to a sequence number (e.g. `fairfax-county-reserve-engine-01`).

### Per-department files

- `department.yaml` — department identity: `name`, `website`, `type` (county/city/independent/military/authority — `authority` covers government entities like the Metropolitan Airport Authority that run their own fire-rescue), `aid_partners` (list of plain department names for mutual/automatic aid relationships — agreement details are out of scope, just *that* the relationship exists), `volunteer_companies` (list of independent volunteer companies operating under this county, each with a stable `id` slug prefixed by the department directory name, and `name` — omitted when the department has none)
- `facilities.yaml` — a list of stations, headquarters, maintenance, storage, and training facilities. Per record: `id`, `name`, `type` (`station` / `headquarters` / `maintenance` / `storage` / `training`), `address`, `lat`, `long`, `coordinate_source` (`source-provided` / `geocoded`), `operator` (the department's `name` — always set), `volunteer_operator` (the `id` of a company in this department's `volunteer_companies` list — omitted entirely, not null, when the facility is solely county-operated), `source`, `last_verified`
- `apparatus.yaml` — a list of units. An apparatus record represents a **position** (the designation, e.g. "Engine 421"), not a physical vehicle — the truck behind a designation rotates and is rarely published. Per record: `id`, `label` (the department's own designation), `type` (the department's own label, preserved verbatim — not forced into a standardized taxonomy), `category` (normalized, **multi-value** list from the controlled vocabulary below), `als_capable` (optional boolean — `true` for ALS engines/trucks staffed with a paramedic; category stays e.g. `[engine]`, since these don't transport), `status` (`frontline` / `reserve` / `out-of-service`, default `frontline`), `home_facility_id` (references any `facilities.yaml` record, in any department — station, headquarters, storage, training, etc.), `operator`, `volunteer_operator` (same rule as facilities — set only when a volunteer company owns/operates the unit; never inferred from the home facility), `source`, `last_verified`. No staffing/seating field — staffing is too variable day-to-day and rarely published per-unit. A single home facility is assumed as the norm; genuine cross-staffing exceptions go in that department's `notes.md` rather than the schema.
- `notes.md` — narrative research notes, following a fixed template: `## Overview`, `## Sources` (general references that don't belong to one specific record), `## Data Gaps / Open Questions`. No change log section — git history covers that.

### Apparatus category vocabulary

`engine`, `ladder`, `quint`, `rescue`, `tanker`, `ambulance-als`, `ambulance-bls`, `ems-supervisor`, `brush`, `hazmat`, `command`, `marine`, `arff`, `air-light`, `aviation`, `medical-bus`, `mass-casualty`, `rehabilitation`, `canteen`, `other`.

- A quint is `[engine, ladder]`.
- Trucks, tillers, and towers are all `[ladder]`.
- Heavy/technical rescues and squads are `[rescue]`.
- `arff` = aircraft rescue and firefighting (crash trucks). `air-light` = breathing-air/lighting support. `aviation` = helicopters/aircraft.

### Coordinates

WGS84 decimal degrees, marking the **building** location. When geocoding (`coordinate_source: geocoded`), use the US Census Geocoder and cite it as an item in the record's `source` list.

No jurisdiction boundary data (e.g. GeoJSON response zones) for now — station locations plus `aid_partners` are enough for a first-pass coverage model; boundaries are a much heavier lift and can be added later if needed.

## Hospitals

`hospitals.yaml` at the repo root (region-level, not per-department) tracks every emergency department **physically inside a covered jurisdiction** — full hospitals and freestanding EDs alike. One entry per facility, not duplicated across departments, since a given hospital (e.g. Inova Fairfax) often serves multiple jurisdictions. Per record: `id`, `name`, `facility_type` (`hospital` / `freestanding_ed`), `address`, `lat`, `long`, `coordinate_source`, `serves` (list of plain department names that commonly transport here — one-directional; departments do not reverse-reference hospitals), `trauma_level`, `trauma_level_system` (the designating authority, e.g. `VDH`, `MIEMSS`, `DC Health` — record each hospital's trauma level as stated by its home jurisdiction rather than normalizing across systems; required whenever `trauma_level` is set), `pediatric_trauma_level` (tracked separately from adult trauma level), `burn_center` (boolean), `stroke_center_level`, `stemi_cardiac_center` (boolean), `source`, `last_verified`. Designation fields are omitted when not applicable (e.g. freestanding EDs). Any EMS-transport-relevant designation gets its own named field as it comes up (e.g. hyperbaric, poison control) rather than a freeform catch-all — add it to the schema first.

`hospitals-notes.md` at the repo root holds narrative notes for this catalog, using the same template as department `notes.md`.

## Incident response

`incidents.yaml` at the repo root (region-level, not per-department) — unlike facilities/apparatus, incident response is **not** tracked per department. All primary departments operate under the shared Northern Virginia emergency response system and are assumed to respond uniformly, so there is a single shared catalog rather than 7 duplicated files. This is a modeling assumption, not a verified fact per department — if research turns up a genuine divergence, note it in that record's `notes` rather than restructuring the schema.

The catalog is keyed on **CAD call types** (what dispatch actually sends units on), not NFIRS codes, which are post-incident classifications. Every entry is a call type with a documented response. The research agent should consider every possible source for the call-type list (regional run-card documents, department CAD lists, operations manuals) and record how the catalog was built in `incidents-notes.md` (same template as department `notes.md`). Conflicting lists → ask the user.

Per record: `id` (slug, e.g. `structure-fire-residential`), `name` (the CAD label verbatim), `cad_code` (optional), `nfirs_codes` (optional cross-reference list of 3-digit NFIRS incident types), `response_tiers`, `notes` (optional — e.g. which departments actually run an MWAA- or military-specific call type such as aircraft alerts), `source`. No `last_verified`.

`response_tiers` is an **ordered** escalation list. Each item has a `tier` from this fixed scale, in this order: `first_alarm` → `working_fire` → `second_alarm` → `third_alarm` → `fourth_alarm_plus`. Each tier lists only the **incremental** units it adds (not cumulative), as a `response` list of `{apparatus_type, count}` where `apparatus_type` uses the same category vocabulary as `apparatus.yaml` (so an incident's response can be directly compared against fleet composition). Tiers that don't apply to a call type are simply omitted. Escalation tiers are almost always published together in one run-card document, so `source` is per call type, not per tier. Mutual aid is not represented in response lines, only the home system's own apparatus type/count.

## Schema validation

`_schema/` at the repo root holds JSON Schema files for all five structured file types (`department`, `facilities`, `apparatus`, `hospitals`, `incidents`) plus `common.json` for shared definitions (source items, category vocabulary, slugs).

Run the validator after any data change:

```
pip install -r requirements.txt
python scripts/validate.py
```

It checks every file against its schema and then checks referential integrity: unique IDs repo-wide, ID prefixes matching the department directory, `operator` matching the department `name`, `volunteer_operator` resolving to the department's `volunteer_companies`, `home_facility_id` resolving to a facility in any department, and response tier ordering. Unknown names in `aid_partners` / `serves` are reported as warnings (partners can lie outside the covered set). Errors print as `file:record-id: message` and make the script exit non-zero.

## Source tracking (required)

Every data point must be traceable (see per-file field lists above). When updating an existing entry, update its `source` list and `last_verified` rather than silently overwriting without a trail. `last_verified` (`YYYY-MM-DD`) is record-level and informational only — there is no enforced staleness threshold.

## Status tracking

The root `README.md` holds a per-department status table: `not started` → `facilities` → `apparatus` → `verified`. `verified` means every applicable category has been checked against **all sources that could be found**; a single source is acceptable when no other exists, but every category resting on a single source must be listed as such under that department's `## Data Gaps / Open Questions`. The shared `incidents.yaml` and `hospitals.yaml` catalogs each get their own separate status line, since they aren't per-department work.

## Status

No data has been collected yet. This schema/layout is the agreed design — Fairfax County is compiled first and should follow it exactly as the concrete example for the rest.
