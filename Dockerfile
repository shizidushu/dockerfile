FROM rocker/shiny

RUN apt-get update \
  && apt-get install -y \
    autoconf \
    automake \
    apt-transport-https \
    cron \
    curl \
    debconf-utils \
    default-jdk \
    fonts-roboto \
    fonts-wqy-zenhei \
    freetds-bin  \
    freetds-common  \
    freetds-dev \
    ghostscript \
    git \
    gnupg2 \
    less \
    libapparmor1 \
    libbz2-dev \
    libcairo2-dev \
    libdigest-hmac-perl \
    libedit2 \
    libfreetype6-dev \
    libgl1-mesa-dev  \
    libglpk-dev \
    libglu1-mesa-dev \
    libgmp-dev  \
    libgmp10-dev \
    libgmp3-dev \
    libgsl0-dev \
    libhiredis-dev \
    libhunspell-dev \
    libicu-dev \
    libjq-dev \
    libmagick++-dev \
    libnetcdf-dev  \
    libpq-dev \
    librdf0-dev \
    libsecret-1-dev \
    libsndfile1  \
    libsndfile1-dev \
    libssh2-1-dev \
    libssl-dev \
    libtiff-dev \
    libtool \
    libudunits2-dev \
    libv8-dev \
    m4 \
    netcdf-bin \
    odbc-postgresql \
    pandoc \
    psmisc \
    python-setuptools \
    qpdf \
    ssh \
    sudo \
    tdsodbc  \
    unixodbc-dev \
    vim \
    wget \
    libcurl3 \
  && R CMD javareconf \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
  && curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list \
  && apt-get update \
  && ACCEPT_EULA=Y apt-get -y install msodbcsql17 \
  && ACCEPT_EULA=Y apt-get -y install mssql-tools \
  && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile \
  && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc \
  && /bin/bash -c "source ~/.bashrc" \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/



RUN Rscript -e "install.packages('devtools')" \
  && Rscript -e "devtools::source_url('https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/r-pkgs.txt')"