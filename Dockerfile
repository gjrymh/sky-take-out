FROM maven:3.9.9-eclipse-temurin-17 AS builder

WORKDIR /workspace

COPY pom.xml .
COPY sky-common/pom.xml sky-common/pom.xml
COPY sky-pojo/pom.xml sky-pojo/pom.xml
COPY sky-server/pom.xml sky-server/pom.xml

COPY sky-common/src sky-common/src
COPY sky-pojo/src sky-pojo/src
COPY sky-server/src sky-server/src

RUN mvn -B -ntp \
    -pl sky-server \
    -am \
    clean package \
    -DskipTests

FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

RUN groupadd --system spring \
    && useradd \
       --system \
       --gid spring \
       --home-dir /app \
       --shell /usr/sbin/nologin \
       spring

COPY --from=builder \
    --chown=spring:spring \
    /workspace/sky-server/target/sky-server-1.0-SNAPSHOT.jar \
    /app/app.jar

USER spring:spring

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
