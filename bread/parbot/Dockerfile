FROM docker.dev.pardot.com/base/node:6
MAINTAINER pd-bread@salesforce.com

RUN npm install -g coffeelint jslint
RUN mkdir -p /app
WORKDIR /app
COPY package.json /app/package.json
COPY npm-shrinkwrap.json /app/npm-shrinkwrap.json
COPY script/bootstrap /app/script/bootstrap
RUN npm install
CMD ["script/server"]
COPY . /app
