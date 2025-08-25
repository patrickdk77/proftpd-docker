FROM ubuntu

ARG PROFTPD_VERSION VROOT_VERSION
RUN set -e \
 && apt-get -y update \
 && apt-get -y install git curl libmysqlclient-dev build-essential libssl-dev libpq-dev openssl gettext-base \
 && git clone -j8 --depth 1 --branch ${PROFTPD_VERSION} https://github.com/proftpd/proftpd.git \
 && git clone -j8 --depth 1 --branch ${VROOT_VERSION} https://github.com/Castaglia/proftpd-mod_vroot.git \
 && mv proftpd-mod_vroot proftpd/contrib/mod_vroot \
 && true
 
RUN set -e \
 && cd proftpd \
 && ./configure --sysconfdir=/etc/proftpd --localstatedir=/var/proftpd \
       --with-modules=mod_sql:mod_sql_mysql:mod_sql_passwd:mod_tls:mod_exec:mod_vroot:mod_sftp:mod_sftp_sql \
       --enable-openssl --disable-ident --enable-nls \
 && make \
 && make install \
 && true

COPY rootfs/ /

RUN set -e \
 && groupadd proftpd \
 && useradd -g proftpd proftpd \
 && chmod a+x /usr/local/bin/docker-entrypoint.sh \
 && mkdir /var/log/proftpd

# FTP ROOT
#VOLUME /srv/ftp

HEALTHCHECK --timeout=10s --start-period=10s CMD ftpwho

EXPOSE 21 49152-49407

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

ARG BUILD_DATE BUILD_REF BUILD_VERSION PROFTPD_VERSION VROOT_VERSION
LABEL maintainer="Patrick Domack (patrickdk@patrickdk.com)" \
  Description="Lightweight container for ProFTPD based on Ubuntu Linux." \
  org.label-schema.schema-version="1.0" \
  org.label-schema.build-date="${BUILD_DATE}" \
  org.label-schema.name="proftpd-docker" \
  org.label-schema.description="ProFTPD alpine base image" \
  org.label-schema.url="https://github.com/patrickdk77/proftpd-docker/" \
  org.label-schema.usage="https://github.com/patrickdk77/proftpd-docker/tree/master/README.md" \
  org.label-schema.vcs-url="https://github.com/patrickdk77/proftpd-docker" \
  org.label-schema.vcs-ref="${BUILD_REF}" \
  org.label-schema.version="${BUILD_VERSION}" \
  org.opencontainers.image.authors="Patrick Domack (patrickdk@patrickdk.com)" \
  org.opencontainers.image.created="${BUILD_DATE}" \
  org.opencontainers.image.title="proftpd-docker" \
  org.opencontainers.image.description="ProFTPD ubuntu image" \
  org.opencontainers.image.version="${BUILD_VERSION}" \
  version="${BUILD_VERSION}" \
  proftpd_version="${PROFTPD_VERSION}"
