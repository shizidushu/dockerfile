FROM shizidushu/compact-r

ARG GITHUB_PAT


## Install system package that r packages depends on
RUN apt-get update && apt-get install -y \
    software-properties-common \
    bzip2 \
    ca-certificates \
    cargo \
    dirmngr \
    cron \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libxt-dev \
    fonts-wqy-zenhei \
    libglu1-mesa-dev \
    libgit2-dev \
    gnupg \
    libgl1-mesa-dev  \
    libhiredis-dev \
    tdsodbc \
    libsqliteodbc \
    odbc-postgresql \
    unixodbc \
    xtail \
    libudunits2-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    libjq-dev \
    libprotobuf-dev \
    protobuf-compiler \
    unzip \
    xvfb \
    libxi6 \
    libgconf-2-4 \
  && R CMD javareconf \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/


RUN Rscript -e "if (!require(devtools)) install.packages('devtools')" \
  && Rscript -e "devtools::source_url('https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/r-pkgs.R')" \
  && rm -rf /tmp/Rtmp*
