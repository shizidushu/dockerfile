FROM shizidushu/complete-r

ARG GITHUB_PAT

# Install shiny server
RUN wget --no-verbose https://download3.rstudio.org/ubuntu-14.04/x86_64/VERSION -O "version.txt" \
  && VERSION=$(cat version.txt) \
  && wget --no-verbose "https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb \
  && gdebi -n ss-latest.deb \
  && rm -f version.txt ss-latest.deb \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# RUN Rscript -e "if (!require(devtools)) install.packages('devtools')" \
#  && Rscript -e "devtools::source_url('https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/r-pkgs.R')" \
#  && Rscript -e "devtools::source_url('https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/r-pkgs-dev.R')" \
#  && rm -rf /tmp/Rtmp*

RUN Rscript -e "devtools::source_url('https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/r-pkgs-shiny.R')"

RUN cd /usr/bin/ \
  && wget https://raw.githubusercontent.com/rocker-org/shiny/master/shiny-server.sh \
  && chmod 700 shiny-server.sh \
  && cd /


EXPOSE 3838

CMD ["/usr/bin/shiny-server.sh"]