-- template_version: 2026-05-04

-- layer: contexts
-- geometry: POLYGON
-- crs: EPSG:6870
-- geometry_column: geometry
CREATE TABLE contexts (
    context TEXT,
    context_type TEXT(50)
);

-- layer: details
-- geometry: POLYGON
-- crs: EPSG:6870
-- geometry_column: geometry
CREATE TABLE details (
    material TEXT
);

-- layer: limits
-- geometry: LINESTRING
-- crs: EPSG:6870
-- geometry_column: geom
CREATE TABLE limits (

);
