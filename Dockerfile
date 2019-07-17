FROM puckel/docker-airflow:1.10.3

ARG GITHUB_PAT

ENV JULIA_PATH /usr/local/julia
ENV PATH $JULIA_PATH/bin:$PATH
ENV PATH=$PATH:/opt/TinyTeX/bin/x86_64-linux/
ENV PATH="/opt/mssql-tools/bin:${PATH}"

USER root

# Add system libs & minor fix
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    unixodbc-dev \
    apt-transport-https \
    curl \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/ \
  && groupadd --gid 119 docker \
  && usermod -aG docker airflow \
  # fix jdk https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=863199
  && mkdir -p /usr/share/man/man1 \
  && mkdir tmp/


# Install Julia
RUN curl -fL -o julia.tar.gz "https://julialang-s3.julialang.org/bin/linux/x64/1.1/julia-1.1.0-linux-x86_64.tar.gz"



# Add python modules
RUN pip3 install -r https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/basic-python-module.txt \
  && pip3 install -r https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/python-module-for-airflow.txt







# Install R
## Copy from https://raw.githubusercontent.com/rocker-org/rocker-versioned/master/r-ver/Dockerfile

ARG R_VERSION
ARG BUILD_DATE
ENV R_VERSION=${R_VERSION:-3.6.1} \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    TERM=xterm

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    bash-completion \
    ca-certificates \
    file \
    fonts-texgyre \
    g++ \
    gfortran \
    gsfonts \
    libblas-dev \
    libbz2-1.0 \
    libcurl3 \
    libicu57 \
    libjpeg62-turbo \
    libopenblas-dev \
    libpangocairo-1.0-0 \
    libpcre3 \
    libpng16-16 \
    libreadline7 \
    libtiff5 \
    liblzma5 \
    locales \
    make \
    unzip \
    zip \
    zlib1g \
  && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
  && locale-gen en_US.utf8 \
  && /usr/sbin/update-locale LANG=en_US.UTF-8 \
  && BUILDDEPS="curl \
    default-jdk \
    libbz2-dev \
    libcairo2-dev \
    libcurl4-openssl-dev \
    libpango1.0-dev \
    libjpeg-dev \
    libicu-dev \
    libpcre3-dev \
    libpng-dev \
    libreadline-dev \
    libtiff5-dev \
    liblzma-dev \
    libx11-dev \
    libxt-dev \
    perl \
    tcl8.6-dev \
    tk8.6-dev \
    texinfo \
    texlive-extra-utils \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-latex-recommended \
    x11proto-core-dev \
    xauth \
    xfonts-base \
    xvfb \
    zlib1g-dev" \
  && apt-get install -y --no-install-recommends $BUILDDEPS \
  && cd tmp/ \
  ## Download source code
  && curl -O https://cran.r-project.org/src/base/R-3/R-${R_VERSION}.tar.gz \
  ## Extract source code
  && tar -xf R-${R_VERSION}.tar.gz \
  && cd R-${R_VERSION} \
  ## Set compiler flags
  && R_PAPERSIZE=letter \
    R_BATCHSAVE="--no-save --no-restore" \
    R_BROWSER=xdg-open \
    PAGER=/usr/bin/pager \
    PERL=/usr/bin/perl \
    R_UNZIPCMD=/usr/bin/unzip \
    R_ZIPCMD=/usr/bin/zip \
    R_PRINTCMD=/usr/bin/lpr \
    LIBnn=lib \
    AWK=/usr/bin/awk \
    CFLAGS="-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 -g" \
    CXXFLAGS="-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 -g" \
  ## Configure options
  ./configure --enable-R-shlib \
               --enable-memory-profiling \
               --with-readline \
               --with-blas \
               --with-tcltk \
               --disable-nls \
               --with-recommended-packages \
  ## Build and install
  && make \
  && make install \
  ## Add a default CRAN mirror
  && echo "options(repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl')" >> /usr/local/lib/R/etc/Rprofile.site \
  ## Add a library directory (for user-installed packages)
  && mkdir -p /usr/local/lib/R/site-library \
  && chown root:staff /usr/local/lib/R/site-library \
  && chmod g+wx /usr/local/lib/R/site-library \
  ## Fix library path
  && echo "R_LIBS_USER='/usr/local/lib/R/site-library'" >> /usr/local/lib/R/etc/Renviron \
  && echo "R_LIBS=\${R_LIBS-'/usr/local/lib/R/site-library:/usr/local/lib/R/library:/usr/lib/R/library'}" >> /usr/local/lib/R/etc/Renviron \
  ## install packages from date-locked MRAN snapshot of CRAN
  && [ -z "$BUILD_DATE" ] && BUILD_DATE=$(TZ="America/Los_Angeles" date -I) || true \
  && MRAN=https://mran.microsoft.com/snapshot/${BUILD_DATE} \
  && echo MRAN=$MRAN >> /etc/environment \
  && export MRAN=$MRAN \
  && echo "options(repos = c(CRAN='$MRAN'), download.file.method = 'libcurl')" >> /usr/local/lib/R/etc/Rprofile.site \
  ## Use littler installation scripts
  && Rscript -e "install.packages(c('littler', 'docopt'), repo = '$MRAN')" \
  && ln -s /usr/local/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r \
  && ln -s /usr/local/lib/R/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
  && ln -s /usr/local/lib/R/site-library/littler/bin/r /usr/local/bin/r \
  ## Clean up from R source install
  && cd / \
  && rm -rf /tmp/* \
  && apt-get remove --purge -y $BUILDDEPS \
  && apt-get autoremove -y \
  && apt-get autoclean -y \
  && rm -rf /var/lib/apt/lists/*







# copy from https://raw.githubusercontent.com/rocker-org/rocker-versioned/master/rstudio/Dockerfile

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
  && wget -O libssl1.0.0.deb http://ftp.debian.org/debian/pool/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u8_amd64.deb \
  && dpkg -i libssl1.0.0.deb \
  && rm libssl1.0.0.deb \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/






# copy from https://raw.githubusercontent.com/rocker-org/rocker-versioned/master/tidyverse/Dockerfile
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    libxml2-dev \
    libcairo2-dev \
    libsqlite3-dev \
    libmariadbd-dev \
    libmariadb-client-lgpl-dev \
    libpq-dev \
    libssh2-1-dev \
    unixodbc-dev \
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
  




# install SQL Server drivers and tools
### https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server    
### https://github.com/Microsoft/mssql-docker/blob/master/linux/mssql-tools/Dockerfile

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
  && curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list \
  && apt-get update \
  && ACCEPT_EULA=Y apt-get -y install msodbcsql17 \
  && ACCEPT_EULA=Y apt-get -y install mssql-tools





USER airflow