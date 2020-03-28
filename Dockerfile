FROM rocker/r-ver:latest

ARG GITHUB_PAT

ENV LESSCHARSET=utf-8
ENV JULIA_PATH /usr/local/julia
ENV PATH $JULIA_PATH/bin:$PATH
ENV PATH=$PATH:/opt/TinyTeX/bin/x86_64-linux/
ENV PATH="/opt/mssql-tools/bin:${PATH}"



# add sys lib
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    apt-transport-https \
    curl \
    gnupg2 \
    libsodium-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/
  


# copy from https://github.com/rocker-org/rocker-versioned/blob/master/rstudio/3.6.1.Dockerfile

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    file \
    git \
    libapparmor1 \
    libcurl4-openssl-dev \
    libedit2 \
    libssl-dev \
    lsb-release \
    psmisc \
    procps \
    python-setuptools \
    sudo \
    wget \
    libclang-dev \
    libclang-3.8-dev \
    libobjc-6-dev \
    libclang1-3.8 \
    libclang-common-3.8-dev \
    libllvm3.8 \
    libobjc4 \
    libgc1c2 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/






# copy from https://github.com/rocker-org/rocker-versioned/blob/master/tidyverse/3.6.1.Dockerfile
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
  libxml2-dev \
  libcairo2-dev \
  libsqlite3-dev \
  libmariadbd-dev \
  libmariadb-client-lgpl-dev \
  libpq-dev \
  libssh2-1-dev \
  unixodbc-dev \
  libsasl2-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/






# From https://raw.githubusercontent.com/rocker-org/rocker-versioned/master/verse/Dockerfile

## Add LaTeX, rticles and bookdown support
RUN wget "https://travis-bin.yihui.name/texlive-local.deb" \
  && dpkg -i texlive-local.deb \
  && rm texlive-local.deb \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ## for some package installs
    cmake \
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
  && if /opt/TinyTeX/bin/*/tex -v | grep -q 'TeX Live 2018'; then \
      ## Patch the Perl modules in the frozen TeX Live 2018 snapshot with the newer
      ## version available for the installer in tlnet/tlpkg/TeXLive, to include the
      ## fix described in https://github.com/yihui/tinytex/issues/77#issuecomment-466584510
      ## as discussed in https://www.preining.info/blog/2019/09/tex-services-at-texlive-info/#comments
      wget -P /tmp/ ${CTAN_REPO}/install-tl-unx.tar.gz \
      && tar -xzf /tmp/install-tl-unx.tar.gz -C /tmp/ \
      && cp -Tr /tmp/install-tl-*/tlpkg/TeXLive /opt/TinyTeX/tlpkg/TeXLive \
      && rm -r /tmp/install-tl-*; \
    fi \
  && if /opt/TinyTeX/bin/*/tex -v | grep -q 'TeX Live 2016'; then \
      ## Patch error handling of tlmgr path (https://tex.stackexchange.com/a/314079)
      ## in the frozen TeX Live 2016 snapshot by back-porting the corresponding fix:
      ## https://git.texlive.info/texlive/commit/Master/tlpkg/TeXLive/TLUtils.pm?id=69cee5e1ce4b20f6ebb6af77e19d49706a842a3e
      apt-get update && apt-get install -y --no-install-recommends patch \
      && wget -qO- \
         "https://git.texlive.info/texlive/patch/Master/tlpkg/TeXLive/TLUtils.pm?id=69cee5e1ce4b20f6ebb6af77e19d49706a842a3e" | \
         patch -i - /opt/TinyTeX/tlpkg/TeXLive/TLUtils.pm \
      && apt-get remove --purge --autoremove -y patch \
      && apt-get clean && rm -rf /var/lib/apt/lists/; \
    fi \
  && /opt/TinyTeX/bin/*/tlmgr path add \
  && tlmgr install ae inconsolata listings metafont mfware parskip pdfcrop tex \
  && tlmgr path add \
  && Rscript -e "tinytex::r_texmf()" \
  && chown -R root:staff /opt/TinyTeX \
  && chmod -R g+w /opt/TinyTeX \
  && chmod -R g+wx /opt/TinyTeX/bin \
  && echo "PATH=${PATH}" >> /usr/local/lib/R/etc/Renviron \
  && install2.r --error PKI
      





# Add python

RUN apt-get update \
 && apt-get install -y \
   python-pip \
   python3-dev \
   python3-pip \
   python3-venv \
   libpython3-dev \
   python3-setuptools \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/ \
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
