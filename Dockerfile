FROM python:3.8-alpine

LABEL "com.github.actions.name"="S3 Sync (OIDC)"
LABEL "com.github.actions.description"="Sync a directory to an AWS S3 bucket using OIDC"
LABEL "com.github.actions.icon"="refresh-cw"
LABEL "com.github.actions.color"="green"

ENV AWSCLI_VERSION='1.18.14'

RUN pip install --quiet --no-cache-dir awscli==${AWSCLI_VERSION}

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
