FROM docker.dev.pardot.com/base/java:8u102-jdk

ARG artifactory_host

RUN mkdir /pardriver
WORKDIR /pardriver
ADD pom.xml /pardriver/pom.xml

RUN mvn test-compile
