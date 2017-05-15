# vim:set ft=dockerfile:
FROM postgres:9.5

ENV PG_MAJOR 9.5
ENV PG_VERSION 9.5.6-1.pgdg80+1

# RUN mkdir /docker-entrypoint-initdb.d

RUN set -ex; \
# pub   4096R/ACCC4CF8 2011-10-13 [expires: 2019-07-02]
#       Key fingerprint = B97B 0AFC AA1A 47F0 44F2  44A0 7FCC 7D46 ACCC 4CF8
# uid                  PostgreSQL Debian Repository
	key='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8'; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	gpg --export "$key" > /etc/apt/trusted.gpg.d/postgres.gpg; \
	rm -r "$GNUPGHOME"; \
	apt-key list


RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' $PG_MAJOR > /etc/apt/sources.list.d/pgdg.list

RUN apt-get update \
	&& apt-get install -y \
		postgresql-server-dev-$PG_MAJOR \
		pgxnclient \
		ca-certificates \
		gcc \
		make \
	&& rm -rf /var/lib/apt/lists/*

RUN pgxnclient install temporal_tables

RUN apt-get purge -y --auto-remove ca-certificates gcc make

COPY temporal_tables.sql /docker-entrypoint-initdb.d/

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 5432
CMD ["postgres"]
