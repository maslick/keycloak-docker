FROM jboss/keycloak:6.0.1

# setup SSL
USER root
RUN yum install xmlstarlet -y
ADD keycloak.jks $JBOSS_HOME/standalone/configuration/
RUN chown jboss:jboss $JBOSS_HOME/standalone/configuration/keycloak.jks
USER jboss

# 1. add keycloak.jks to security realm
RUN sed -i -e '0,/RE/s/<security-realms>/&\n            <security-realm name="UndertowRealm">\n                <server-identities>\n                    <ssl>\n                        <keystore path="keycloak.jks" relative-to="jboss.server.config.dir" keystore-password="secret"\/>\n                    <\/ssl>\n                <\/server-identities>\n            <\/security-realm>\n/' $JBOSS_HOME/standalone/configuration/standalone-ha.xml

# 2. remove https-listener
RUN xmlstarlet ed -L -d "//*[local-name()='https-listener']" $JBOSS_HOME/standalone/configuration/standalone-ha.xml

# 3. add https-listener with Undertow security realm
RUN sed -i -e 's/<server name="default-server">/&\n                <https-listener name="https" socket-binding="https" security-realm="UndertowRealm" enable-http2="true"\/>\n/' $JBOSS_HOME/standalone/configuration/standalone-ha.xml

# 4. change host attribute to UndertowRealm
RUN xmlstarlet ed -L -u "//*[local-name()='server']/*[local-name()='host']/*/@security-realm" -v "UndertowRealm" $JBOSS_HOME/standalone/configuration/standalone-ha.xml