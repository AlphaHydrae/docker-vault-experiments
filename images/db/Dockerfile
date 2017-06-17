FROM postgres:9.6-alpine

RUN apk add --update curl \
    && rm -rf /var/cache/apk/*

RUN curl -sSLo /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 \
    && chmod +x /usr/local/bin/jq

COPY entrypoint.sh /usr/local/bin/db-entrypoint.sh
COPY scripts/ /docker-entrypoint-initdb.d/

ENTRYPOINT [ "/usr/local/bin/db-entrypoint.sh" ]
CMD [ "postgres" ]
