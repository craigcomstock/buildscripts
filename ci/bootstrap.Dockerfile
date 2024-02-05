FROM debian:stretch-backports
#RUN rm -f /etc/apt/sources.list.d/*; echo 'deb http://archive.debian.org/debian/ stretch main contrib non-free' >/etc/apt/sources.list 
RUN apt-get -qy update 
RUN apt-get -qy upgrade 
#RUN apt-get -y install autossh git autogen autoconf automake m4 make bison flex binutils libtool gcc g++ libc-dev \
#           liblmdb-dev libpam0g-dev python libssl-dev libpcre3-dev psmisc curl jq php php-gd php-mbstring php-xml php-ldap unzip \
#           pigz parallel libpcre2-dev
COPY linux-install-node-20.10.0.sh /
#RUN /linux-install-node-20.10.0.sh
COPY install-composer.sh /
#RUN /install-composer.sh
CMD sleep infinity
