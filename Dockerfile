FROM rocker/shiny

## Install linux packages may depend on

## install SQL Server drivers and tools
### https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server    
### https://github.com/Microsoft/mssql-docker/blob/master/linux/mssql-tools/Dockerfile

## Fix package dependency & git chinese character path
### http://blog.csdn.net/gxp/article/details/26563579

## Install imagemagick
### 1. make a new directory
### 2. download the latest source from https://www.imagemagick.org/download/ImageMagick.tar.gz
### 3. open the only one folder. https://askubuntu.com/questions/454688/how-do-you-cd-into-the-first-available-folder-without-typing-out-the-name
### 4. install


RUN echo "deb http://ftp2.cn.debian.org/debian stretch main non-free contrib" >> /etc/apt/sources.list \
    && apt-get update && apt-get -y install \
        apache2-utils \
        apt-transport-https \
        autoconf \
        automake \
        cron \
        curl \
        debconf-utils \
        default-jdk \
        fonts-wqy-zenhei \
        gnupg1 \
        gnupg2 \
        libcurl-dev \
        libglu1-mesa-dev \
        libhiredis-dev \
        libpq-dev \
        libsecret-1-dev \
        libtool \
        libudunits2-dev \
        m4 \
        xz-utils \
    && R CMD javareconf \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get -y install msodbcsql17 \
    && ACCEPT_EULA=Y apt-get -y install mssql-tools \
    && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile \
    && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc \
    && /bin/bash -c "source ~/.bashrc" \
    && apt-get -y install unixodbc-dev \
    && git config --global core.quotepath false \
    && git config --global gui.encoding utf-8 \
    && git config --global i18n.commit.encoding utf-8 \
    && git config --global i18n.logoutputencoding utf-8 \
    && export LESSCHARSET=utf-8 \
    && mkdir /tmp/imk \
    && cd /tmp/imk \
    && wget --no-verbose "https://www.imagemagick.org/download/ImageMagick.tar.gz" \
    && tar xvzf ImageMagick.tar.gz \
    && cd */ \
    && ./configure \
      --disable-static \
      --enable-shared \
      --with-gslib \
      --with-jpeg \
      --with-openjp2 \
      --with-png \
      --with-tiff \
      --with-quantum-depth=8 \
    && make \
    && make install \
    && ldconfig /usr/local/lib \
    && cd / \
    && apt-get autoremove -y \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*




RUN Rscript -e "install.packages('devtools')" \
  && Rscript -e "devtools::source_url('https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/r-pkgs.txt')"