FROM ubuntu:19.04
 
COPY conf/gvm.conf /etc/ld.so.conf.d/gvm.conf


ENV DEBIAN_FRONTEND=noninteractive \
    GSE_PASSWORD=admin \
    HOSTNAME=gvm \
    SRC_DIR=src \
    SRC_PATH=/opt/gvm/src/ \
    PGUSERNAME=gvm \
    VIRTUAL_ENV=/opt/gvm \
    PATH=/opt/gvm/bin:/opt/gvm/sbin:/opt/gvm/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin 

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
        libssh-gcrypt-dev\
        libxml2-dev \
        nmap \
        nodejs \
        nsis \
        perl-base \
        pkg-config \
        postgresql \
        postgresql-contrib \
        postgresql-server-dev-all \
        python-polib \
        python3-virtualenv \
        python3-defusedxml \
        python3-lxml \
        python3-paramiko \
        python3-pip \
        python3-psutil \
        redis-server \
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

RUN apt-get install texlive-latex-extra --no-install-recommends -yq ;\
    apt-get install texlive-fonts-recommended -yq 

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - ;\
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list ;\
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
    wget -O gvm-libs-11.0.0.tar.gz  https://github.com/greenbone/gvm-libs/archive/v11.0.0.tar.gz ;\
    wget -O openvas-7.0.0.tar.gz https://github.com/greenbone/openvas/archive/v7.0.0.tar.gz ;\
    wget -O gvmd-9.0.0.tar.gz https://github.com/greenbone/gvmd/archive/v9.0.0.tar.gz ;\
    wget -O openvas-smb-1.0.5.tar.gz https://github.com/greenbone/openvas-smb/archive/v1.0.5.tar.gz ;\
    wget -O gsa-9.0.0.tar.gz https://github.com/greenbone/gsa/archive/v9.0.0.tar.gz ;\
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
    make doc ;\
    make install ;\
    cd ${SRC_PATH}

RUN cd ${SRC_PATH}\openvas-smb-1.0.5 ;\
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH ;\
    mkdir build ;\
    cd build/ ;\
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm .. ;\
    make ;\
    make install ;\
    cd ${SRC_PATH}

RUN cd ${SRC_PATH}\openvas-7.0.0 ;\
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH ;\
    mkdir build ;\
    cd build/ ;\
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm .. ;\
    make ;\
    make doc ;\
    make install ;\
    cd ${SRC_PATH}

COPY conf/openvas.conf /opt/gvm/etc/openvas/openvas.conf 

RUN greenbone-nvt-sync

RUN cd ${SRC_PATH}\gvmd-9.0.0 ;\
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH ;\
    mkdir build ;\
    cd build/ ;\
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm .. ;\
    make ;\
    make doc-full ;\
    make install ;\
    cd ${SRC_PATH}


RUN cd ${SRC_PATH}/gsa-9.0.0 ;\
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH ;\
    mkdir build ;\
    cd build/ ;\
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm .. ;\
    make ;\
    make doc-full ;\
    make install ;\
    touch /opt/gvm/var/log/gvm/gsad.log ;\
    cd ${SRC_PATH}

RUN python3 -m virtualenv --python=/usr/bin/python3 $VIRTUAL_ENV

ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN cd ${SRC_PATH}\ospd-2.0.0 ;\
    pip3 install . ;\
    cd ${SRC_PATH}

RUN cd ${SRC_PATH}\ospd-openvas-1.0.0 ;\
    pip3 install . ;\
    cd ${SRC_PATH}

#RUN rm {SRC_PATH}/ -rf

COPY script/entrypoint.sh /entrypoint.sh 

USER root

RUN ldconfig

CMD /entrypoint.sh

EXPOSE 443 9391