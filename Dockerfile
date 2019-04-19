FROM shizidushu/rstudio

ARG GITHUB_PAT

# Install Rstudio preview
RUN apt-get update \
  && apt-get install -y libclang-dev \
  && wget --no-check-certificate -q https://s3.amazonaws.com/rstudio-ide-build/server/debian9/x86_64/rstudio-server-1.2.1502-amd64.deb \
  && dpkg -i rstudio-server-1.2.1502-amd64.deb \
  && rm rstudio-server-1.2.1502-amd64.deb
  
#  \
#  && wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
#  && dpkg -i google-chrome-stable_current_amd64.deb; apt-get -fy install \
#  && rm google-chrome-stable_current_amd64.deb

USER rstudio
RUN Rscript -e "blogdown::install_hugo()"
USER root

# install python deps
RUN apt-get update \
  && apt-get install -y \
    python-pip \
    python3-dev \
    python3-pip \
    python3-requests \
    python-numpy \
    python-scipy \
    python-matplotlib \
    python-pandas \
    python-sympy \
  && pip install virtualenv
  
#    python-nose \
#    python-bs4 \


RUN Rscript -e "if (!require(devtools)) install.packages('devtools')" \
  && Rscript -e "devtools::source_url('https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/r-pkgs-ready.R')" \
  && Rscript -e "devtools::source_url('https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/r-pkgs-learning.R')" \
  && Rscript -e "devtools::source_url('https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/r-pkgs-other.R')" \
  && rm -rf /tmp/Rtmp*