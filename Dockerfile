FROM rocker/shiny-verse

ARG GITHUB_PAT

ENV JULIA_PATH /usr/local/julia
ENV PATH $JULIA_PATH/bin:$PATH
ENV PATH=$PATH:/opt/TinyTeX/bin/x86_64-linux/
ENV PATH="/opt/mssql-tools/bin:${PATH}"



# add sys lib
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    apt-transport-https \
    curl \
    gnupg2 \
    git \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/
  
  
  

# From https://raw.githubusercontent.com/rocker-org/rocker-versioned/master/verse/Dockerfile
## Add LaTeX support

RUN wget "https://travis-bin.yihui.name/texlive-local.deb" \
  && dpkg -i texlive-local.deb \
  && rm texlive-local.deb \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ## for rJava
    default-jdk \
    ## Nice Google fonts
    fonts-roboto \
    ## used by some base R plots
    ghostscript \
    ## used to build rJava and other packages
    libbz2-dev \
    libicu-dev \
    liblzma-dev \
    ## system dependency of hunspell (devtools)
    libhunspell-dev \
    ## system dependency of hadley/pkgdown
    libmagick++-dev \
    ## rdf, for redland / linked data
    librdf0-dev \
    ## for V8-based javascript wrappers
    libv8-dev \
    ## R CMD Check wants qpdf to check pdf sizes, or throws a Warning
    qpdf \
    ## For building PDF manuals
    texinfo \
    ## for git via ssh key
    ssh \
 ## just because
    less \
    vim \
 ## parallelization
    libzmq3-dev \
    libopenmpi-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/ \
  ## Use tinytex for LaTeX installation
  && install2.r --error tinytex \
  ## Admin-based install of TinyTeX:
  && wget -qO- \
    "https://github.com/yihui/tinytex/raw/master/tools/install-unx.sh" | \
    sh -s - --admin --no-path \
  && mv ~/.TinyTeX /opt/TinyTeX \
  && /opt/TinyTeX/bin/*/tlmgr path add \
  && tlmgr install metafont mfware inconsolata tex ae parskip listings \
  && tlmgr path add \
  && Rscript -e "tinytex::r_texmf()" \
  && chown -R root:staff /opt/TinyTeX \
  && chown -R root:staff /usr/local/lib/R/site-library \
  && chmod -R g+w /opt/TinyTeX \
  && chmod -R g+wx /opt/TinyTeX/bin \
  && echo "PATH=${PATH}" >> /usr/local/lib/R/etc/Renviron \
  && install2.r --error PKI






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
RUN curl -fL -o julia.tar.gz "https://julialang-s3.julialang.org/bin/linux/x64/1.3/julia-1.3.1-linux-x86_64.tar.gz" \
  && mkdir "$JULIA_PATH" \
  && tar -xzf julia.tar.gz -C "$JULIA_PATH" --strip-components 1 \
  && rm julia.tar.gz \
  && julia --version \
  && echo "options(JULIA_HOME='$JULIA_PATH/bin/')" >> /usr/local/lib/R/etc/Rprofile.site






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
    libsodium-dev \
  && R CMD javareconf \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/


RUN Rscript -e "if (!require(devtools)) install.packages('devtools')" \
  && Rscript -e "devtools::source_url('https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/r-pkgs.R')" \
  && Rscript -e "devtools::source_url('https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/r-pkgs-shiny.R')" \
  && rm -rf /tmp/Rtmp*