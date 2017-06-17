FROM vault:0.7.3

COPY config.hcl /vault/config/

RUN mkdir -p /vault/data \
    && chown -R vault:vault /vault/data

CMD [ "server" ]
