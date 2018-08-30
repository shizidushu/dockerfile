[![Build Status](https://travis-ci.org/shizidushu/dockerfile.svg?branch=plumber)](https://travis-ci.org/shizidushu/dockerfile)

Based on: shizidushu/complete-r

- `plumber::plumb(rev(commandArgs())[1]); pr$run(host='0.0.0.0', port=8000, swagger=TRUE)` Let it possible to use the last command (can be specified in docker-compose.yml)