FROM shizidushu/complete-r

ARG GITHUB_PAT



RUN Rscript -e "if (!require(devtools)) install.packages('devtools')" \
  && Rscript -e "devtools::source_url('https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/r-pkgs-dev.R')" \
  && rm -rf /tmp/Rtmp*