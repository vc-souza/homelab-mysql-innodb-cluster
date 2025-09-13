ARG BASE="debian:bookworm-slim"
ARG ROUTER_HOME="/var/lib/mysqlrouter"

FROM ${BASE}

ARG ROUTER_HOME

RUN groupadd \
        -g 999 \
        --system \
        mysqlrouter \
    && useradd \
        -u 999 \
        -g 999 \
        --no-create-home \
        --no-user-group \
        --system \
        --shell /bin/false \
        --home-dir ${ROUTER_HOME} \
        --comment 'MySQL Router' \
        mysqlrouter \
    && mkdir -p ${ROUTER_HOME} \
    && apt-get -y update \
    && apt-get install -y gnupg \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys A8D3785C \
    && echo "deb http://repo.mysql.com/apt/debian/ bookworm mysql-8.4-lts" > /etc/apt/sources.list.d/mysql.list \
    && apt-get -y update \
    && apt-get install -y mysql-router mysql-client

# classic R/W
EXPOSE 6446
# classic R/O
EXPOSE 6447
# X R/W
EXPOSE 6448
# X R/O
EXPOSE 6449
# classic R/W-splitting
EXPOSE 6450
# REST HTTPS API
EXPOSE 8443

RUN chown -R 999:999 ${ROUTER_HOME}

COPY ./router/docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=999:999 ./scripts/router/ /scripts/

VOLUME ${ROUTER_HOME}

WORKDIR ${ROUTER_HOME}

USER 999:999

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "mysqlrouter" ]
