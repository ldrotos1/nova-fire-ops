## Overview

Fairfax County Fire and Rescue Department (FCFRD) is a combination career/volunteer department. Under the Northern Virginia regional numbering scheme its stations and units use the 4xx range (e.g. Station 21 is Station 421 and its engine is Engine 421).

- **Stations:** 39 county stations plus 6 support facilities: headquarters, training academy, the FRD/USAR Lorton Training Site (Virginia Task Force 1), logistics center, and two apparatus shops. The FRD facilities layer also lists a USAR office at 14725-H Flint Lee Rd, Chantilly, which isn't recorded because it's an office, not one of the tracked facility types.
- **Stations run by other departments:** Stations 403 and 433 are run by the City of Fairfax, and 463–466 by Fort Belvoir. The county's GIS layer includes them, but they belong in `fairfax-city/` and `fort-belvoir/`.
- **Volunteer companies:** 12 independent companies are associated with 15 stations.
- **Temporary stations:** Stations 423 and 432 are being rebuilt. Per project decision only the permanent sites are recorded, even though both currently operate from temporary locations:
  - Station 423: 8724 Little River Turnpike, Fairfax
  - Station 432: 11112 Chapel Road, Fairfax Station
- **Apparatus scope:** The roster includes every vehicle in the source except antiques, Public Information Officer vehicles, and the academy's training engines (Engine 407 / 407B), and any vehicle the source lists with no label (7 such vehicles, per project rule).
- **Status:** Suffixed units (B/C/E, e.g. Engine 402B, Ambulance 408E) are recorded as `reserve`. RadioReference defines Echo (E) as an "EMS-only staffed unit". In Fairfax these are volunteer-staffed, so per user decision (2026-10-04) they remain `reserve`. Exception: suffixed Utility and Swiftwater units (Utility 412B, Utility 422B, Swiftwater 412B, Swiftwater 412C) are `frontline`, per user decision.
- **Spare pool:** 105 unnumbered spare vehicles (pumpers, aerials, tankers, rescues, light/air, command vehicles, ambulances) are listed in the source without a facility assignment. Per project rule they are not recorded.
- **Medic vs. Ambulance:** "Medic" units are treated as ALS transport (`ambulance-als`) and "Ambulance" units as BLS (`ambulance-bls`).
- **Other category calls:**
  - SHRU (Special Hazards Response Unit) → `hazmat`
  - Foam 426 and the academy foam trailers → `other`
  - ALS/EMS 40x supervisor vehicles and the Operational Medical Director → `ems-supervisor`
- **ALS engines:** `als_capable` is set only where a source says so explicitly (Paramedic Engine 444).

## Sources

- **Fairfax County GIS, Fire Stations layer (official):** station addresses and coordinates. https://data-fairfaxcountygis.opendata.arcgis.com/datasets/Fairfaxcountygis::fire-stations-3
- **Fairfax County Fire Stations page (official):** station and support-facility list. https://www.fairfaxcounty.gov/fire-ems/fire-stations
- **Fairfax County Volunteer Fire and Rescue Association (official):** volunteer company to station mapping. https://fcvfra.org/about-us/member-departments/
- **NVERS member departments (official):** the NOVA Agreement parties used for `aid_partners`. https://www.nvers.org/fireems/fireems-member-departments
- **fire.fandom.com (secondary):** the apparatus roster, page revision of 2026-09-11. https://fire.fandom.com/wiki/Fairfax_County_Fire_and_Rescue_Department
- **FCFRD ArcGIS layers `FRD_Battalion` (revised 2024-12-18) and `FRD_Division` (revised 2022-04-23) (official):** station `battalion`/`division`, assigned by intersecting each station point with the polygons. https://services2.arcgis.com/S6mKhQEnAuTji2Zb/arcgis/rest/services
- **RadioReference wiki (secondary), page edited 2026-01-02:** a per-station unit table and battalion/division membership. Its battalion lists match the GIS-derived assignments exactly. https://wiki.radioreference.com/index.php/Fairfax_County_(VA)
- **US Census Geocoder:** coordinates for the non-station facilities. https://geocoding.geo.census.gov/geocoder/

## Data Gaps / Open Questions

- **Single source for apparatus:** every apparatus record rests on the fandom wiki alone. FCFRD publishes no official per-unit roster (the county site and the NERIS registry list stations only).
- **Volunteer ownership of apparatus is unknown.** The wiki gives many units "V"-prefixed fleet numbers, which suggests volunteer ownership. Per project decision this isn't used, so no apparatus has `volunteer_operator`.
  - **Evidence:**
    - Bailey's Crossroads VFD's apparatus page (dated 2020, http://www.bxrvfd.org/apparatus.html) says the company bought Medic 410, Medic 410B and Ambulance 410, and the county bought Engine 410 and Truck 410. Most of those vehicles have since been replaced, so this isn't used to set `volunteer_operator`.
    - Lorton VFD's homepage mentions "volunteer-owned fire and medical apparatus" in general terms, without naming units.
- **Which engines are ALS is unknown**, apart from Paramedic Engine 444.
- **Conflicts resolved by user decision (2026-10-04):**
  - **Rescue 401:** the wiki lists it at both Station 401 (McLean) and Station 425 (Reston). The user first chose 401, then moved it to **Station 425** after the RadioReference wiki also placed it there. That page notes the FY2026 reorganization assigns one rescue per battalion, numbered by battalion, and Station 425 is in battalion 401.
  - **Battalion Chief 470:** listed both at Public Safety Headquarters and under "Station/Assignment Unknown". It is recorded at headquarters.
  - **EMS Training Center:** the wiki places it at 7921 Jones Branch Rd, McLean. It is treated as part of the Training Academy (4600 West Ox Rd, per the county site) and not recorded separately. Its vehicle is homed at the academy.
- **Unit-name conflicts, resolved 2026-10-04.** The rule is to use the name two of the three sources agree on (fandom wiki, company site, RadioReference); otherwise prefer the company site when it's current.
  - **Dunn Loring:** the wiki and RadioReference both say Medic 413 and Ambulance 413, so those are kept. The company site's names (Ambulance 413 and Ambulance 413 Bravo) were tried and then reverted.
  - **Greater Springfield:** the company site and RadioReference both say Ambulance 422, so the wiki's Ambulance 422E is recorded as Ambulance 422.
  - **Fair Oaks:** the wiki's Medic 421B is recorded as Ambulance 421E, per the company site, which says BLS.
  - **Wiki name kept, because the other source is older:**
    - Great Falls: the site says Ambulance 412 where the wiki says Medic 412B.
    - Bailey's Crossroads: the 2020 site says Medic 410B where the wiki says Ambulance 410E, and marks Ambulance 410 as reserve.
    - Greater Springfield: the site has a second "Utility 422" where the wiki has Utility 422B.
- **Where RadioReference (2026-01-02) differs from the newer wiki (2026-09), the wiki is kept:**
  - Tower 438 vs. T438, and Truck 441 vs. TWR441.
  - Medic vs. Ambulance naming at Stations 412, 415, 419 and 438.
  - Station placement of Safety 401/402, ALS 403 and EMS 403. RadioReference predates the FY2026 reorganization.
- **Volunteer company sites as a second source:** they corroborate 32 records, which now cite both the wiki and the company site. Six companies (McLean, Franconia, Annandale, Burke, Centreville, Lorton) publish no apparatus listing.
- **Address variants where the county site was followed:**
  - South Apparatus Shop: the wiki says 6902 Newington Rd.
  - North Apparatus Shop: RadioReference says 4610 West Ox Rd.
  - Station 444: the wiki says 1766 Old Meadow Ln.
  - Station 441: the NERIS registry says 9601 Hampton Rd.
- **Units with no assignment:** several are listed under "Station/Assignment Unknown" (Mobile Command Post 400, Battalion Chiefs 471/472/474/492, etc.) and have no `home_facility_id`.
- **Battalion/division caveats:**
  - Assignments are spatial: each station is placed in the polygon that contains it. Every station also sat inside its own first-due area, and every battalion chief vehicle in the wiki roster sits inside its own battalion, which is a good independent check.
  - The division layer (revised April 2022) is older than the battalion layer (December 2024), but every battalion falls cleanly inside one division (401: battalions 401–403 and 407; 402: battalions 404–406 and 408).
  - The battalion layer's metadata says "Agency Use Only" even though it's publicly reachable.
  - The battalion layer also has battalion 443 (City of Fairfax) and 465 (Fort Belvoir). These go to those departments' stations.
- **Mutual aid outside the NOVA Agreement is not yet sourced.** This covers aid with Maryland and D.C. departments under the regional (COG) agreements.
- **Units found only on volunteer company sites:**
  - Chief 402 (Vienna VFD site).
  - Swiftwater 412 / 412B / 412C (Great Falls VFD site). That site appears outdated (it lists 2003–2012 vehicles), so these boats may no longer be in service.
- **Units only RadioReference lists (2026-01-02) are not recorded, per user decision.** There are 45 that don't appear in the newer fandom roster. They include volunteer chiefs, pre-FY2026 tech rescue numbers, boats and swiftwater units, brush trucks, UTVs, mobile command posts, and a few specialty units. VC402/408/414/417 probably duplicate the recorded Chief 402/408/414/417.
- **Pending manual review: status of the 23 unsuffixed Ambulance units.** All are `frontline` for now. 14 are their station's only frontline transport unit (416, 420, 423, 427, 428, 431, 434, 436, 437, 438, 440, 441, 442, 444). The other 9 sit alongside a Medic (402, 408, 409, 410, 411, 413, 414, 417, 422). The user will decide whether any should be `reserve`.
- **Single-source categories:** 72 of 243 apparatus records (39 station-based; the rest are headquarters, academy, logistics or unassigned units). `aid_partners` (NVERS only).
