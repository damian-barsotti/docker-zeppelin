ARG zeppelin_version=0.12.0
FROM apache/zeppelin:${zeppelin_version}

LABEL maintainer="Damian Barsotti<damian@famaf.unc.edu.ar>"

ARG zeppelin_version
ARG spark_version=3.5.6
ARG hadoop_version="3"
ARG spark_download_url=https://archive.apache.org/dist/spark

ENV SPARK_HOME="/opt/spark"

USER root

RUN find -name \._\* -type f -exec rm -f {} \; || true

COPY ./start.sh /start.sh

RUN chmod 755 /start.sh

RUN apt-get update -q && \
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

RUN chmod 775 /opt/zeppelin/.cache

RUN --mount=type=bind,source=./requirements.txt,target=/tmp/requirements.txt \
    pip install -r /tmp/requirements.txt

RUN DEBIAN_FRONTEND=noninteractive apt-get install -yq sudo

# RUN echo "zeppelin ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/zeppelin

RUN sudo adduser --quiet --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password damian

RUN sudo adduser --quiet --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password user1

RUN sudo adduser --quiet --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password user2

# RUN mv /opt/zeppelin/notebook /tmp/

# RUN mkdir /opt/zeppelin/notebook

# RUN cp -a /tmp/notebook /opt/zeppelin/notebook/user1
# RUN cp -a /tmp/notebook /opt/zeppelin/notebook/user2
# RUN rm -rf /tmp/notebook

COPY ./bin/interpreter.sh /opt/zeppelin/bin/

# CMD ["/start.sh" ]
