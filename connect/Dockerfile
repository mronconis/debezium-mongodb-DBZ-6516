ARG STRIMZI_VERSION

FROM quay.io/strimzi/kafka:${STRIMZI_VERSION}

ENV KAFKA_CONNECT_PLUGIN_PATH=/tmp/connect-plugins

ARG DEBEZIUM_CONNECTOR_VERSION

RUN mkdir $KAFKA_CONNECT_PLUGIN_PATH &&\
    cd $KAFKA_CONNECT_PLUGIN_PATH &&\
    curl -vfSL https://repo1.maven.org/maven2/io/debezium/debezium-connector-mongodb/$DEBEZIUM_CONNECTOR_VERSION/debezium-connector-mongodb-$DEBEZIUM_CONNECTOR_VERSION-plugin.tar.gz | tar xz

COPY metrics.yml /opt/kafka/conf/prometheus-config.yml
