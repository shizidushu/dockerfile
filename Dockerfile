FROM shizidushu/complete-r

ARG GITHUB_PAT

RUN Rscript -e "if (!require(devtools)) install.packages('devtools')" \
  && Rscript -e "devtools::source_url('https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/r-pkgs-ready.R')" \
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

## Source a R script with the last supplied CMD as supplied file to mount and run plumber
ENTRYPOINT ["Rscript", "-e", "source(rev(commandArgs())[1])"]