ARG zeppelin_version=0.11.1
FROM apache/zeppelin:${zeppelin_version}

LABEL maintainer="Damian Barsotti<damian@famaf.unc.edu.ar>"

ARG spark_version=3.4.3
ARG hadoop_version="3"
ARG spark_download_url=https://archive.apache.org/dist/spark

ENV SPARK_HOME="/opt/spark"

USER root

RUN find -name \._\* -exec rm -f {} \; || true

# Install shell interpreter if doesn't exists
RUN --mount=type=bind,source=./sh-interpreter-setting.json,target=/tmp/sh-interpreter-setting.json \
    [ -d ./interpreter/sh ] || \
        ( \
            ./bin/install-interpreter.sh --name sh --artifact org.apache.zeppelin:zeppelin-shell:${zeppelin_version} && \
            cp /tmp/sh-interpreter-setting.json ./interpreter/sh/interpreter-setting.json && \
            chmod 775 local-repo \
        )

COPY ./start.sh /start.sh

RUN chmod 755 /start.sh

RUN apt-get update -q && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq  apt-utils && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq \
        bash-completion \
        iputils-ping \
        less \
        screen

RUN DEBIAN_FRONTEND=noninteractive apt-get install -yq mc && \
    cp /root/.bashrc /opt/zeppelin/ && \
    echo alias "mc='. /usr/share/mc/bin/mc-wrapper.sh'" >> /opt/zeppelin/.bashrc

RUN apt-get autoremove && apt-get clean

RUN echo "Download Spark binary" && \
    mkdir -p ${SPARK_HOME} && \
    wget --progress=dot:giga -O /tmp/spark.tgz ${spark_download_url}/spark-${spark_version}/spark-${spark_version}-bin-hadoop${hadoop_version}.tgz

RUN echo "Install Spark" && \
    tar --strip-components=1 -zxvf /tmp/spark.tgz -C ${SPARK_HOME} && \
    rm -f /tmp/spark.tgz && \
    chown -R root:root ${SPARK_HOME} && \
    chmod 775 ${SPARK_HOME}

#CMD ["/usr/bin/screen", "-s", "/bin/bash", "bin/zeppelin.sh" ]

CMD ["/start.sh" ]
