# blackout
Jupyter notebook + utilities to study Spain's blackout from the STARS4ALL photometer netwrok

# Technical notes

## SQL Queries

Get the photometers deployed at the Iberian peninsula with data from 2025-04-08 21:30 local time till midnight. along with its location and number of readings in that period.

```sql
SELECT n.name, l.place, l.town, COUNT(r.tess_id) as '# readings'
FROM tess_readings_t AS r
JOIN tess_t AS p USING (tess_id)
JOIN date_t as d USING(date_id)
JOIN time_t as t USING(time_id)
JOIN location_t AS l USING(location_id)
JOIN name_to_mac_t AS n USING(mac_address)
WHERE r.date_id = '20250428' AND r.time_id >= '193000' -- time in UTC time
AND p.valid_state = 'Current' AND n.valid_state = 'Current'
AND n.name IN (SELECT name FROM tess_v WHERE timezone = 'Europe/Madrid')
GROUP BY (r.tess_id)
ORDER by CAST(substr(n.name, 6) as decimal) ASC;
```
