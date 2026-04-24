# syntax=docker/dockerfile:1

# The image is for testing MariaDB isolation violations with Jepsen
#
# Build (from the repo root):
#   docker build -t mariadb-jepsen -f mariadb-docker/Dockerfile .
#
# Run (clone & build MariaDB, then test):
#   docker run mariadb-jepsen https://github.com/MariaDB/server 11.8
#
# Run (prebuilt install mounted from host):
#   docker run -v /path/to/install:/home/mariadb/mariadb-bin mariadb-jepsen
#
# Run (build tree mounted from host):
#   docker run -v /path/to/build-tree:/home/mariadb/mariadb-bin mariadb-jepsen
#
FROM ubuntu:24.04

RUN <<EOT
set -e
sed -i 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources
apt-get update
apt-get -y upgrade
# SSH is not used for single-machine tests but Jepsen may require it for
# multi-node setups, so the packages are installed but not configured.
apt-get -y install --no-install-recommends \
    dpkg-dev git cmake gcc g++ vim libncurses-dev gnutls-dev bison make \
    automake libtool pkg-config libaio-dev libpcre2-dev zlib1g-dev \
    sudo openjdk-21-jre openjdk-21-jdk wget \
    openssh-server openssh-client \
    apt-transport-https libzip4t64 curl man-db faketime netcat-openbsd \
    ntpsec-ntpdate unzip iptables psmisc tar bzip2 iputils-ping iproute2 \
    rsyslog logrotate dirmngr tcpdump graphviz gnuplot
apt-get clean
rm -rf /var/lib/apt/lists/* /var/cache/apt/* /var/log/apt/* /var/log/dpkg.log
adduser --disabled-password --comment "" mariadb
wget -O /usr/local/bin/lein https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein
chmod a+x /usr/local/bin/lein
EOT

COPY mariadb-docker/start.sh mariadb-docker/tests.sh mariadb-docker/verify.sh /

USER mariadb

COPY --chown=mariadb:mariadb project.clj /home/mariadb/jepsen-mariadb/
RUN cd ~/jepsen-mariadb && lein deps

COPY --chown=mariadb:mariadb . /home/mariadb/jepsen-mariadb
RUN cd ~/jepsen-mariadb && lein check

ENTRYPOINT ["/start.sh"]
