FROM maven:3.3.9-jdk-8

RUN mkdir /pardriver
WORKDIR /pardriver
ADD pom.xml /pardriver/pom.xml

RUN mvn test-compile
