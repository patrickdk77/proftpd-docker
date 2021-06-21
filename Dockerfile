FROM ubuntu:groovy-20210614

RUN set -e \
 && apt-get -y update \
 && apt-get -y install git curl libmysqlclient-dev build-essential libssl-dev libpq-dev openssl gettext-base \
 && git clone https://github.com/proftpd/proftpd.git \
 && git clone https://github.com/Castaglia/proftpd-mod_vroot.git \
 && cd proftpd-mod_vroot \
 && git checkout tags/v0.9.5 \
 && cd .. \
 && mv proftpd-mod_vroot proftpd/contrib/mod_vroot \
 && echo ""
 
RUN cd proftpd \
 && ./configure --sysconfdir=/etc/proftpd --localstatedir=/var/proftpd \
       --with-modules=mod_sql:mod_sql_mysql:mod_sql_passwd:mod_tls:mod_exec:mod_vroot:mod_sftp:mod_sftp_sql \
       --enable-openssl --disable-ident --enable-nls \
 && make \
 && make install

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
