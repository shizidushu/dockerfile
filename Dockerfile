FROM rocker/verse

ARG GITHUB_PAT

## Install system package that r packages depends on
RUN apt-get update && apt-get install -y \
    software-properties-common \
    apt-transport-https \
    bzip2 \
    cron \
    curl \
    fonts-wqy-zenhei \
    gnupg2 \
    libglu1-mesa-dev \
    libhiredis-dev \
    libudunits2-dev \
    odbc-postgresql \
    libgdal-dev \
    firefox-esr \
  && apt-get autoremove -y \
  && apt-get autoclean -y \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*



## Fix package dependency & git chinese character path
### http://blog.csdn.net/gxp/article/details/26563579

RUN git config --global core.quotepath false \
    && git config --global gui.encoding utf-8 \
    && git config --global i18n.commit.encoding utf-8 \
    && git config --global i18n.logoutputencoding utf-8
ENV LESSCHARSET=utf-8


## install SQL Server drivers and tools
### https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server    
### https://github.com/Microsoft/mssql-docker/blob/master/linux/mssql-tools/Dockerfile

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
  && curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list \
  && apt-get update \
  && ACCEPT_EULA=Y apt-get -y install msodbcsql17 \
  && ACCEPT_EULA=Y apt-get -y install mssql-tools
ENV PATH="/opt/mssql-tools/bin:${PATH}"


## Add cron to s6-init system
RUN mkdir -p /etc/services.d/cron \
  && echo '#!/bin/sh \
      \n exec cron -f' \
      > /etc/services.d/cron/run 

USER rstudio
## Install R packages and latex packages
RUN Rscript -e "if (!require(devtools)) install.packages('devtools')" \
  && Rscript -e "devtools::source_url('https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/r-pkgs.R')" \
  && Rscript -e "tinytex::tlmgr_install(readr::read_lines('https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/latex-pkgs.txt'))" \
  && Rscript -e "tinytex::tlmgr_update()" \
  && rm -rf /tmp/Rtmp*
USER root
