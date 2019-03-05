FROM rocker/r-ver:latest

ARG GITHUB_PAT


ENV JULIA_PATH /usr/local/julia
ENV PATH $JULIA_PATH/bin:$PATH

## Install system package that r packages depends on
RUN apt-get update && apt-get install -y \
    software-properties-common \
    apt-transport-https \
    bzip2 \
    ca-certificates \
    cargo \
    dirmngr \
    sudo \
    cron \
    curl \
    gdebi-core \
    fonts-wqy-zenhei \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libssh2-1-dev \
    libcairo2-dev \
    libxt-dev \
    libpython-dev \
    libpython3-dev \
    wget \
    default-jdk \
    fonts-wqy-zenhei \
    libglu1-mesa-dev \
    libudunits2-dev \
    libgit2-dev \
    git \
    gnupg \
    gnupg2 \
    libgl1-mesa-dev  \
    libhiredis-dev \
    libmagick++-dev \
    libpq-dev \
    libssl-dev \
    tdsodbc \
    libsqliteodbc \
    odbc-postgresql \
    unixodbc \
    unixodbc-dev \
    xtail \
    libudunits2-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    libv8-dev \
    libjq-dev \
    libprotobuf-dev \
    protobuf-compiler \
    libssl-dev \
    unzip \
    xvfb \
    libxi6 \
    libgconf-2-4 \
  && R CMD javareconf \
  && curl -fL -o julia.tar.gz "https://julialang-s3.julialang.org/bin/linux/x64/1.1/julia-1.1.0-linux-x86_64.tar.gz" \
  && mkdir "$JULIA_PATH" \
  && tar -xzf julia.tar.gz -C "$JULIA_PATH" --strip-components 1 \
  && rm julia.tar.gz \
  && julia --version \
  && wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
  && dpkg -i google-chrome-stable_current_amd64.deb; apt-get -fy install \
  && rm google-chrome-stable_current_amd64.deb \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


## Fix package dependency & git chinese character path
### http://blog.csdn.net/gxp/article/details/26563579

RUN git config --global core.quotepath false \
    && git config --global gui.encoding utf-8 \
    && git config --global i18n.commit.encoding utf-8 \
    && git config --global i18n.logoutputencoding utf-8
ENV LESSCHARSET=utf-8
