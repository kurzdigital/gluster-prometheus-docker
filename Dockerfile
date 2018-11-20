from golang:stretch as build

# Otherwise make runs with /bin/sh
ENV SHELL "bash"

RUN \

# Install dep
    curl -sL https://github.com/golang/dep/releases/download/v0.5.0/dep-linux-amd64 > $GOPATH/bin/dep && \
    chmod 755 $GOPATH/bin/dep && \
# Install gometalinter
    curl -sL https://github.com/alecthomas/gometalinter/releases/download/v2.0.11/gometalinter-2.0.11-linux-amd64.tar.gz | tar --strip-components=1 -zxf - -C $GOPATH/bin && \
# Install gluster-prometheus
    mkdir -p $GOPATH/src/github.com/gluster && \
    cd $GOPATH/src/github.com/gluster && \
    git clone https://github.com/gluster/gluster-prometheus.git && \
    cd gluster-prometheus && \
    bash -c "make" && \
    cp ./build/gluster-exporter /tmp/

from debian:stretch

RUN apt update && apt install -y glusterfs-server procps && apt clean

copy --from=build /tmp/gluster-exporter /
copy gluster-exporter.toml /
run chmod 755 /gluster-exporter

CMD ["/gluster-exporter", "--config=/gluster-exporter.toml"]
