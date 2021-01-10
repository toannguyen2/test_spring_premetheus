FROM maven:3.6-jdk-8-slim

RUN mkdir -p \deploy\application

WORKDIR /deploy/application

ADD . .

ENTRYPOINT ["mvn", "install"]
CMD ["-DskipTests"]