FROM shizidushu/rstudio

## Install system package that r packages depends on
RUN apt-get update \
  && wget --no-check-certificate https://s3.amazonaws.com/rstudio-ide-build/server/trusty/amd64/rstudio-server-1.2.1004-amd64.deb \
  && dpkg -i rstudio-server-1.2.1004-amd64.deb \
  && rm rstudio-server-1.2.1004-amd64.deb
