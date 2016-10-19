FROM docker.dev.pardot.com/base/bread/node:0.10
MAINTAINER pd-bread@salesforce.com
RUN apt-get update \
  && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libicu-dev \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /var/cache
RUN npm install -g coffeelint jslint
RUN mkdir -p /app
WORKDIR /app
COPY package.json /app/package.json
COPY npm-shrinkwrap.json /app/npm-shrinkwrap.json
COPY script/bootstrap /app/script/bootstrap
RUN npm install
CMD ["script/server"]
COPY . /app
