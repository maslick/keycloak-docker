#!/bin/bash

keytool -genkey -noprompt \
  -alias localhost \
  -dname "CN=localhost, OU=LIIS, O=FRI, L=Pavel, S=Maslov, C=SI" \
  -keyalg RSA \
  -keystore keycloak.jks \
  -storepass secret \
  -keypass secret \
  -validity 10950
