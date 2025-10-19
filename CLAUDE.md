# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Docker-based R/RStudio Server environment (R 4.3.2) designed for Japanese data scientists. Provides comprehensive environment with 100+ pre-installed R packages for statistical analysis, machine learning, and data visualization.

## Key Commands

### Build and Run
```bash
# Create required volumes and network (first time only)
docker volume create renv
docker network create pgnetwork

# Build Docker image
docker-compose build

# Start container
docker-compose up -d

# Stop container
docker-compose down
```

### Docker Image Management
```bash
# Pull latest image
docker pull nujabec/myrocker:20250917

# Push to Docker Hub
docker login
docker push nujabec/myrocker:20250917

# Export for offline environments
docker save nujabec/myrocker:20250917 > myrocker_20250917.tar

# Import in offline environment
docker load < myrocker_20250917.tar
```

## Architecture

### Container Configuration
- **Base Image**: `rocker/geospatial:4.3.2` - R environment with geospatial capabilities
- **Port**: 50003 (RStudio Server)
- **Network**: Connected to `pgnetwork` for PostgreSQL integration
- **Users**: Multi-user setup with 51 users (user00-user50)
- **Locale**: Japanese (ja_JP.UTF-8) with CJK font support
- **CIFS Mount**: Network share at `//200.200.17.40/scan/3F_診療情報管理室/inayoshi`

### Key Components
1. **docker-compose.yml**: Container orchestration with volume mounts:
   - `/home/rstudio/srv/` → `../srv/`
   - `renv` volume → `/home/rstudio/.cache/R/renv`
   - `samba-mpd` CIFS mount → `/home/rstudio/mpd/`

2. **docker/Dockerfile**: Main build configuration:
   - Japanese locale and timezone (Asia/Tokyo) setup
   - GitHub Copilot enabled for RStudio
   - Microsoft ODBC drivers for SQL Server
   - Pre-installed large R package collection
   - Multi-user environment setup
   - Node.js and Claude Code CLI installation

3. **docker/add_users.sh**: Creates 51 user accounts with consistent configuration

### Pre-installed Package Categories
- **Core**: tidyverse ecosystem, data.table, arrow
- **Database**: RPostgreSQL, RMySQL, odbc, DuckDB
- **ML/Statistics**: xgboost, glmnet, caret, survival, lme4
- **Visualization**: plotly, gganimate, gt, flextable
- **Japanese-specific**: zipangu, NipponMap, jpndistrict
- **Geospatial**: sf, tmap, terra, leaflet

## Development Notes

- Optimized for offline use with pre-installed packages
- RStudio configuration pre-set via `docker/rstudio-prefs_mysettings.json`
- Custom R startup settings in `docker/dotRprofile`
- CRAN mirror set to Tokyo (https://cran.ism.ac.jp/)
- Includes cron for scheduled tasks
- SQL Server connectivity via Microsoft ODBC Driver 17

## Recent Updates

- **2025/10/19**: Added Claude Code CLI and Gemini CLI support
- **2025/09/17**: Updated to new image tag with latest configuration
- **2024/10/18**: Updated all R packages to latest versions to fix patchwork 1.1.3 compatibility issue
- **2024/09/07**: Added DuckDB for analytical workloads
- **2024/09/03**: Added cron and user00
- **2024/05/03**: Added packages introduced at Tokyo.R 2024/4/20, updated RStudio settings