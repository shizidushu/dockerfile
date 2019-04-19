FROM rocker/verse

ARG GITHUB_PAT


ENV LESSCHARSET=utf-8
ENV JULIA_PATH /usr/local/julia
ENV PATH $JULIA_PATH/bin:$PATH
ENV PATH="/opt/mssql-tools/bin:${PATH}"

# add sys lib
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    apt-transport-https \
    curl \
    gnupg2 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/


# Add python

RUN apt-get update \
  && apt-get install -y \
    libpython3-dev \
    python3-setuptools \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/ \
  && easy_install3 pip \
  && pip3 install -U pip setuptools wheel \
  && pip3 install -r https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/basic-python-module.txt






# Install Julia
RUN curl -fL -o julia.tar.gz "https://julialang-s3.julialang.org/bin/linux/x64/1.1/julia-1.1.0-linux-x86_64.tar.gz" \
  && mkdir "$JULIA_PATH" \
  && tar -xzf julia.tar.gz -C "$JULIA_PATH" --strip-components 1 \
  && rm julia.tar.gz \
  && julia --version \
  && echo "options(JULIA_HOME='$JULIA_PATH/bin/')" >> /usr/local/lib/R/etc/Rprofile.site





# Fix package dependency & git chinese character path
## http://blog.csdn.net/gxp/article/details/26563579

RUN git config --global core.quotepath false \
    && git config --global gui.encoding utf-8 \
    && git config --global i18n.commit.encoding utf-8 \
    && git config --global i18n.logoutputencoding utf-8





# install SQL Server drivers and tools
### https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server    
### https://github.com/Microsoft/mssql-docker/blob/master/linux/mssql-tools/Dockerfile

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
  && curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list \
  && apt-get update \
  && ACCEPT_EULA=Y apt-get -y install msodbcsql17 \
  && ACCEPT_EULA=Y apt-get -y install mssql-tools


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


## Add cron to s6-init system
RUN mkdir -p /etc/services.d/cron \
  && echo '#!/bin/sh \
      \n exec cron -f' \
      > /etc/services.d/cron/run


USER rstudio
## Install R packages and latex packages
RUN Rscript -e "if (!require(devtools)) install.packages('devtools')" \
  && Rscript -e "devtools::source_url('https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/r-pkgs.R')" \
  && Rscript -e "devtools::source_url('https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/r-pkgs-rstudio.R')" \
  && Rscript -e "tinytex::tlmgr_install(readr::read_lines('https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/latex-pkgs.txt'))" \
  && Rscript -e "tinytex::tlmgr_update()" \
  && rm -rf /tmp/Rtmp*
USER root
