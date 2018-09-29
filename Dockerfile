FROM shizidushu/rstudio

RUN apt-get update \
  && apt-get install -y libclang-dev \
  && wget --no-check-certificate -q https://s3.amazonaws.com/rstudio-ide-build/server/debian9/x86_64/rstudio-server-1.2.1013-amd64.deb \
  && dpkg -i rstudio-server-1.2.1013-amd64.deb \
  && rm rstudio-server-1.2.1013-amd64.deb
