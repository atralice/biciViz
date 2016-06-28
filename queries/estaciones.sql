SELECT AddGeometryColumn('estaciones','point','4326','POINT',2);
UPDATE estaciones SET point = ST_PointFromText(wkt, 4326);