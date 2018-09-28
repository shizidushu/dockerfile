FROM rocker/r-ver:latest

## Install system package that r packages depends on
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    sudo \
    curl \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    wget \
    default-jdk \
    fonts-wqy-zenhei \
    git \
    gnupg2 \
    libgl1-mesa-dev  \
    libhiredis-dev \
    libmagick++-dev \
    libpq-dev \
    libssl-dev \
    tdsodbc \
    libsqliteodbc \
    odbc-postgresql \
    unixodbc \
    unixodbc-dev \
    xtail \
    libudunits2-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    libv8-dev \
    libjq-dev \
    libprotobuf-dev \
    protobuf-compiler \
    libssl-dev \
  && R CMD javareconf \
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

# https://github.com/rocker-org/rocker-versioned/blob/master/verse/Dockerfile
# Use tinytex for LaTeX installation
## change the directory's owner to be root and add it to group staff
RUN wget "https://travis-bin.yihui.name/texlive-local.deb" \
  && dpkg -i texlive-local.deb \
  && rm texlive-local.deb \
  && wget -qO- \
    "https://github.com/yihui/tinytex/raw/master/tools/install-unx.sh" | \
    sh -s - --admin --no-path \
  && mv ~/.TinyTeX /opt/TinyTeX \
  && /opt/TinyTeX/bin/*/tlmgr path add \
  && tlmgr install metafont mfware inconsolata tex ae parskip listings \
  && tlmgr path add \
  && Rscript -e "source('https://install-github.me/yihui/tinytex'); tinytex::r_texmf()" \
  && chown -R root:staff /opt/TinyTeX \
  && chmod -R g+w /opt/TinyTeX \
  && chmod -R g+wx /opt/TinyTeX/bin
