FROM jboss/base-jdk:8

ENV KEYCLOAK_VERSION 1.3.1.Final


USER root
RUN mkdir /data && touch /data/apim.json && chown jboss:jboss /data/apim.json

# also install ssh server components and nodejs
RUN yum install -y epel-release && yum install -y jq && yum clean all


USER jboss

RUN cd /opt/jboss/ && curl http://central.maven.org/maven2/org/keycloak/keycloak-server-dist/$KEYCLOAK_VERSION/keycloak-server-dist-$KEYCLOAK_VERSION.tar.gz | tar zx && mv /opt/jboss//keycloak-$KEYCLOAK_VERSION /opt/jboss/keycloak

ADD setLogLevel.xsl /opt/jboss/keycloak/
# switch to standalone-full
RUN java -jar /usr/share/java/saxon.jar -s:/opt/jboss/keycloak/standalone/configuration/standalone.xml -xsl:/opt/jboss/keycloak/setLogLevel.xsl -o:/opt/jboss/keycloak/standalone/configuration/standalone.xml

# add admin user
RUN /opt/jboss/keycloak/bin/add-user.sh admin admin --silent

ENV JBOSS_HOME /opt/jboss/keycloak

# setup postgres database instead of h2
# previously 9.3-1102-jdbc3
ENV DB_CONNECTOR_VERSION 9.4-1201-jdbc41

ADD changeDatabase.xsl /opt/jboss/keycloak/
RUN java -jar /usr/share/java/saxon.jar -s:/opt/jboss/keycloak/standalone/configuration/standalone.xml -xsl:/opt/jboss/keycloak/changeDatabase.xsl -o:/opt/jboss/keycloak/standalone/configuration/standalone.xml; java -jar /usr/share/java/saxon.jar -s:/opt/jboss/keycloak/standalone/configuration/standalone-ha.xml -xsl:/opt/jboss/keycloak/changeDatabase.xsl -o:/opt/jboss/keycloak/standalone/configuration/standalone-ha.xml; rm /opt/jboss/keycloak/changeDatabase.xsl
RUN mkdir -p /opt/jboss/keycloak/modules/system/layers/base/org/postgresql/jdbc/main; cd /opt/jboss/keycloak/modules/system/layers/base/org/postgresql/jdbc/main; curl -O http://central.maven.org/maven2/org/postgresql/postgresql/$DB_CONNECTOR_VERSION/postgresql-$DB_CONNECTOR_VERSION.jar
ADD module.xml /opt/jboss/keycloak/modules/system/layers/base/org/postgresql/jdbc/main/

EXPOSE 8080

# export database into json file on reboot
CMD ["/opt/jboss/keycloak/bin/standalone.sh", "-b", "0.0.0.0" , "-bmanagement", "0.0.0.0", "-Dkeycloak.migration.action=export", "-Dkeycloak.migration.provider=singleFile", "-Dkeycloak.migration.file=/data/apim.json"]
