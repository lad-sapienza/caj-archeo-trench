# Section template

Template data for the **section** project type (elevation / section view).

CRS: **EPSG:6870** (ETRS89 / Albania TM 2010)

---

## Status

This template type is **not yet defined**. The `schema.sql` file does not exist; deploying a `section` project will raise an error until it is created.

To set up the section template:

1. Design the layer schema for section/elevation drawings.
2. Create `schema.sql` in this directory following the format described below.
3. Add QML style files to `styles/default/`.
4. Use **Save schema to template** from an open section project to populate the schema and styles automatically.

---

## Files

| File | Description |
|---|---|
| `schema.sql` | Layer definitions *(to be created)* |
| `styles/` | QML style files, one subdirectory per style set *(to be created)* |

---

## schema.sql format

Each layer is declared by a block of `--` metadata comments followed by a `CREATE TABLE` statement. The geometry column is managed by OGR/QGIS and must not appear in the `CREATE TABLE` body.

```sql
-- template_version: YYYY-MM-DD

-- layer: <table_name>
-- geometry: <Point|Polygon|LineString>
-- crs: EPSG:6870
-- geometry_column: <column_name>
CREATE TABLE <table_name> (
    <field> <TYPE>,
    ...
);
```

The first line must be `-- template_version: YYYY-MM-DD`. This date is written automatically by **Save schema to template** and recorded in `_meta.template_version` of every deployed GeoPackage.

See `template/types/plan/README.md` for the complete format reference and a worked example.

---

## Editing the template

**To add a field:** edit `schema.sql` directly, or open a section project, add the field in QGIS, then run **Save schema to template**.

**To share changes:** use **Publish to repository…** in the plugin menu.
