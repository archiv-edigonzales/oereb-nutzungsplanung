FROM crunchydata/crunchy-postgres-gis:centos7-11.2-2.3.1

LABEL maintainer="Stefan Ziegler stefan.ziegler.de@gmail.com"

USER root

RUN localedef -c -i de_CH -f UTF-8 de_CH.UTF-8
COPY pgconf/* /pgconf/

USER 26

HEALTHCHECK --interval=5s --timeout=120s --start-period=15s --retries=5 CMD ["/usr/pgsql-11/bin/pg_isready", "--host=localhost", "-U postgres"] || exit 1

