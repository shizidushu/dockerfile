FROM rocker/shiny


RUN Rscript -e "install.packages('devtools')" \
  && Rscript -e "devtools::source_url('https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/r-pkgs.txt')"