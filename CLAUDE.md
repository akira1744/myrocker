# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Docker-based R/RStudio Server + Shiny Server environment (R 4.5.3) designed for Japanese data scientists. Provides a comprehensive environment with 100+ pre-installed R packages for statistical analysis, machine learning, and data visualization.

Deployed in two environments:
1. **Online dev PC** (this machine, WSL2 + Docker Desktop) — built directly with `docker compose build`.
2. **Offline EMR Windows PC** — image is transferred as a tar via `docker save` / `docker load`.

## Key Commands

### Build and Run
```bash
# Build Docker image
docker compose build

# Start container
docker compose up -d

# Stop container
docker compose down
```

### Docker Image Management
```bash
# Pull latest image
docker pull nujabec/myrocker:20260519

# Push to Docker Hub
docker login
docker push nujabec/myrocker:20260519

# Export for offline environments
docker save nujabec/myrocker:20260519 -o myrocker_20260519.tar

# Import in offline environment
docker load -i myrocker_20260519.tar
```

## Architecture

### Container Configuration
- **Base Image**: `rocker/geospatial:4.5.3` — R 4.5.3 on Ubuntu 24.04 (noble) with geospatial capabilities
- **Ports**:
  - 50003 → 8787 (RStudio Server)
  - 81 → 3838 (Shiny Server)
- **Users**: 21 accounts (user00-user20), all in the `rstudio` group, password = username
- **Locale**: Japanese (ja_JP.UTF-8), Asia/Tokyo, CJK fonts (IPA, Noto CJK)
- **CRAN repo**: Posit Package Manager (PPM) pinned at `__linux__/noble/2026-05-18` for reproducibility

### Key Components
1. **docker-compose.yml**: Container orchestration
   - `../srv/` → `/home/rstudio/srv/` (project files)
   - `../srv/shinyapps` → `/srv/shiny-server/` (Shiny apps)
   - `../srv/shinylog` → `/var/log/shiny-server/` (Shiny logs)

2. **docker/Dockerfile**: Multi-stage layered build
   - Locale / timezone / CJK fonts / Microsoft ODBC 17 / Node.js 20 / GitHub CLI / DuckDB CLI (single layer)
   - PPM CRAN pin + HTTPUserAgent set in `/usr/local/lib/R/etc/Rprofile.site`
   - `remotes` installed before `installGithub.r` (4.5.x base no longer pre-installs it)
   - Multiple `install2.r` layers for CRAN packages
   - LibreOffice (full install)
   - Project-specific packages (arrow, Polychrome, future, openxlsx2, reactable, shinyWidgets, shinybusy, shinycssloaders, shinymanager, shinytest2, sortable, stringdist, tidyxl, waiter, writexl)
   - Shiny Server via `/rocker_scripts/install_shiny_server.sh` (coexists with RStudio under s6-overlay)
   - User setup
   - **Final layer**: `npm install -g @anthropic-ai/claude-code @google/gemini-cli` (placed last so updates of just these don't invalidate earlier caches)
   - HEALTHCHECK probing RStudio's unauth HTML

3. **docker/add_users.sh**: Creates user00-user20 with symlink to `srv/` in each home

### Pre-installed Package Categories
- **Core**: tidyverse ecosystem, arrow
- **Database**: RPostgreSQL, RMySQL, odbc, DuckDB
- **ML/Statistics**: xgboost, glmnet, caret, survival, lme4, tidymodels
- **Visualization**: plotly, gganimate, gt, flextable, reactable
- **Shiny ecosystem**: shiny, shinydashboard, shinyWidgets, shinybusy, shinycssloaders, shinymanager, shinytest2, sortable, waiter
- **Japanese-specific**: zipangu, NipponMap, jpndistrict
- **Geospatial**: sf, tmap, terra, leaflet
- **Excel/Office I/O**: openxlsx, openxlsx2, writexl, readxl, tidyxl, officer, flextable

## Development Notes

- Optimized for offline use with pre-installed packages
- RStudio configuration pre-set via `docker/rstudio-prefs_mysettings.json`
- Custom R startup settings in `docker/dotRprofile`
- SQL Server connectivity via Microsoft ODBC Driver 17 (signed-by keyring; Ubuntu 24.04 requirement)
- Includes cron for scheduled tasks
- Built-in HEALTHCHECK so `docker ps` reports container health

## Recent Updates

- **2026/05/19**: R 4.5.3, merged Shiny Server in, removed CIFS mount, PPM date-pinned, added 15 packages for the dept-level inpatient-revenue project, Microsoft ODBC signed-by fix, Claude Code/Gemini in final layer, HEALTHCHECK, image tag `20260519`
- **2025/11/22**: Added LibreOffice installation for document handling
- **2025/10/19**: Added Claude Code CLI and Gemini CLI support
- **2025/09/17**: Updated to new image tag with latest configuration
- **2024/10/18**: Updated all R packages to latest versions to fix patchwork 1.1.3 compatibility issue
- **2024/09/07**: Added DuckDB for analytical workloads
- **2024/09/03**: Added cron and user00
- **2024/05/03**: Added packages introduced at Tokyo.R 2024/4/20, updated RStudio settings
