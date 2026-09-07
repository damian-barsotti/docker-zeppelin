# Basado en el Dockerfile oficial de Zeppelin:
#   https://github.com/apache/zeppelin/blob/v0.12.1/scripts/docker/zeppelin/bin/Dockerfile
# Se construye la imagen desde cero, en vez de partir de apache/zeppelin, para
# poder crear el env conda con Python 3.11: el yml de upstream pinnea
# python=3.7, donde plotly 6.x no se puede instalar.
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:22.04

LABEL maintainer="Damian Barsotti<damian@famaf.unc.edu.ar>"

ARG zeppelin_version=0.12.1
ARG spark_version=3.5.9
ARG hadoop_version="3"
ARG spark_download_url=https://archive.apache.org/dist/spark

ENV Z_VERSION="${zeppelin_version}"

ENV LOG_TAG="[ZEPPELIN_${Z_VERSION}]:" \
    ZEPPELIN_HOME="/opt/zeppelin" \
    HOME="/opt/zeppelin" \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 \
    ZEPPELIN_ADDR="0.0.0.0" \
    SPARK_HOME="/opt/spark"

# A los paquetes de upstream se agregan los del curso: bash-completion,
# iputils-ping, less, screen (lo usa start.sh) y mc.
RUN echo "$LOG_TAG install basic packages" && \
    apt-get -y update && \
    # Switch back to install JRE instead of JDK when moving to JDK9 or later.
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        locales language-pack-en tini openjdk-11-jdk-headless wget unzip \
        bash-completion iputils-ping less screen mc && \
    # Cleanup
    rm -rf /var/lib/apt/lists/* && \
    apt-get autoclean && \
    apt-get clean

# Install conda to manage python and R packages
ARG miniconda_version="py39_24.1.2-0"
# Hashes via https://docs.conda.io/en/latest/miniconda_hashes.html
ARG miniconda_sha256="2ec135e4ae2154bb41e8df9ecac7ef23a7d6ca59fc1c8071cfe5298505c19140"
# Install python and R packages via conda
COPY env_python_3_with_R.yml /env_python_3_with_R.yml

RUN set -ex && \
    wget -nv https://repo.anaconda.com/miniconda/Miniconda3-${miniconda_version}-Linux-x86_64.sh -O miniconda.sh && \
    echo "${miniconda_sha256} miniconda.sh" > anaconda.sha256 && \
    sha256sum --strict -c anaconda.sha256 && \
    bash miniconda.sh -b -p /opt/conda && \
    export PATH=/opt/conda/bin:$PATH && \
    conda config --set always_yes yes --set changeps1 no && \
    conda info -a && \
    conda install mamba -c conda-forge && \
    # Upstream usa 'mamba env update --prune', que en mamba 2.x falla si el env
    # no existe ("No prefix found"). Al construir desde cero corresponde create.
    mamba env create -f /env_python_3_with_R.yml && \
    # Cleanup
    rm -v miniconda.sh anaconda.sha256  && \
    # Cleanup based on https://github.com/ContinuumIO/docker-images/commit/cac3352bf21a26fa0b97925b578fb24a0fe8c383
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    mamba clean -ay
    # Allow to modify conda packages. This allows malicious code to be injected into other interpreter sessions, therefore it is disabled by default
    # chmod -R ug+rwX /opt/conda
ENV PATH=/opt/conda/envs/python_3_with_R/bin:/opt/conda/bin:$PATH

RUN echo "$LOG_TAG Download Zeppelin binary" && \
    mkdir -p ${ZEPPELIN_HOME} && \
    wget -nv -O /tmp/zeppelin-${Z_VERSION}-bin-all.tgz "https://www.apache.org/dyn/closer.lua/zeppelin/zeppelin-${Z_VERSION}/zeppelin-${Z_VERSION}-bin-all.tgz?action=download" && \
    tar --strip-components=1 -zxvf  /tmp/zeppelin-${Z_VERSION}-bin-all.tgz -C ${ZEPPELIN_HOME} && \
    rm -f /tmp/zeppelin-${Z_VERSION}-bin-all.tgz && \
    chown -R root:root ${ZEPPELIN_HOME} && \
    mkdir -p ${ZEPPELIN_HOME}/logs ${ZEPPELIN_HOME}/run ${ZEPPELIN_HOME}/webapps && \
    # Allow process to edit /etc/passwd, to create a user entry for zeppelin
    chgrp root /etc/passwd && chmod ug+rw /etc/passwd && \
    # Give access to some specific folders
    chmod -R 775 "${ZEPPELIN_HOME}/logs" "${ZEPPELIN_HOME}/run" "${ZEPPELIN_HOME}/notebook" "${ZEPPELIN_HOME}/conf" && \
    # Allow process to create new folders (e.g. webapps)
    chmod 775 ${ZEPPELIN_HOME} && \
    chmod -R 775 /opt/conda

COPY log4j.properties ${ZEPPELIN_HOME}/conf/
COPY log4j_docker.properties ${ZEPPELIN_HOME}/conf/
COPY log4j2.properties ${ZEPPELIN_HOME}/conf/
COPY log4j2_docker.properties ${ZEPPELIN_HOME}/conf/

# --- Agregados del curso -----------------------------------------------------

RUN find -name \._\* -type f -exec rm -f {} \; || true

COPY ./start.sh /start.sh

RUN chmod 755 /start.sh

RUN cp /root/.bashrc /opt/zeppelin/ && \
    echo alias "mc='. /usr/share/mc/bin/mc-wrapper.sh'" >> /opt/zeppelin/.bashrc

RUN echo "Download Spark binary" && \
    mkdir -p ${SPARK_HOME} && \
    wget --progress=dot:giga -O /tmp/spark.tgz ${spark_download_url}/spark-${spark_version}/spark-${spark_version}-bin-hadoop${hadoop_version}.tgz

RUN echo "Install Spark" && \
    tar --strip-components=1 -zxvf /tmp/spark.tgz -C ${SPARK_HOME} && \
    rm -f /tmp/spark.tgz && \
    chown -R root:root ${SPARK_HOME} && \
    chmod 775 ${SPARK_HOME}

RUN mkdir -p /opt/zeppelin/.cache && chmod 775 /opt/zeppelin/.cache

RUN --mount=type=bind,source=./requirements.txt,target=/tmp/requirements.txt \
    pip install -r /tmp/requirements.txt

EXPOSE 8080

ENTRYPOINT [ "/usr/bin/tini", "--" ]
WORKDIR ${ZEPPELIN_HOME}
CMD ["/start.sh" ]
