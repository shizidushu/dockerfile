FROM shizidushu/complete-r

# Install shiny server
RUN wget --no-verbose https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "version.txt"\
  && VERSION=$(cat version.txt) \
  && wget --no-verbose "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb \
  && gdebi -n ss-latest.deb \
  && rm -f version.txt ss-latest.deb \
  && R -e "install.packages(c('shiny', 'rmarkdown'), repos='https://cran.rstudio.com/')" \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


RUN Rscript -e "install.packages('devtools')" \
  && Rscript -e "devtools::source_url('https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/r-pkgs-for-shiny.txt')"

RUN cd /usr/bin/ \
  && wget https://raw.githubusercontent.com/rocker-org/shiny/master/shiny-server.sh \
  && chmod 700 shiny-server.sh \
  && cd /


EXPOSE 3838

CMD ["/usr/bin/shiny-server.sh"]