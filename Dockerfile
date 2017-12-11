FROM registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift

ENV ZOO_USER=zookeeper \
    ZOO_BASE=/opt/zookeeper \
    ZOO_CONF_DIR=${ZOO_BASE}/conf \
    ZOO_DATA_DIR=${ZOO_BASE}/data \
    ZOO_DATA_LOG_DIR=${ZOO_BASE}/datalog \
    ZOO_PORT=2181 \
    ZOO_TICK_TIME=2000 \
    ZOO_INIT_LIMIT=5 \
    ZOO_SYNC_LIMIT=2 \
    ZOO_MAX_CLIENT_CNXNS=60

# Add a user and make dirs
#RUN set -ex; \
#    adduser -D "$ZOO_USER"; \
#    mkdir -p "$ZOO_DATA_LOG_DIR" "$ZOO_DATA_DIR" "$ZOO_CONF_DIR"; \
#    chown "$ZOO_USER:$ZOO_USER" "$ZOO_DATA_LOG_DIR" "$ZOO_DATA_DIR" "$ZOO_CONF_DIR"

#ARG GPG_KEY=D0BC8D8A4E90A40AFDFC43B3E22A746A68E327C1
ARG DISTRO_NAME=zookeeper-3.3.6

# Download Apache Zookeeper, verify its PGP signature, untar and clean up
# weitere Befehle für RUN werden nur für Zertifikatsprüfung gebraucht
#    apk add --no-cache --virtual .build-deps \
#        ca-certificates \
#       gnupg \
#       libressl; \
#    curl "https://www.apache.org/dist/zookeeper/$DISTRO_NAME/$DISTRO_NAME.tar.gz.asc"; \
#		
#    export GNUPGHOME="$(mktemp -d)"; \
#    gpg --keyserver ha.pool.sks-keyservers.net --recv-key "$GPG_KEY" || \
#    gpg --keyserver pgp.mit.edu --recv-keys "$GPG_KEY" || \
#    gpg --keyserver keyserver.pgp.com --recv-keys "$GPG_KEY"; \
#    gpg --batch --verify "$DISTRO_NAME.tar.gz.asc" "$DISTRO_NAME.tar.gz"; \
#    rm -rf "$GNUPGHOME" "$DISTRO_NAME.tar.gz.asc"; \
#    apk del .build-deps
#

RUN set -ex; \
    curl -o "$DISTRO_NAME.tar.gz" "https://www.apache.org/dist/zookeeper/$DISTRO_NAME/$DISTRO_NAME.tar.gz"; \
    tar -xzf "$DISTRO_NAME.tar.gz"; \
    mkdir -p "$ZOO_CONF_DIR" "$ZOO_DATA_DIR" "$ZOO_DATA_LOG_DIR"; \
    mv "$DISTRO_NAME/conf/"* "$ZOO_CONF_DIR"; \
    rm -rf "$DISTRO_NAME.tar.gz"; \

WORKDIR $DISTRO_NAME
VOLUME ["$ZOO_DATA_DIR", "$ZOO_DATA_LOG_DIR"]

#EXPOSE 2181 2888
EXPOSE ${ZOO_PORT} 2888

ENV PATH=$PATH:/$DISTRO_NAME/bin \
    ZOOCFGDIR=${ZOO_CONF_DIR}

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["zkServer.sh", "start-foreground"]