# https://github.com/rocker-org/rocker-versioned2
FROM rocker/geospatial:4.3.2

# OS環境（rockerはdebianベース）に日本語ロケールを追加し切り替え
ENV LANG ja_JP.UTF-8
ENV LC_ALL ja_JP.UTF-8

# Setting Japanese locale
# Enable copilot
RUN sed -i '$d' /etc/locale.gen && \  
    echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen ja_JP.UTF-8 && \
    /usr/sbin/update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja" && \
    /bin/bash -c "source /etc/default/locale" && \
    ln -sf  /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    apt-get update && apt-get install -y fonts-ipaexfont fonts-noto-cjk && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    R -e "options(repos = c(CRAN = 'https://cran.ism.ac.jp/'))" && \
    echo "copilot-enabled=1" >> /etc/rstudio/rsession.conf && \
    cd /home/rstudio && mkdir .cache .cache/R .cache/R/renv .TinyTeX && \
    chown -R rstudio:rstudio /home/rstudio && \
    chmod -R 777 /home/rstudio

# Inastall R packages from GitHub
RUN installGithub.r \
    davidgohel/gdtools \
    davidgohel/officer \
    davidgohel/flextable \
    uribo/jpmesh \
    uribo/jpndistrict \
    mlr-org/shinyMlr && \
    rm -rf /tmp/downloaded_packages/ 

# Install R packages
RUN install2.r --error --skipinstalled --deps TRUE --ncpu -1 \
    renv \
    here \
    && rm -rf /tmp/downloaded_packages/

RUN install2.r --error --skipinstalled --deps TRUE --ncpu -1 \
    tidylog \
    DBI \
    RPostgreSQL \
    odbc \
    pacman \
    rio \
    && rm -rf /tmp/downloaded_packages/

RUN install2.r --error --skipinstalled --deps TRUE --ncpu -1 \
    openxlsx \
    renv \
    remotes \
    linelist \
    naniar \
    janitor \
    gtsummary \
    && rm -rf /tmp/downloaded_packages/

RUN install2.r --error --skipinstalled --deps TRUE --ncpu -1 \
    gganimate \
    sf \
    tmap \
    OpenStreetMap \
    spdep \
    rmarkdown \
    reportfactory \
    flexdashboard \
    shiny \
    knitr \
    DT \
    gt \
    huxtable \
    gsDesign \
    shinydashboard \
    formattable \
    ggplotgui \
    ggraptR \
    && rm -rf /tmp/downloaded_packages/


RUN install2.r --error --skipinstalled --deps TRUE --ncpu -1 \
    mice \
    pool \
    Rmisc \
    celestial \
    NipponMap \
    GGally \
    ggmap \
    ggmosaic \
    Hmisc \
    kableExtra \
    MASS \
    && rm -rf /tmp/downloaded_packages/


RUN install2.r --error --skipinstalled --deps TRUE --ncpu -1 \
    rJava \
    summarytools \
    zipangu \
    coin \
    sessioninfo \
    styler \
    sqldf \
    Matching \
    MatchIt \
    WeightIt \
    epiR \
    cobalt \
    && rm -rf /tmp/downloaded_packages/

RUN install2.r --error --skipinstalled --deps TRUE --ncpu -1 \
    glmnet \
    glmnetUtils \
    rpart \
    partykit \
    pROC \
    caret \
    Amelia \
    tibbletime \
    xts \
    forecast \
    rstan \
    styler \
    survival \
    survminer \
    && rm -rf /tmp/downloaded_packages/

RUN install2.r --error --skipinstalled --deps TRUE --ncpu -1 \
    broom \
    lme4 \
    lmerTest \
    gee \
    geepack \
    emmeans \
    interactions \
    forestplot \
    boot \
    logistf \
    ggsci \
    ggfortify \
    ggbeeswarm \
    ggpubr \
    lubridate \
    && rm -rf /tmp/downloaded_packages/

RUN install2.r --error --skipinstalled --deps TRUE --ncpu -1 \
    miniCRAN \
    rjson \
    gghighlight \
    ggThemeAssist \
    targets \
    revealjs \
    docxtractr \
    cronR \
    export \
    && rm -rf /tmp/downloaded_packages/

RUN install2.r --error --skipinstalled --deps TRUE --ncpu -1 \
    ragg \
    svglite \
    fpCompare \
    devEMF \
    && rm -rf /tmp/downloaded_packages/

RUN install2.r --error --skipinstalled --deps TRUE --ncpu -1 \
    xgboost \
    && rm -rf /tmp/downloaded_packages/

RUN install2.r --error --skipinstalled --deps TRUE --ncpu -1 \
    rpivotTable \
    DataExplorer \
    skimr \
    XLConnect \
    mlr \
    terra \
    spData \
    mapview \
    osrm \
    movecost \
    && rm -rf /tmp/downloaded_packages/

RUN install2.r --error --skipinstalled --deps TRUE --ncpu -1 \
    SnowballC \
    text2vec \
    kernlab \
    && rm -rf /tmp/downloaded_packages/

RUN install2.r --error --skipinstalled --deps TRUE --ncpu -1 \
    prismatic \
    && rm -rf /tmp/downloaded_packages/

RUN install2.r --error --skipinstalled --deps TRUE --ncpu -1 \
    rstatix \
    broom \
    lmtest \
    easystats \
    && rm -rf /tmp/downloaded_packages/

RUN install2.r --error --skipinstalled --deps TRUE --ncpu -1 \
    parameters \
    see \
    cowplot \
    patchwork \
    RColorBrewer \
    ggridges \
    ggrepel \
    && rm -rf /tmp/downloaded_packages/

RUN install2.r --error --skipinstalled --deps TRUE --ncpu -1 \
    ggnewscale \
    DiagrammeR \
    plotly \
    haven \
    esquisse \
    tableone \
    RMySQL \
    jsonlite \
    checkpoint \
    emmeans \
    curl \
    doParallel \
    reshape2 \
    moments \
    greybox \
    muhaz \
    rpart.plot \
    ranger \
    proxy \
    && rm -rf /tmp/downloaded_packages/

# 20240124 install errorが発生。不要なパッケージなので、削除
# package ‘qlcMatrix’ is not available for this version of R
# RUN install2.r --error --skipinstalled --deps TRUE --ncpu -1 \
#     qlcMatrix \
#     && rm -rf /tmp/downloaded_packages/

# 20240411 sparklineを入れる必要があったので、合わせていくつかpackageを追加
RUN install2.r --error --skipinstalled --deps TRUE --ncpu -1 \
    sparkline \
    corrr \
    psych \
    PerformanceAnalytics \
    rmapshaper \
    leaflet \
    && rm -rf /tmp/downloaded_packages/

# Copy RStudio settings
COPY --chown=rstudio:rstudio rstudio-prefs_mysettings.json /home/rstudio/.config/rstudio/rstudio-prefs.json
COPY --chown=rstudio:rstudio dotRprofile /home/rstudio/.Rprofile

# sqlserverようにMcicrosoft ODBC17のdriverを入れる
RUN curl https://packages.microsoft.com/keys/microsoft.asc | tee /etc/apt/trusted.gpg.d/microsoft.asc \
    # 上のcodeの解説: https://packages.microsoft.com/keys/microsoft.asc からデータを取得し、それを /etc/apt/trusted.gpg.d/microsoft.asc に書き込む
    # teeは、標準入力からデータを受け取り、それを標準出力とファイルに書き込むコマンド
    && curl https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list | tee /etc/apt/sources.list.d/mssql-release.list \
    # 上のcodeの解説: https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list からデータを取得し、それを /etc/apt/sources.list.d/mssql-release.list に書き込む
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql17 \
    && ACCEPT_EULA=Y apt-get install -y mssql-tools \
    && apt-get install -y unixodbc-dev \
    # 上のcodeの解説: ACCEPT_EULA=Y は、msodbcsql17のライセンスに同意するという意味
    && apt-get clean  \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="${PATH}:/opt/mssql-tools/bin"

# Add users
COPY add_users.sh /home/rstudio/add_users.sh
RUN chmod +x /home/rstudio/add_users.sh
RUN /home/rstudio/add_users.sh user01 user02 user03 user04 user05 user06 user07 user08 user09 user10 && \
    /home/rstudio/add_users.sh user11 user12 user13 user14 user15 user16 user17 user18 user19 user20 && \
    /home/rstudio/add_users.sh user21 user22 user23 user24 user25 user26 user27 user28 user29 user30 && \
    /home/rstudio/add_users.sh user31 user32 user33 user34 user35 user36 user37 user38 user39 user40 && \
    /home/rstudio/add_users.sh user41 user42 user43 user44 user45 user46 user47 user48 user49 user50

# homeディレクトリの権限を変更
RUN chmod -R 777 /home

# Install shiny server
RUN /rocker_scripts/install_shiny_server.sh