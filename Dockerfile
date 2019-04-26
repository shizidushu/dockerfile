FROM shizidushu/complete-r

ARG GITHUB_PAT



RUN Rscript -e "if (!require(devtools)) install.packages('devtools')" \
  && Rscript -e "devtools::source_url('https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/r-pkgs-ready.R')" \
  && Rscript -e "devtools::source_url('https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/r-pkgs-learning.R')" \
  && Rscript -e "devtools::source_url('https://raw.githubusercontent.com/shizidushu/common-pkg-list/master/r-pkgs-other.R')" \
  && rm -rf /tmp/Rtmp*
  
  
RUN julia -e 'using Pkg; Pkg.resolve(); Pkg.add(["LinearAlgebra", "SparseArrays", "Plots", "Random", "DSP"]); Pkg.add(PackageSpec(url="https://github.com/VMLS-book/VMLS.jl", rev="master"))'