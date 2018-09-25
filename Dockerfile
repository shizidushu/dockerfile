FROM shizidushu/rstudio

## Install system package that r packages depends on
RUN apt-get update \
  && apt-get install libclang-dev \
  && wget --no-check-certificate https://s3.amazonaws.com/rstudio-ide-build/desktop/trusty/amd64/rstudio-1.2.1004-amd64.deb \
  && dpkg -i rstudio-1.2.1004-amd64.deb \
  && rm rstudio-1.2.1004-amd64.deb