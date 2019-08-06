FROM shizidushu/rstudio

ARG GITHUB_PAT

# Install Rstudio preview
RUN apt-get update \
  && apt-get install -y libclang-dev \
  && wget --no-check-certificate -q -O rstudio-server-amd64.deb https://s3.amazonaws.com/rstudio-ide-build/server/debian9/x86_64/rstudio-server-1.2.1555-amd64.deb \
  && dpkg -i rstudio-server-amd64.deb \
  && rm rstudio-server-amd64.deb
  
#  \
#  && wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
#  && dpkg -i google-chrome-stable_current_amd64.deb; apt-get -fy install \
#  && rm google-chrome-stable_current_amd64.deb




RUN Rscript -e "if (!require(devtools)) install.packages('devtools')" \
  && Rscript -e "devtools::source_url('https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/r-pkgs-trial-2.R')" \
  && rm -rf /tmp/Rtmp*
  
RUN julia -e 'using Pkg; Pkg.resolve(); Pkg.add(["LinearAlgebra", "SparseArrays", "Plots", "Random", "DSP"]); Pkg.add(PackageSpec(url="https://github.com/VMLS-book/VMLS.jl", rev="master"))'

