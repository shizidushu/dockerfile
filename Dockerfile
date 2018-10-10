FROM shizidushu/rstudio

# Install Rstudio preview
RUN apt-get update \
  && apt-get install -y libclang-dev \
  && wget --no-check-certificate -q https://s3.amazonaws.com/rstudio-ide-build/server/debian9/x86_64/rstudio-server-1.2.1030-amd64.deb \
  && dpkg -i rstudio-server-1.2.1030-amd64.deb \
  && rm rstudio-server-1.2.1030-amd64.deb

# install dev version of r pkgs
RUN Rscript -e "devtools::source_url('https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/r-pkgs-dev.R')"
