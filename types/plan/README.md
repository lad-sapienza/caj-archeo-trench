# Plan template

Template data for the **plan** project type (top-down view).

CRS: **EPSG:6870** (ETRS89 / Albania TM 2010)

---

## Files

| File | Description |
|---|---|
| `schema.sql` | Layer definitions — edit this to add or rename fields |
| `styles/` | QML style files, one subdirectory per style set |

---

## schema.sql format

Each layer is declared by a block of `--` metadata comments followed by a `CREATE TABLE` statement. The geometry column is managed by OGR/QGIS and must not appear in the `CREATE TABLE` body.

```sql
-- layer: <table_name>
-- geometry: <Point|Polygon|LineString>
-- crs: EPSG:6870
-- geometry_column: <column_name>
CREATE TABLE <table_name> (
    <field> <TYPE>,
    ...
);
```

The first line of the file must be:

```sql
-- template_version: YYYY-MM-DD
```

This date is written automatically by **Save schema to template** and recorded in `_meta.template_version` of every deployed GeoPackage.

---

## Layers

### `elevations` — Point

| Field | Type |
|---|---|
| `elevation` | REAL |
| `context` | TEXT(20) |

Geometry column: `geom`

### `contexts` — Polygon

| Field | Type |
|---|---|
| `context` | TEXT(30) |
| `context_type` | TEXT(100) |

Geometry column: `geom`

### `detail` — Polygon

| Field | Type |
|---|---|
| `context` | TEXT(30) |
| `material` | TEXT(255) |

Geometry column: `geom`

### `elev_change` — LineString

| Field | Type |
|---|---|
| `context` | TEXT(30) |

Geometry column: `geometry` *(note: different from the other layers)*

### `limits` — Polygon

| Field | Type |
|---|---|
| `trench` | TEXT(30) |

Geometry column: `geom`

---

## Style sets

Each subdirectory of `styles/` is an independent style set. The `default` set is used when deploying and when no explicit set is chosen.

```
styles/
└── default/
    ├── contexts.qml
    ├── detail.qml
    ├── elev_change.qml
    ├── elevations.qml
    └── limits.qml
```

QML files are matched to layers by stem substring (case-insensitive): `elevations.qml` applies to both `elevations` and `c100 Elevations`.

---

## Editing the template

**To add a field:** add it to the relevant `CREATE TABLE` block in `schema.sql`, then run **Save schema to template** from inside a project that already has the field — or edit `schema.sql` directly. Existing deployed projects can be updated via **Sync from template**.

**To add a style set:** create a new subdirectory under `styles/` and populate it with QML files named after the layer tables.

**To share changes with the team:** use **Publish to repository…** in the plugin menu.
