# This Dockerfile will build an arm64 Keycloak image that can be used in the same way
# as the docker images provided by bitnami/keycloak
ARG KEYCLOAK_VERSION=19.0.3

# Inspired by https://github.com/keycloak/keycloak/blob/main/quarkus/container/Dockerfile
# and https://github.com/bitnami/containers/blob/main/bitnami/keycloak/19/debian-11/Dockerfile
FROM registry.access.redhat.com/ubi8-minimal AS build

ARG KEYCLOAK_VERSION
ARG KEYCLOAK_DIST=https://github.com/keycloak/keycloak/releases/download/$KEYCLOAK_VERSION/keycloak-$KEYCLOAK_VERSION.tar.gz

RUN microdnf install -y tar gzip && microdnf clean all 

ADD $KEYCLOAK_DIST /tmp/keycloak/

# The next step makes it uniform for local development and upstream built.
# If it is a local tar archive then it is unpacked, if from remote is just downloaded.
RUN (cd /tmp/keycloak && \
    tar -xvf /tmp/keycloak/keycloak-*.tar.gz && \
    rm /tmp/keycloak/keycloak-*.tar.gz) || true

RUN mv /tmp/keycloak/keycloak-* /opt/keycloak && mkdir -p /opt/keycloak/data

RUN chmod -R g+rwX /opt/keycloak

FROM docker.io/bitnami/keycloak:${KEYCLOAK_VERSION} as bitnami-env

FROM registry.access.redhat.com/ubi8-minimal
ARG KEYCLOAK_VERSION
ENV LANG en_US.UTF-8

COPY --from=build --chown=1000:0 /opt/keycloak /opt/keycloak
COPY --from=bitnami-env --chown=1000:0 /opt/bitnami/scripts /opt/bitnami/scripts
RUN ln -s /opt/keycloak /opt/bitnami/keycloak

# prevent JAVA_HOME from being changed
RUN sed -i 's/export JAVA_HOME=\"\/opt\/bitnami\/java\"//' /opt/bitnami/scripts/keycloak-env.sh

RUN microdnf update -y && \
    microdnf install -y --nodocs java-11-openjdk-headless glibc-langpack-en hostname tar gzip && microdnf clean all && rm -rf /var/cache/yum/* && \
    echo "keycloak:x:0:root" >> /etc/group && \
    echo "keycloak:x:1000:0:keycloak user:/opt/keycloak:/sbin/nologin" >> /etc/passwd

# Install wait-for-port which is required by bitnami scripts
# ref: https://github.com/bitnami/containers/blob/main/bitnami/keycloak/19/debian-11/Dockerfile#L25
RUN \
    curl -SsLf "https://github.com/bitnami/wait-for-port/releases/download/v1.0.5/wait-for-port-linux-arm64.tar.gz" -O && \
    tar -zxf "wait-for-port-linux-arm64.tar.gz" && \
    rm -rf "wait-for-port-linux-arm64.tar.gz" && \
    mv ./wait-for-port-linux-arm64 /usr/bin/wait-for-port

ENV APP_VERSION="$KEYCLOAK_VERSION" \
    BITNAMI_APP_NAME="keycloak" \
    PATH="/opt/bitnami/common/bin:/opt/bitnami/java/bin:/opt/bitnami/keycloak/bin:$PATH"

USER 1000

EXPOSE 8080
EXPOSE 8443

ENTRYPOINT [ "/opt/bitnami/scripts/keycloak/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/keycloak/run.sh" ]
