[![Build Status](https://travis-ci.org/shizidushu/dockerfile.svg?branch=rstudio)](https://travis-ci.org/shizidushu/dockerfile)

Based on: rocker/verse

Check Rstudio Server Administration Guide: http://docs.rstudio.com/ide/server-pro/


Based on rocker/verse. This image adds the following:

- System package R or related depends on
- Fix the Git path for Chinese
- Add SQL Server ODBC driver
- Add Cron to s6-init system
- Install R packages and latex packages



`docker pull shizidushu/rstudio`
