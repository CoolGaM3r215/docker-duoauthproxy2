FROM debian:bookworm-slim as build

# from https://duo.com/docs/authproxy-reference#installation
RUN apt-get -y install \
    build-essential \
    libffi-dev \
    perl \
    zlib1g-dev

# modified from https://github.com/jumanjihouse/docker-duoauthproxy/
WORKDIR /src
ADD https://dl.duosecurity.com/duoauthproxy-5.2.1-src.tgz /src/
RUN tar xzf duoauthproxy-*-src.tgz \
 && cd duoauthproxy-*-src \
 && make \ 
 && useradd duo \
 && cd duoauthproxy-build \
 && ./install --install-dir=/opt/duoauthproxy --service-user=duo --log-group=duo --create-init-script=no

FROM debian:bookworm-slim

RUN apt-get -y install  \
    openssl
COPY --from=build /opt/duoauthproxy/ /opt/duoauthproxy/
RUN useradd -s /sbin/nologin duo \
 && mkdir -p /opt/duoauthproxy/log \
 && chown -R duo:duo /opt/duoauthproxy/log

USER duo
CMD ["/opt/duoauthproxy/bin/authproxy"]
