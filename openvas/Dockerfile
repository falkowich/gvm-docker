FROM ubuntu:18.04
RUN apt-get update && apt-get install \
  -y --no-install-recommends python3 python3-virtualenv

ENV DEBIAN_FRONTEND=noninteractive \
    HOSTNAME=scanner \
    SRC_DIR=src \
    SRC_PATH=/opt/gvm/src/ \
    VIRTUAL_ENV=/opt/gvm

RUN apt-get update ;\
    apt-get install apt-utils software-properties-common --no-install-recommends -yq ;\
    apt-get dist-upgrade -yq ;\
    apt-get install \
        cmake \
        wget \
        doxygen \
        fakeroot \
        gcc \
        git \
        pkg-config \
        python-polib \
        python3-defusedxml \
        python3-lxml \
        python3-paramiko \
        python3-pip \
        python3-psutil \
        -yq

RUN mkdir /opt/gvm ;\
    adduser gvm --disabled-password --home /opt/gvm/ --no-create-home --gecos '' ;\
    usermod -aG redis gvm ;\
    chown gvm:gvm /opt/gvm/ -R

USER gvm

RUN mkdir ${SRC_PATH} -p ;\
    cd ${SRC_PATH} ;\
    wget -O ospd-openvas-1.0.0.tar.gz https://github.com/greenbone/ospd-openvas/archive/v1.0.0.tar.gz ;\
    wget -O ospd-2.0.0.tar.gz https://github.com/greenbone/ospd/archive/v2.0.0.tar.gz

RUN cd ${SRC_PATH} ;\
    find . -name \*.gz -exec tar zxvfp {} \;

RUN python3 -m virtualenv --python=/usr/bin/python3 $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN cd ${SRC_PATH}\ospd-2.0.0 ;\
pip3 install . ;\
cd ${SRC_PATH}

RUN cd ${SRC_PATH}\ospd-openvas-1.0.0 ;\
pip3 install . ;\
cd ${SRC_PATH}

COPY script/entrypoint.sh /entrypoint.sh 

CMD /entrypoint.sh