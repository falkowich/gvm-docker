FROM debian:10.2

COPY conf/gvm.conf /etc/ld.so.conf.d/gvm.conf

ENV DEBIAN_FRONTEND=noninteractive \
    HOSTNAME=gvmd \
    SRC_PATH=/opt/gvm/src/ \
    PATH=$PATH:/opt/gvm/bin:/opt/gvm/sbin:/opt/gvm/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin 

RUN apt-get update ;\
    apt-get install apt-utils software-properties-common --no-install-recommends -yq ;\
    apt-get dist-upgrade -yq ;\
    apt-get install cmake pkg-config libglib2.0-dev libgpgme-dev libgnutls28-dev uuid-dev libssh-gcrypt-dev \
        libldap2-dev doxygen graphviz libradcli-dev libhiredis-dev libpcap-dev bison libksba-dev libsnmp-dev \
        gcc-mingw-w64 heimdal-dev libpopt-dev xmltoman redis-server xsltproc libical-dev postgresql \
        postgresql-contrib postgresql-server-dev-all gnutls-bin nmap rpm nsis curl wget fakeroot gnupg \
        sshpass socat snmp smbclient libmicrohttpd-dev libxml2-dev python-polib gettext rsync xml-twig-tools \
        python3-paramiko python3-lxml python3-defusedxml python3-pip python3-psutil virtualenv git gosu -yq

RUN apt-get install texlive-latex-extra --no-install-recommends -yq ;\
    apt-get install texlive-fonts-recommended -yq 

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg |  apt-key add -  ;\
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list ;\
    apt-get update ;\
    apt-get install yarn -yq

RUN mkdir /opt/gvm ;\
    adduser gvm --disabled-password --home /opt/gvm/ --no-create-home --gecos '' ;\
    usermod -aG redis gvm ;\
    chown gvm:gvm /opt/gvm/ -R

RUN echo 'Defaults        secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/opt/gvm/sbin"' >> /etc/sudoers ;\
    echo 'gvm ALL = NOPASSWD: /opt/gvm/sbin/openvas' >> /etc/sudoers

USER gvm


RUN mkdir ${SRC_PATH} -p ;\
    cd ${SRC_PATH} ;\
    git clone -b gvm-libs-11.0 --single-branch  https://github.com/greenbone/gvm-libs.git ;\
    git clone -b openvas-7.0 --single-branch https://github.com/greenbone/openvas.git ;\
    git clone -b gvmd-9.0 --single-branch https://github.com/greenbone/gvmd.git ;\
    git clone -b master --single-branch https://github.com/greenbone/openvas-smb.git ;\
    git clone -b gsa-9.0 --single-branch https://github.com/greenbone/gsa.git ;\
    git clone -b ospd-openvas-1.0 --single-branch  https://github.com/greenbone/ospd-openvas.git ;\
    git clone -b ospd-2.0 --single-branch https://github.com/greenbone/ospd.git

RUN cd ${SRC_PATH}\gvm-libs ;\
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH ;\
    mkdir build ;\
    cd build ;\
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm .. ;\
    make ;\
    make doc ;\
    make install ;\
    cd ${SRC_PATH}

RUN cd ${SRC_PATH}\openvas-smb ;\
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH ;\
    mkdir build ;\
    cd build/ ;\
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm .. ;\
    make ;\
    make install ;\
    cd ${SRC_PATH}

RUN cd ${SRC_PATH}\openvas ;\
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH ;\
    mkdir build ;\
    cd build/ ;\
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm .. ;\
    make ;\
    make doc ;\
    make install ;\
    cd /opt/gvm/src

USER root

RUN ldconfig ;\
    mkdir /var/run/redis-openvas ;\
    chown redis.redis /var/run/redis-openvas -R ;\
    cp /opt/gvm/src/openvas/config/redis-openvas.conf /etc/redis/redis.conf ;\
    chown redis:redis /etc/redis/redis.conf ;\
    echo "db_address = /run/redis-openvas/redis.sock" > /opt/gvm/etc/openvas/openvas.conf 

RUN echo 'Defaults        secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/opt/gvm/sbin"' >> /etc/sudoers ;\
    echo 'gvm ALL = NOPASSWD: /opt/gvm/sbin/openvas' >> /etc/sudoers ;\
    echo 'gvm ALL = NOPASSWD: /opt/gvm/sbin/gsad' >> /etc/sudoers

RUN cat /etc/sudoers

USER gvm

RUN greenbone-nvt-sync


RUN cd ${SRC_PATH}\gvmd ;\
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH ;\
    mkdir build ;\
    cd build/ ;\
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm .. ;\
    make ;\
    make doc ;\
    make install ;\
    cd /opt/gvm/src

# TODO - This is beq I cant get the sync's to work.. Ugly as ****. 

RUN greenbone-certdata-sync
RUN greenbone-certdata-sync 
RUN greenbone-certdata-sync 

RUN greenbone-scapdata-sync 
RUN greenbone-scapdata-sync 
RUN greenbone-scapdata-sync 

RUN cd ${SRC_PATH}\gsa ;\
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH ;\
    mkdir build ;\
    cd build/ ;\
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm .. ;\
    make ;\
    make doc ;\
    make install ;\
    touch /opt/gvm/var/log/gvm/gsad.log ;\
    cd /opt/gvm/src


RUN virtualenv --python python3.7  /opt/gvm/bin/ospd-scanner/

RUN /bin/bash -c "source /opt/gvm/bin/ospd-scanner/bin/activate ;\
    cd ${SRC_PATH}\ospd ;\
    pip3 install . ;\
    cd ${SRC_PATH}\ospd-openvas ;\
    pip3 install . ;\
    cd ${SRC_PATH}"

COPY script/entrypoint.sh /entrypoint.sh 

USER root

CMD /entrypoint.sh

EXPOSE 443 9391