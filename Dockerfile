FROM shizidushu/rstudio

ARG GITHUB_PAT

# install python deps
RUN apt-get update \
  && apt-get install -y \
    python-pip
    python3-dev \
    python3-pip \
    python3-requests \
  && pip install -U pip setuptools wheel \
  && pip install virtualenv \
  && pip install pandas numpy SciPy matplotlib python-bs4

# Install Rstudio preview
RUN apt-get update \
  && apt-get install -y libclang-dev \
  && Rscript -e "devtools::source_url('https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/r-pkgs-dev.R')" \
  && wget --no-check-certificate -q https://s3.amazonaws.com/rstudio-ide-build/server/debian9/x86_64/rstudio-server-1.2.1153-amd64.deb \
  && dpkg -i rstudio-server-1.2.1153-amd64.deb \
  && rm rstudio-server-1.2.1153-amd64.deb

USER rstudio
RUN Rscript -e "blogdown::install_hugo()"
USER root
