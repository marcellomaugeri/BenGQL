FROM maven:3.9.10-eclipse-temurin-8-alpine

RUN apk add --no-cache git

RUN git clone https://github.com/WebFuzzing/EMB.git
WORKDIR /EMB
RUN git checkout f234ece5101e2e72ea66665eed90d5bd886f53cb

WORKDIR /EMB/jdk_8_maven/cs/graphql/graphql-scs
RUN mvn clean package

RUN mv target/ /target/
WORKDIR /target
RUN rm -rf /EMB

CMD [ "java", "-jar", "/target/graphql-scs-sut.jar" ]
