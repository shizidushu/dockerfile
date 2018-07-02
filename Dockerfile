FROM rocker/r-ver:latest


RUN apt-get update \
  && apt-get install -y --no-install-recommends \
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
    libnetcdf11  \
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

# Temporarily comment this for a issue of tinytex install
## uses dummy texlive, see FAQ 8: https://yihui.name/tinytex/faq/
## RUN wget "https://travis-bin.yihui.name/texlive-local.deb" \
##   && dpkg -i texlive-local.deb \
##   && Rscript -e "install.packages('devtools')" \
##   && Rscript -e "devtools::source_url('https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/r-pkgs.txt')" \
##   && Rscript -e "tinytex::install_tinytex()" \
##   && Rscript -e "tinytex::tlmgr_install(readr::read_lines('https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/latex-pkgs.txt'))" \
##   && Rscript -e "tinytex::tlmgr_update()" \
##   && rm -rf /tmp/Rtmp*


RUN Rscript -e "install.packages('devtools')" \
  && Rscript -e "devtools::source_url('https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/r-pkgs.txt')" \
  && rm -rf /tmp/Rtmp*

## copy from  https://github.com/rocker-org/rocker-versioned/blob/master/rstudio/Dockerfile
RUN echo '\n\
    \n# Configure httr to perform out-of-band authentication if HTTR_LOCALHOST \
    \n# is not set since a redirect to localhost may not work depending upon \
    \n# where this Docker container is running. \
    \nif(is.na(Sys.getenv("HTTR_LOCALHOST", unset=NA))) { \
    \n  options(httr_oob_default = TRUE) \
    \n}' >> /usr/local/lib/R/etc/Rprofile.site \
  && rm -rf /tmp/Rtmp* 


EXPOSE 8000

## run R plumber with the last supplied CMD as supplied file
ENTRYPOINT ["R", "-e", "pr <- plumber::plumb(rev(commandArgs())[1]); pr$run(host='0.0.0.0', port=8000, swagger=TRUE)"]

CMD ["/usr/local/lib/R/site-library/plumber/examples/04-mean-sum/plumber.R"]