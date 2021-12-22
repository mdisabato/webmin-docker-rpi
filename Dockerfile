# Based on slab42/bind9.16 https://www.github.com/slab42/bind9.16
# Modified to remove BIND

# Use the latest Debian image as a parent

FROM arm64v8/debian:buster-backports

LABEL MAINTAINER "Michael Disabato" <mdisabato@dellamente.com>

ENV WEBMIN_VERSION=1.983 \
    DATA_DIR=/data

# Initial updates and install core utilities
RUN apt-get update -qq -y && \
    apt-get upgrade -y && \
    apt-get install -y \
       wget \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y perl libnet-ssleay-perl \
      libauthen-pam-perl libpam-runtime libio-pty-perl unzip shared-mime-info

# Install Webmin
RUN rm -rf /etc/apt/apt.conf.d/docker-gzip-indexes \
 && apt-get update \
 && wget "http://prdownloads.sourceforge.net/webadmin/webmin_${WEBMIN_VERSION}_all.deb" -P /tmp/ \
 && dpkg -i /tmp/webmin_${WEBMIN_VERSION}_all.deb \
 && rm -rf /tmp/webmin_${WEBMIN_VERSION}_all.deb \
 && rm -rf /var/lib/apt/lists/*

COPY webmin-entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 10000/tcp
VOLUME ["${DATA_DIR}"]
ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["/usr/sbin/named"]
