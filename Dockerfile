FROM r-base:4.3.2 AS base

# Build base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    ## Install python 3 and system dependencies
        && apt-get install -y --no-install-recommends build-essential procps libpq-dev python3.8 python3-pip python3-setuptools python3-dev python3.11-venv \
    ## Install bed tools
        && apt-get install bedtools \
    ## Move python usr library
        && mv /usr/lib/python3.11/EXTERNALLY-MANAGED /usr/lib/python3.11/EXTERNALLY-MANAGED.old \
    ## install R packages
        && install2.r \
            tidyverse \
            readxl \
            openxlsx \
            devtools \
            argparse \
            Cairo \
            docopt \
            Hmisc \
            jsonlite \
            pals \
            patchwork \
            reticulate \
            rlang \
            rjson \
            yaml \
    ## install pythoon packages
        && pip3 install \
            ipython \
            numpy \
            scipy \
            pandas

ENV PYTHONPATH "${PYTHONPATH}:/app"



FROM base AS build

# Install samtools

RUN wget https://github.com/samtools/samtools/releases/download/1.18/samtools-1.18.tar.bz2 \
    && tar -axf samtools-1.18.tar.bz2
WORKDIR "/samtools-1.18"
RUN ./configure --prefix=/bin/samtools-1.18/ \
    && make \
    && make install


WORKDIR "/"

# Install htslib

RUN wget https://github.com/samtools/htslib/releases/download/1.18/htslib-1.18.tar.bz2 \
    && tar -axf htslib-1.18.tar.bz2
WORKDIR "/htslib-1.18"
RUN ./configure --prefix=/bin/htslib-1.18 \
    && make \
    && make install

# Create image

FROM base as image

WORKDIR "/"
COPY --from=build /bin/samtools-1.18 /bin/samtools-1.18
COPY --from=build /bin/htslib-1.18 /bin/htslib-1.18
ENV PATH="${PATH}:/bin/samtools-1.18/bin/:/bin/htslib-1.18/bin/"

CMD ["/bin/bash"]
