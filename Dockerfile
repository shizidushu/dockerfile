FROM shizidushu/complete-r

ARG GITHUB_PAT

RUN Rscript -e "install.packages('devtools')" \
  && Rscript -e "devtools::source_url('https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/r-pkgs-for-plumber.txt')" \
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