# caj-archeo-trench — archaeoTrench Template Repository

This repository is the **official template** for the [archaeoTrench Utilities](https://github.com/lad-sapienza/archaeo-trench-utilities) QGIS plugin, developed at [LAD — Laboratorio di Archeologia Digitale](https://lad.saras.uniroma1.it), Sapienza University of Rome, for the Çuka e Ajtoit (CAJ) excavation project.

It defines the GeoPackage layer schema and QML visual styles used across all trench projects. The plugin reads this repository to deploy new projects, keep existing ones in sync, and publish schema or style changes back to the team.

---

## What this repository is

The plugin separates **data structure** from **field data**. This repository holds the data structure side:

- `schema.sql` — a plain-text SQL file that defines the layers (tables), their geometry type, coordinate reference system, and attribute fields
- `styles/` — QML style files that control how each layer looks in QGIS, organised into named style sets

Everything here is **plain text**: fully readable in any editor, diff-able in git, and reviewable in a pull request. No binary files, no proprietary formats.

---

## Repository layout

```
types/
├── plan/                       ← Top-down plan-view projects
│   ├── schema.sql              ← Layer definitions (edit this to add/remove fields)
│   └── styles/
│       ├── default/            ← Default style set (required)
│       │   ├── contexts.qml
│       │   ├── detail.qml
│       │   ├── elev_change.qml
│       │   ├── elevations.qml
│       │   └── limits.qml
│       └── <custom-set>/       ← Any number of additional style sets
│           └── ...
└── section/                    ← Stratigraphic section projects
    ├── schema.sql              ← (create this to enable section projects)
    └── styles/
        └── default/
```

Each directory under `types/` is a **project type**. The plugin uses the type stored in each deployed project's GeoPackage to know which subtree to read.

---

## How the plugin uses this repository

When you run **Deploy new trench** in the plugin:

1. It reads `types/{project_type}/schema.sql` and creates a fresh GeoPackage with one layer per table definition.
2. It copies the `styles/` directory into the new project folder.
3. It generates a `.qgz` QGIS project file with all layers grouped and styled.

When you run **Sync from template**:

1. It compares the live project's GeoPackage schema against `schema.sql` and adds any missing fields (existing data is never touched).
2. It reloads the QML style for each layer from the selected style set.

When you run **Save schema to template**:

1. It extracts the current GeoPackage schema back to `schema.sql`.
2. It exports the current QGIS layer styles to QML files in the selected style set folder.

Changes are then shared with the team via **Template repository → Publish changes**.

---

## Using this template with the plugin

### First-time setup (no git required)

Open QGIS → *Plugins → archaeoTrench Utilities → Template repository…* → **Download template**.

The plugin downloads a ZIP of this repository and extracts it to `~/.archaeotrench/`. No git installation needed.

### First-time setup (with git)

```bash
git clone https://github.com/lad-sapienza/caj-archeo-trench.git ~/.archaeotrench
```

Or use **Template repository… → Clone with git** from the plugin menu.

### Staying up to date

- **Without git**: *Template repository… → Update template* (re-downloads the ZIP)
- **With git**: *Template repository… → Pull latest*

---

## Creating your own template

Fork this repository on GitHub, then point the plugin to your fork:

1. Fork on GitHub (your profile → fork → create).
2. In QGIS: *archaeoTrench Utilities → Settings…* → set **Shared repo URL** to your fork URL.
3. Set **Push / fork URL** if you want to publish changes via pull request instead of pushing directly.
4. Use **Template repository… → Clone with git** (or re-download) to populate `~/.archaeotrench/` from your fork.

Edit `schema.sql` and `styles/` freely. Use **Save schema to template** to capture changes from a live project, then **Publish changes** to push them to your fork.

---

## Schema reference

The `schema.sql` file is a plain SQL file with a strict structure. The plugin parses it at deploy and sync time — the comments are not optional decoration, they are metadata.

### File header

The file must begin with a version line:

```sql
-- template_version: YYYY-MM-DD
```

This date is written into every deployed GeoPackage and shown in the plugin's Sync dialog. The plugin uses it to track whether a project is up to date. The **Save schema to template** action updates this line automatically to today's date.

### Layer blocks

Each layer is declared as a pair: a block of metadata comments followed by a `CREATE TABLE` statement. The two must be adjacent — no blank lines between the last comment and the `CREATE TABLE`.

```sql
-- layer: <table_name>
-- geometry: <geometry_type>
-- crs: <EPSG_code>
-- geometry_column: <column_name>
CREATE TABLE <table_name> (
    field1 TYPE,
    field2 TYPE(length),
    ...
);
```

**`-- layer:`** — the GeoPackage table name. Must be a valid SQL identifier (lowercase, underscores, no spaces). This name also drives QML matching: a QML file whose stem matches this name (case-insensitive, as a substring) is applied as the default style.

**`-- geometry:`** — the geometry type. Accepted values: `POINT`, `POLYGON`, `LINESTRING` (case-insensitive). Multi-variants (`MULTIPOLYGON` etc.) are not currently supported.

**`-- crs:`** — the coordinate reference system as an EPSG code (e.g. `EPSG:6870`). All layers in a project should share the same CRS; the project CRS is set to this value at deploy time.

**`-- geometry_column:`** — the name of the geometry column inside the GeoPackage. The default in OGR/QGIS is `geom`. Some contexts use `geometry`. The name must match what QGIS will read from the GeoPackage — if you change it, do so consistently.

### Field types

Only the **non-geometry** fields appear in `CREATE TABLE`. The geometry column is managed by OGR and must not be listed.

| SQL type | QGIS field type | Notes |
|---|---|---|
| `TEXT` | String | Unbounded length |
| `TEXT(n)` | String | Maximum length `n` (advisory; SQLite does not enforce) |
| `REAL` | Double | Floating-point number — use for elevations, measurements |
| `INTEGER` | Integer | 32-bit signed integer |

The plugin maps these types when creating GeoPackage layers via `QgsVectorFileWriter` and when inspecting existing layers during sync.

### Full example

```sql
-- template_version: 2026-05-03

-- layer: contexts
-- geometry: POLYGON
-- crs: EPSG:6870
-- geometry_column: geom
CREATE TABLE contexts (
    context      TEXT(30),
    context_type TEXT(100)
);

-- layer: elevations
-- geometry: POINT
-- crs: EPSG:6870
-- geometry_column: geom
CREATE TABLE elevations (
    elevation REAL,
    context   TEXT(20)
);
```

### Rules and constraints

- **Order matters for the layer tree**: the plugin adds layers to the QGIS project in the order they appear in `schema.sql`. The last layer in the file ends up at the top of the layer tree (drawn last = on top).
- **`fid` is automatic**: do not declare an `fid` or `id` column — GeoPackage adds a primary key automatically.
- **Adding fields**: add a line to `CREATE TABLE` in `schema.sql`. The next time a project runs **Sync from template**, that field is added to the live GeoPackage. Existing data in other fields is untouched.
- **Removing or renaming fields**: the sync is additive only — fields removed from `schema.sql` are not deleted from existing projects. Renaming a field in SQL is equivalent to removing the old one and adding a new empty one.
- **No `NOT NULL` or `DEFAULT`**: SQLite/GeoPackage supports constraints, but the plugin does not declare them — keep field definitions as bare `name TYPE` or `name TYPE(n)`.

---

## Plan layers

*The following descriptions cover the layer design and field semantics for the plan project type. — to be completed.*

### `contexts`

Polygon layer. Represents excavation contexts (stratigraphic units).

| Field | Type | Description |
|---|---|---|
| `context` | TEXT(30) | |
| `context_type` | TEXT(100) | |

### `detail`

Polygon layer. Fine-grained detail features within a context.

| Field | Type | Description |
|---|---|---|
| `context` | TEXT(30) | |
| `material` | TEXT(255) | |

### `elev_change`

LineString layer. Elevation change lines (scarps, steps, breaks in slope).

| Field | Type | Description |
|---|---|---|
| `context` | TEXT(30) | |

### `elevations`

Point layer. Individual elevation measurements, auto-populated from a DEM by the plugin's Auto-elevation feature.

| Field | Type | Description |
|---|---|---|
| `elevation` | REAL | Elevation value sampled from DEM |
| `context` | TEXT(20) | |

### `limits`

Polygon layer. Outer boundary of the excavation trench.

| Field | Type | Description |
|---|---|---|
| `trench` | TEXT(30) | |

---

## Styles reference

Styles are stored as QML files — QGIS's native layer style format. Each file completely describes the symbology, labels, field visibility, and rendering order for one layer.

Style files are organised into **style sets** — named subdirectories under `styles/`. The plugin can switch between style sets at deploy time, sync time, or on demand. Each set must contain one QML file per layer (named to match the layer table name).

### QML matching

The plugin matches QML files to layers by name: it looks for a QML file whose stem (filename without extension) appears as a substring of the layer name, case-insensitively. For example, `contexts.qml` matches both the `Contexts` base layer and the `c100 Contexts` context group layer.

### Available style sets

#### `default`

*— to be completed.*

#### `filer-by-context-name`

*— to be completed.*

### Creating a new style set

1. Duplicate an existing style set directory under `styles/`.
2. Edit the QML files in QGIS (Layer → Save as → QML) or directly in a text editor.
3. Run **Save schema to template** in the plugin with the new set name — the plugin will export the current layer styles and save them under `styles/<new-set-name>/`.
4. Publish the changes.

---

## Contributing

Changes to the schema or styles that benefit the whole team should be submitted as a pull request:

1. Clone the repository (see setup above).
2. Make your changes — edit `schema.sql` or style files, or use **Save schema to template** from a live project.
3. Use **Template repository… → Publish changes** from the plugin, which commits your changes and opens the pull request form on GitHub.

For changes to the `section` project type, see `types/section/README.md`.
