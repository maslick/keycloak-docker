FROM jboss/base-jdk:8

ENV KEYCLOAK_VERSION 1.9.7.Final


USER root
RUN mkdir /data && touch /data/keycloak.json && chown jboss:jboss /data/keycloak.json

USER jboss

# Download Keycloak and unzip
RUN cd /opt/jboss/ && curl http://downloads.jboss.org/keycloak/$KEYCLOAK_VERSION/keycloak-$KEYCLOAK_VERSION.tar.gz | tar zx && mv /opt/jboss/keycloak-$KEYCLOAK_VERSION /opt/jboss/keycloak

# switch to standalone-full
ADD setLogLevel.xsl /opt/jboss/keycloak/
RUN java -jar /usr/share/java/saxon.jar -s:/opt/jboss/keycloak/standalone/configuration/standalone.xml -xsl:/opt/jboss/keycloak/setLogLevel.xsl -o:/opt/jboss/keycloak/standalone/configuration/standalone.xml

# add admin user
RUN /opt/jboss/keycloak/bin/add-user-keycloak.sh -r master -u admin -p admin
ENV JBOSS_HOME /opt/jboss/keycloak

# setup postgres database instead of h2
ENV DB_CONNECTOR_VERSION 9.4-1201-jdbc41

ADD changeDatabase.xsl /opt/jboss/keycloak/
RUN java -jar /usr/share/java/saxon.jar -s:/opt/jboss/keycloak/standalone/configuration/standalone.xml -xsl:/opt/jboss/keycloak/changeDatabase.xsl -o:/opt/jboss/keycloak/standalone/configuration/standalone.xml; java -jar /usr/share/java/saxon.jar -s:/opt/jboss/keycloak/standalone/configuration/standalone-ha.xml -xsl:/opt/jboss/keycloak/changeDatabase.xsl -o:/opt/jboss/keycloak/standalone/configuration/standalone-ha.xml; rm /opt/jboss/keycloak/changeDatabase.xsl
RUN mkdir -p /opt/jboss/keycloak/modules/system/layers/base/org/postgresql/jdbc/main; cd /opt/jboss/keycloak/modules/system/layers/base/org/postgresql/jdbc/main; curl -O http://central.maven.org/maven2/org/postgresql/postgresql/$DB_CONNECTOR_VERSION/postgresql-$DB_CONNECTOR_VERSION.jar
ADD module.xml /opt/jboss/keycloak/modules/system/layers/base/org/postgresql/jdbc/main/

# setup SSL
USER root
ADD keycloak.jks $JBOSS_HOME/standalone/configuration/
RUN chown jboss:jboss $JBOSS_HOME/standalone/configuration/keycloak.jks
USER jboss
RUN sed -i -e 's/<security-realms>/&\n            <security-realm name="UndertowRealm">\n                <server-identities>\n                    <ssl>\n                        <keystore path="keycloak.jks" relative-to="jboss.server.config.dir" keystore-password="secret" \/>\n                    <\/ssl>\n                <\/server-identities>\n            <\/security-realm>/' $JBOSS_HOME/standalone/configuration/standalone.xml
RUN sed -i -e 's/<server name="default-server">/&\n                <https-listener name="https" socket-binding="https" security-realm="UndertowRealm"\/>/' $JBOSS_HOME/standalone/configuration/standalone.xml

EXPOSE 8080

USER root

# export database into json file on reboot
CMD ["/opt/jboss/keycloak/bin/standalone.sh", "-b", "0.0.0.0" , "-bmanagement", "0.0.0.0", "-Dkeycloak.migration.action=export", "-Dkeycloak.migration.provider=singleFile", "-Dkeycloak.migration.file=/data/keycloak.json"]
