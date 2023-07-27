FROM alpine:latest
RUN apk --update add postgresql-client python3 py-pip jq
RUN rm -rf /var/cache/apk/*
RUN pip install --upgrade awscli

WORKDIR /src
COPY s3_pg_dump.sh /src
COPY config /src
RUN chmod +x /src/s3_pg_dump.sh

CMD /src/s3_pg_dump.sh
