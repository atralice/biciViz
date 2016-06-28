SELECT row_to_json(fc)
 FROM ( SELECT 'FeatureCollection' As type, array_to_json(array_agg(f)) As features
 FROM (SELECT 'Feature' As type
    , ST_AsGeoJSON(ST_MakeLine(eo.point, ed.point))::json As geometry
    , row_to_json((origenestacionid, nombreorigen, destinoestacionid, nombredestino, avg(tiempouso),count(*))) As properties
     from recorridos r
JOIN estaciones eo 
	ON eo.id_fg = r.origenestacionid
JOIN estaciones ed
	ON ed.id_fg = r.destinoestacionid
GROUP BY origenestacionid, nombreorigen, destinoestacionid, nombredestino, ST_AsGeoJSON(ST_MakeLine(eo.point, ed.point)) ORDER BY count(*) DESC   ) As f )  As fc;