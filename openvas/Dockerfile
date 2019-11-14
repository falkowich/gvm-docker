FROM ubuntu:19.04

ENV DEBIAN_FRONTEND=noninteractive \
    HOSTNAME=gvmd \
    SRC_DIR=src \
    SRC_PATH=/opt/gvm/src/ \
    PATH=$PATH:/opt/gvm/bin:/opt/gvm/sbin:/opt/gvm/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin 

RUN apt-get update && apt-get install \
  -y --no-install-recommends python3 python3-virtualenv




RUN apt-get update ;\
    apt-get install apt-utils software-properties-common --no-install-recommends -yq ;\
    add-apt-repository universe -y ;\
    apt-get dist-upgrade -yq ;\
    apt-get install alien \
        apt-transport-https \
        bison  \
        cmake \
        curl \
        doxygen \
        fakeroot \
        gcc \
        gcc-mingw-w64 \
        gettext \
        git \
        gnupg \
        gnutls-bin \
        graphviz \
        heimdal-dev \
        libfreeradius-dev \
        libgcrypt20-dev \
        libglib2.0-dev \
        libgnutls28-dev \
        libgpgme-dev \
        libgpgme11-dev \
        libhiredis-dev\
        libical2-dev \
        libksba-dev \
        libldap2-dev \
        libmicrohttpd-dev \
        libpcap-dev \
        libpopt-dev \
        libpq-dev \
        libradcli-dev \
        libsnmp-dev  \
        libsnmp-dev \
        libsqlite3-dev \
        libssh-gcrypt-dev \
        libxml2-dev \
        nmap \
        nodejs \
        nsis \
        perl-base \
        pkg-config \
        postgresql-server-dev-all \
        python-polib \
        python3-virtualenv \
        python3-defusedxml \
        python3-lxml \
        python3-paramiko \
        python3-pip \
        python3-psutil \
        rpm \
        rsync \
        smbclient \
        snmp \
        socat \
        sqlfairy \
        sshpass \
        sudo \
        uuid-dev \
        wget \
        xmlstarlet \
        xmltoman \
        xsltproc \
        zip \
        gosu \
        -yq


RUN mkdir /opt/gvm ;\
    adduser gvm --disabled-password --home /opt/gvm/ --no-create-home --gecos '' ;\
    addgroup redis ;\
    usermod -aG redis gvm ;\
    mkdir -p /opt/gvm/var/log/gvm ;\
    chown gvm:gvm /opt/gvm/ -R

RUN echo 'Defaults        secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/opt/gvm/sbin"' >> /etc/sudoers ;\
    echo 'gvm ALL = NOPASSWD: /opt/gvm/sbin/openvas' >> /etc/sudoers

RUN apt install virtualenv

USER gvm

RUN mkdir ${SRC_PATH} -p ;\
    cd ${SRC_PATH} ;\
    wget -O gvm-libs-11.0.0.tar.gz  https://github.com/greenbone/gvm-libs/archive/v11.0.0.tar.gz ;\
    wget -O openvas-7.0.0.tar.gz https://github.com/greenbone/openvas/archive/v7.0.0.tar.gz ;\
    wget -O gvmd-9.0.0.tar.gz https://github.com/greenbone/gvmd/archive/v9.0.0.tar.gz ;\
    wget -O openvas-smb-1.0.5.tar.gz https://github.com/greenbone/openvas-smb/archive/v1.0.5.tar.gz ;\
    wget -O ospd-openvas-1.0.0.tar.gz https://github.com/greenbone/ospd-openvas/archive/v1.0.0.tar.gz ;\
    wget -O ospd-2.0.0.tar.gz https://github.com/greenbone/ospd/archive/v2.0.0.tar.gz

RUN cd ${SRC_PATH} ;\
    find . -name \*.gz -exec tar zxvfp {} \;

RUN cd ${SRC_PATH}\gvm-libs-11.0.0 ;\
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH ;\
    mkdir build ;\
    cd build ;\
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm .. ;\
    make ;\
    make install ;\
    cd ${SRC_PATH}

RUN cd ${SRC_PATH}\gvmd-9.0.0 ;\
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH ;\
    mkdir build ;\
    cd build/ ;\
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm .. ;\
    make ;\
    make install ;\
    cd ${SRC_PATH}

RUN cd ${SRC_PATH}\openvas-smb-1.0.5 ;\
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH ;\
    mkdir build ;\
    cd build/ ;\
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm .. ;\
    make ;\
    make install ;\
    cd /opt/gvm/src


RUN  cd ${SRC_PATH}\openvas-7.0.0 ;\
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH ;\
    mkdir build ;\
    cd build/ ;\
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm .. ;\
    make ;\
    make install ;\
    cd /opt/gvm/src


RUN virtualenv --python python3.7  /opt/gvm/bin/ospd-scanner/

RUN /bin/bash -c "source /opt/gvm/bin/ospd-scanner/bin/activate ;\
    cd ${SRC_PATH}\ospd-2.0.0 ;\
    pip3 install . ;\
    cd ${SRC_PATH}\ospd-openvas-1.0.0 ;\
    pip3 install . ;\
    cd ${SRC_PATH}"

COPY script/entrypoint.sh /entrypoint.sh 

CMD /entrypoint.sh