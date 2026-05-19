# https://github.com/rocker-org/rocker-versioned2
FROM rocker/geospatial:4.5.3

# OS環境（rockerはdebianベース）に日本語ロケールを追加し切り替え
ENV LANG=ja_JP.UTF-8 \
    LC_ALL=ja_JP.UTF-8 \
    PATH="${PATH}:/opt/mssql-tools/bin" \
    NODE_PATH=/usr/lib/node_modules

# System packages installation in single layer
RUN sed -i '$d' /etc/locale.gen && \  
    echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen ja_JP.UTF-8 && \
    /usr/sbin/update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja" && \
    /bin/bash -c "source /etc/default/locale" && \
    ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    apt-get update && \
    apt-get install -y \
        fonts-ipaexfont \
        fonts-noto-cjk \
        cron \
        wget \
        unzip \
        curl \
        gnupg \
        xdg-utils \
        unixodbc-dev && \
    # Microsoft ODBC Driver installation (Ubuntu 24.04: prod.list already references /usr/share/keyrings/microsoft-prod.gpg)
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg && \
    curl -fsSL https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list -o /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql17 mssql-tools && \
    # Node.js installation
    apt-get remove -y libnode-dev nodejs npm && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y nodejs && \
    # GitHub CLI installation
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y gh && \
    # DuckDB installation
    wget https://github.com/duckdb/duckdb/releases/download/v0.10.2/duckdb_cli-linux-amd64.zip && \
    unzip duckdb_cli-linux-amd64.zip -d /usr/local/bin && \
    rm duckdb_cli-linux-amd64.zip && \
    # Cleanup
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt && \
    # R repos: PPM date-pinned binary packages (Ubuntu noble) for reproducibility
    echo 'options(repos = c(CRAN = "https://packagemanager.posit.co/cran/__linux__/noble/2026-05-18"))' >> /usr/local/lib/R/etc/Rprofile.site && \
    echo 'options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])))' >> /usr/local/lib/R/etc/Rprofile.site && \
    echo "copilot-enabled=1" >> /etc/rstudio/rsession.conf && \
    cd /home/rstudio && \
    mkdir -p .cache/R/renv .TinyTeX .gemini && \
    chown -R rstudio:rstudio /home/rstudio && \
    chmod -R 777 /home/rstudio && \
    chmod -R 755 /home/rstudio/.gemini

# remotes is required by installGithub.r; rocker/geospatial:4.5.3 no longer pre-installs it
RUN install2.r --error --skipinstalled --deps TRUE --ncpu -1 remotes \
    && rm -rf /tmp/downloaded_packages/

# Install R packages from GitHub
RUN installGithub.r \
    davidgohel/gdtools \
    davidgohel/officer \
    davidgohel/flextable \
    uribo/jpmesh \
    uribo/jpndistrict \
    mlr-org/shinyMlr \
    ropensci/rnaturalearthhires \
    jthomasmock/gtExtras \
    coolbutuseless/ggpattern && \
    rm -rf /tmp/downloaded_packages/

# Install R packages in consolidated layers
RUN install2.r --error --skipinstalled --deps TRUE --ncpu -1 \
    renv here tidylog DBI RPostgreSQL odbc pacman rio \
    openxlsx remotes linelist naniar janitor gtsummary \
    gganimate sf tmap OpenStreetMap spdep rmarkdown \
    reportfactory flexdashboard shiny knitr DT gt \
    huxtable gsDesign shinydashboard formattable \
    ggplotgui ggraptR mice pool Rmisc celestial \
    NipponMap GGally ggmap ggmosaic Hmisc kableExtra MASS \
    && rm -rf /tmp/downloaded_packages/

RUN install2.r --error --skipinstalled --deps TRUE --ncpu -1 \
    rJava summarytools zipangu coin sessioninfo styler \
    sqldf Matching MatchIt WeightIt epiR cobalt \
    glmnet glmnetUtils rpart partykit pROC caret \
    Amelia tibbletime xts forecast rstan survival survminer \
    && rm -rf /tmp/downloaded_packages/

RUN install2.r --error --skipinstalled --deps TRUE --ncpu -1 \
    broom lme4 lmerTest gee geepack emmeans interactions \
    forestplot boot logistf ggsci ggfortify ggbeeswarm \
    ggpubr lubridate miniCRAN rjson gghighlight \
    ggThemeAssist targets revealjs docxtractr cronR export \
    && rm -rf /tmp/downloaded_packages/

RUN install2.r --error --skipinstalled --deps TRUE --ncpu -1 \
    ragg svglite fpCompare devEMF xgboost rpivotTable \
    DataExplorer skimr XLConnect mlr terra spData \
    mapview osrm movecost SnowballC text2vec kernlab \
    prismatic rstatix lmtest easystats parameters see \
    && rm -rf /tmp/downloaded_packages/

RUN install2.r --error --skipinstalled --deps TRUE --ncpu -1 \
    cowplot patchwork RColorBrewer ggridges ggrepel \
    ggnewscale DiagrammeR plotly haven esquisse tableone \
    RMySQL jsonlite checkpoint curl doParallel reshape2 \
    moments greybox muhaz rpart.plot ranger proxy \
    sparkline corrr psych PerformanceAnalytics rmapshaper leaflet \
    && rm -rf /tmp/downloaded_packages/

RUN install2.r --error --skipinstalled --deps TRUE --ncpu -1 \
    ggExtra ghibli latex2exp rnaturalearth rnaturalearthdata \
    dagitty ggdag ggbump ggalluvial treemapify golem \
    rdrobust rdd S7 felp colorBlindness patternplot \
    tidymodels duckdb duckplyr \
    && rm -rf /tmp/downloaded_packages/

# Install LibreOffice
RUN apt-get update && apt-get install -y libreoffice && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN install2.r --error --skipinstalled --deps TRUE --ncpu -1 \
    rsvg \
    ggbreak \
    && rm -rf /tmp/downloaded_packages/

# Additional packages required by srv/mpd/20260403_科別入院診療実績 project
RUN install2.r --error --skipinstalled --deps TRUE --ncpu -1 \
    arrow Polychrome future openxlsx2 reactable \
    shinyWidgets shinybusy shinycssloaders shinymanager shinytest2 \
    sortable stringdist tidyxl waiter writexl \
    && rm -rf /tmp/downloaded_packages/

# Install Shiny Server (coexists with RStudio Server under rocker's s6-overlay init)
RUN /rocker_scripts/install_shiny_server.sh

# Final configuration

# Copy configuration files and setup users
COPY --chown=rstudio:rstudio rstudio-prefs_mysettings.json /home/rstudio/.config/rstudio/rstudio-prefs.json
COPY --chown=rstudio:rstudio dotRprofile /home/rstudio/.Rprofile
COPY add_users.sh /home/rstudio/add_users.sh

RUN chmod +x /home/rstudio/add_users.sh && \
    /home/rstudio/add_users.sh user00 user01 user02 user03 user04 user05 user06 user07 user08 user09 user10 && \
    /home/rstudio/add_users.sh user11 user12 user13 user14 user15 user16 user17 user18 user19 user20 && \
    chmod -R 777 /home

# Claude Code and Gemini CLI — placed in the final layer so iterations
# that bump only these (e.g. on the online dev PC) reuse all earlier caches.
RUN npm install -g @anthropic-ai/claude-code @google/gemini-cli

# Healthcheck — RStudio Server returns this HTML page without authentication
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s \
    CMD curl -fsS http://localhost:8787/unsupported_browser.htm > /dev/null || exit 1
