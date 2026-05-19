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
  - 50004 → 8787 (RStudio Server)
  - 81 → 3838 (Shiny Server)
- **Users**: 21 accounts (user00-user20), all in the `rstudio` group, password = username
- **Locale**: Japanese (ja_JP.UTF-8), Asia/Tokyo, CJK fonts (IPA, Noto CJK)
- **CRAN repo**: Posit Package Manager (PPM) pinned at `__linux__/noble/2026-05-18` for reproducibility

### Key Components
1. **docker-compose.yml**: Container orchestration
   - `../srv/` → `/home/rstudio/srv/` (project files)
   - `../srv/shinyapps` → `/srv/shiny-server/` (Shiny apps)
   - `../srv/shinylog` → `/var/log/shiny-server/` (Shiny logs, bind-mounted for host visibility)

2. **docker/Dockerfile**: Multi-stage layered build
   - Locale / timezone / CJK fonts / Microsoft ODBC 17 / Node.js 20 / GitHub CLI / DuckDB CLI (single layer)
   - PPM CRAN pin + HTTPUserAgent + `copilot-enabled=1` + `posit-assistant-enabled=0` (offline) in `/usr/local/lib/R/etc/Rprofile.site` / `rsession.conf`
   - `remotes` installed before `installGithub.r` (4.5.x base no longer pre-installs it)
   - Multiple `install2.r` layers for CRAN packages
   - LibreOffice (full install)
   - Project-specific packages (arrow, Polychrome, future, openxlsx2, reactable, shinyWidgets, shinybusy, shinycssloaders, shinymanager, shinytest2, sortable, stringdist, tidyxl, waiter, writexl, bsicons)
   - Shiny Server via `/rocker_scripts/install_shiny_server.sh` (coexists with RStudio under s6-overlay)
   - `logrotate` package + image-baked `shiny-server.conf` / `shiny-server-logrotate` / Noto Sans JP woff2 fonts (see "Image-baked Shiny tuning" below)
   - s6 service for cron auto-start + cont-init.d script to install user crontabs
   - User setup
   - **Final layer**: `npm install -g @anthropic-ai/claude-code @google/gemini-cli` (placed last so updates of just these don't invalidate earlier caches)
   - HEALTHCHECK probing RStudio's unauth HTML

3. **docker/add_users.sh**: Creates user00-user20 with symlink to `srv/` in each home

4. **docker/shiny-server.conf** → `/etc/shiny-server/shiny-server.conf`: image-baked override
   - `app_idle_timeout 7200` (2h): keep app warm 2h after last disconnect
   - `app_init_timeout 120`: allow up to 2min for slow startup (large global.R + parquet)
   - `simple_scheduler 100`: single R worker shared by all sessions (single-user pattern). `1` would limit to 1 concurrent session per worker and return 503 on the 2nd request, so use a generous N.
   - `preserve_logs true`: keep per-session logs even on clean exit (fixes "shiny logs disappear" pitfall)
   - `sanitize_errors false`: full R error in logs and browser
   - `location /_fonts/` → `/opt/fonts-web` for serving image-baked web fonts

5. **docker/shiny-server-logrotate** → `/etc/logrotate.d/shiny-server` (mode 0644, owned root): rotates `/var/log/shiny-server/*.log` daily, 14 generations, 5MB threshold, `copytruncate`, `su root root` (needed because the bind-mounted log dir is 0777). Overrides the rocker-shipped logrotate config which targeted a non-existent single-file path.

6. **docker/cron-service-run** → `/etc/services.d/cron/run`: s6 service that `exec /usr/sbin/cron -f` so the daemon is auto-started and supervised.

7. **docker/install_crontabs.sh** → `/etc/cont-init.d/03_install_crontabs`: at container startup, copies any `srv/crontabs/<user>` flat file to `/var/spool/cron/crontabs/<user>` (root:crontab 0600) so user crontabs survive container recreation.

### Image-baked Shiny tuning
- **Warm-keep**: `app_idle_timeout 7200` + warm-up curl from a user crontab keep the R process alive across the workday, eliminating cold-start cost.
- **Web fonts**: `/opt/fonts-web/noto-sans-jp/{regular,bold}.woff2` (downloaded at build time from `@fontsource/noto-sans-jp@5`). Apps reference them via `bslib::font_face(src = "url('/_fonts/noto-sans-jp/...')...")`. Removes the Google Fonts CDN fetch that hangs/fails in offline EMR environments. Browser fallbacks: Yu Gothic / Meiryo / Hiragino.
- **Logging**: `preserve_logs true` keeps logs persisted, `logrotate` config cleans up before disk fills.
- **Cron**: cron daemon auto-starts under s6 so user crontabs (incl. logrotate trigger via `/etc/cron.daily/logrotate` at 6:25 AM and Shiny warm-up curl) run without manual `service cron start`.

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

- **2026/05/19 (follow-up)**: bsicons added; Posit Assistant disabled (`posit-assistant-enabled=0`) so offline RStudio sessions don't hit `cdn.posit.co`; Shiny Server warm-keep tuning baked into `shiny-server.conf` (idle 2h / init 2min / `simple_scheduler 100`); Noto Sans JP woff2 fonts baked at `/opt/fonts-web/` and served via `location /_fonts/` (eliminates Google Fonts CDN fetch); `logrotate` package + fixed config for per-session shiny logs; cron daemon auto-started under s6 + cont-init.d script to install user crontabs; `duckdb-data` named volume removed from docker-compose (data lives under `srv/` instead); RStudio host port shifted to 50004
- **2026/05/19**: R 4.5.3, merged Shiny Server in, removed CIFS mount, PPM date-pinned, added 15 packages for the dept-level inpatient-revenue project, Microsoft ODBC signed-by fix, Claude Code/Gemini in final layer, HEALTHCHECK, image tag `20260519`
- **2025/11/22**: Added LibreOffice installation for document handling
- **2025/10/19**: Added Claude Code CLI and Gemini CLI support
- **2025/09/17**: Updated to new image tag with latest configuration
- **2024/10/18**: Updated all R packages to latest versions to fix patchwork 1.1.3 compatibility issue
- **2024/09/07**: Added DuckDB for analytical workloads
- **2024/09/03**: Added cron and user00
- **2024/05/03**: Added packages introduced at Tokyo.R 2024/4/20, updated RStudio settings
