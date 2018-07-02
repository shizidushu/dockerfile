FROM rocker/r-ver:latest

# Install dependencies and Download and install shiny server
RUN apt-get update && apt-get install -y \
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
    odbc-postgresql \
    unixodbc-dev \
  && R CMD javareconf \
  && wget --no-verbose https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "version.txt"\
  && VERSION=$(cat version.txt) \
  && wget --no-verbose "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb && \
    R -e "install.packages(c('shiny', 'rmarkdown'), repos='https://cran.rstudio.com/')" && \
    cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/ && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


RUN Rscript -e "install.packages('devtools')" \
  && Rscript -e "devtools::source_url('https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/r-pkgs.txt')"

EXPOSE 3838

ADD https://raw.githubusercontent.com/rocker-org/shiny/master/shiny-server.sh /usr/bin/shiny-server.sh

CMD ["/usr/bin/shiny-server.sh"]