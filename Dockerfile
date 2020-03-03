ARG BASE_IMAGE=alpine:3.11
FROM ${BASE_IMAGE}

ARG GLIBC_VERSION=2.30-r0
ARG GLIBC_URL=https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk
ARG GLIBC_SHA_256=7d10fc372c2829a0e9423cec3db3d2c084431ff4a4bcc4aebf1f5e6110a2a0d1

ARG JAVA_VERSION=8u241
ARG JAVA_BUILD=07
ARG JAVA_ID=1f5b5a70bf22433b84d0e960903adac8
ARG JAVA_URL=https://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}-b${JAVA_BUILD}/${JAVA_ID}/jre-${JAVA_VERSION}-linux-x64.tar.gz
ARG JAVA_SHA_256=83dfd1e916f0f903fabfd3cb6bcf6e46c14387eeb09d108ec6123f49bb3633e6

# https://github.com/opencontainers/image-spec/blob/master/annotations.md
LABEL org.opencontainers.image.licenses="MIT" \
  org.opencontainers.image.authors="Petr Drastil" \
  org.opencontainers.image.title="Hello world" \
  org.opencontainers.image.description="Hello world docker application"

# Environment
ENV HOME=/home/tomcat JAVA_HOME=/opt/jre
ENV PATH=${PATH}:${JAVA_HOME}/bin

COPY helloworld.war /usr/local/tomcat/webapps/helloworld.war

RUN set -ex \
  # Create non-root user
  && addgroup -g 1000 -S tomcat \
  && adduser -u 1000 -S tomcat tomcat -G tomcat -s /sbin/nologin \
  && chown -R tomcat:tomcat /usr/local/tomcat/webapps \
  # Package update
  && apk -U upgrade \
  && apk add --update wget \
  # Download glibc which is hard dependency of Java 8
  && wget --no-verbose --output-document /tmp/glibc.apk ${GLIBC_URL} \
  && apk add --allow-untrusted /tmp/glibc.apk \
  && echo "${GLIBC_SHA_256}  /tmp/glibc.apk" | sha256sum -c - \
  # Download Oracle Java 8
  && wget --no-verbose \
    --no-cookies \
    --no-check-certificate \
    --output-document /tmp/java.tar.gz \
    --header "Cookie: oraclelicense=accept-securebackup-cookie" ${JAVA_URL} \
  && echo "${JAVA_SHA_256}  /tmp/java.tar.gz" | sha256sum -c - \
  && tar -xzf /tmp/java.tar.gz -C /opt \
  && ln -s /opt/jre1.8.0_241 /opt/jre \
  && java -version \
  # Cleanup
  && rm -rf /tmp/* \
    /opt/jre/lib/plugin.jar \
    /opt/jre/lib/ext/jfxrt.jar \
    /opt/jre/bin/javaws \
    /opt/jre/lib/javaws.jar \
    /opt/jre/lib/desktop \
    /opt/jre/plugin \
    /opt/jre/lib/deploy* \
    /opt/jre/lib/*javafx* \
    /opt/jre/lib/*jfx* \
    /opt/jre/lib/amd64/libdecora_sse.so \
    /opt/jre/lib/amd64/libprism_*.so \
    /opt/jre/lib/amd64/libfxplugins.so \
    /opt/jre/lib/amd64/libglass.so \
    /opt/jre/lib/amd64/libgstreamer-lite.so \
    /opt/jre/lib/amd64/libjavafx*.so \
    /opt/jre/lib/amd64/libjfx*.so

EXPOSE 8080

USER 1000
WORKDIR /usr/local/tomcat/webapps
CMD ["java", "-jar", "helloworld.war"]
