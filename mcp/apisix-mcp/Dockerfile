FROM debian:12.10-slim

WORKDIR /data

COPY bin/apisix_conf.sh /data/bin/apisix_conf.sh

RUN bin/apisix_conf.sh

COPY bin/config.template.yaml /data/config.template.yaml
COPY bin/entrypoint.sh /data/entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
