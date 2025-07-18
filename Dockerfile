# Author: Daniel Rode


# https://docs.docker.com/reference/dockerfile/


FROM alpine:edge

LABEL Author="Daniel Rode"

# Install Alpine Linux packages for building R libraries
RUN ash <<'EOF'
    set -e  # Exit on error
    apk update
    apk add \
        abseil-cpp-dev \
        boost-dev \
        fontconfig-dev \
        fribidi-dev \
        g++ \
        gdal-dev \
        geos-dev \
        harfbuzz-dev \
        libgit2-dev \
        libxml2-dev \
        linux-headers \
        proj-dev \
        R \
        R-dev \
        R-doc \
        udunits-dev \
    ;
EOF

# Create script for installing R packages
COPY <<'EOF' ./rinstall
#!/bin/sh

set -e  # Exit on error
repo="$2"
[ -z "$repo" ] && repo="https://cran.rstudio.com"
Rscript -e "install.packages('$1', repos='$repo', lib='/usr/local/rlib')"
Rscript -e "library($1, lib.loc='/usr/local/rlib')"  # Verify install
EOF
RUN chmod +x ./rinstall

# Install lidR
RUN ash <<'EOF'
    set -e  # Exit on error
    mkdir -p /usr/local/rlib
    ./rinstall sp
    ./rinstall codetools  # Recommended for building lidR
    ./rinstall doParallel  # Needed for parallel processing
    ./rinstall foreach  # Needed for parallel processing
    ./rinstall future  # Needed to enable lidR parallel processing
    ./rinstall lidR
    ./rinstall rjson  # Needed for loading LAS catalog RDS objects
    ./rinstall lwgeom  # Needed for crown statistics
    ./rinstall tibble  # Needed by SF for loading certain vector formats
EOF

# Install lasR
RUN ./rinstall lasR "https://r-lidar.r-universe.dev"

# Install lidRmetrics
RUN ash <<'EOF'
    set -e  # Exit on error
    ./rinstall geometry
    ./rinstall Lmoments
    Rscript -e '
        install.packages("withr", repos="https://cran.rstudio.com")
        install.packages("devtools", repos="https://cran.rstudio.com")
        library(withr)
        library(devtools)
        withr::with_libpaths("/usr/local/rlib",
            devtools::install_github("ptompalski/lidRmetrics")
        )
    '
EOF

# Add newly installed libraries to R path
ENV R_LIBS_USER=/usr/local/rlib
