#
# https://github.com/SoftEtherVPN/SoftEtherVPN/blob/master/src/BUILD_UNIX.md
#
FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
RUN set -ex \
  && apt update \
  && apt-get install -y rsync git cmake gcc g++ make pkgconf \
      libncurses5-dev libssl-dev libsodium-dev libreadline-dev zlib1g-dev

WORKDIR /tmp

RUN set -ex \
    && git clone https://github.com/SoftEtherVPN/SoftEtherVPN.git \
    && cd SoftEtherVPN \
    && git submodule init && git submodule update \
    && ./configure \
    && make -C build \
    && make -C build install

FROM ubuntu:22.04 AS production
ENV DEBIAN_FRONTEND=noninteractive
RUN set -ex \
  && apt update \
  && apt-get install -y libsodium23 libreadline-dev iproute2 iputils-ping

COPY --from=builder /usr/local/libexec/softether /usr/local/libexec/softether/
COPY --from=builder /usr/local/bin/vpnserver /usr/local/bin/vpnserver
COPY --from=builder /usr/local/bin/vpnclient /usr/local/bin/vpnclient
COPY --from=builder /usr/local/bin/vpncmd /usr/local/bin/vpncmd
COPY --from=builder /usr/local/lib/libcedar.so /usr/local/lib/libcedar.so
COPY --from=builder /usr/local/lib/libmayaqua.so /usr/local/lib/libmayaqua.so

ENTRYPOINT [ "vpncmd", "/TOOLS", "/CMD", "Check" ]
