FROM apache/zeppelin:0.10.0
LABEL maintainer="Damian Barsotti<damian@famaf.unc.edu.ar>"

ENV S_VERSION="2.4.8"

ENV SPARK_HOME="/opt/spark"

USER root

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
    wget -nv -O /tmp/spark-${S_VERSION}-bin-hadoop2.7.tgz https://archive.apache.org/dist/spark/spark-${S_VERSION}/spark-${S_VERSION}-bin-hadoop2.7.tgz && \
    tar --strip-components=1 -zxvf /tmp/spark-${S_VERSION}-bin-hadoop2.7.tgz -C ${SPARK_HOME} && \
    rm -f /tmp/spark-${S_VERSION}-bin-hadoop2.7.tgz && \
    chown -R root:root ${SPARK_HOME} && \
    chmod 775 ${SPARK_HOME}

#CMD ["/usr/bin/screen", "-s", "/bin/bash", "bin/zeppelin.sh" ]

CMD ["/start.sh" ]
