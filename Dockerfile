FROM ubuntu:16.04

LABEL maintainer="Jaeyoung Chun (jaeyoung.chun@weizmann.ac.il)"

ENV BAMTOOLS_VERSION="2.5.0"

RUN apt-get update -y \
    && apt-get install -y wget build-essential cmake git pkg-config libz-dev \
    && apt-get install -y python-pip \
    && pip install --upgrade pip

RUN cd /tmp \
    && git clone https://github.com/adaptivegenome/repeatseq.git \
    && cd repeatseq \
    && git clone https://github.com/ekg/fastahack.git \
    && wget https://github.com/pezmaster31/bamtools/archive/v${BAMTOOLS_VERSION}.tar.gz \
    && tar xvzf v${BAMTOOLS_VERSION}.tar.gz \
    && mv bamtools-${BAMTOOLS_VERSION} bamtools \
    && mkdir -p bamtools/build \
    && cd bamtools/build \
    && cmake .. \
    && make

# hack: the posted installation steps do not work
RUN cd /tmp/repeatseq \
    && mkdir -p bamtools/lib \
    && cp bamtools/build/src/api/libbamtools.a bamtools/lib \
    && sed -i.bak 's|-Lbamtools/lib|-Lbamtools/lib -lz|g' makefile \
    && make

# copy binary and clean up
RUN cp /tmp/repeatseq/repeatseq /usr/bin/ \
    && rm -rf /tmp/*

ENTRYPOINT ["/usr/bin/repeatseq"]
CMD ["--help"]
