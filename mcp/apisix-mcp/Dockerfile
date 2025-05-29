FROM debian:12.10-slim

WORKDIR /data

COPY bin /data/bin

RUN bin/apisix_deps.sh && \
    mv bin/entrypoint.sh .

COPY --from=apache/apisix-dashboard:latest /usr/local/apisix-dashboard /usr/local/apisix-dashboard

ENTRYPOINT ["./entrypoint.sh"]
