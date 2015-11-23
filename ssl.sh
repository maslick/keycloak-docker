#!/bin/bash

rm -f keycloak.jks

function genkey {
  keytool -genkey -noprompt \
    -alias keycloak-$1 \
    -dname "CN=$1, OU=LIIS, O=FRI, L=Pavel, S=Maslov, C=SI" \
    -keyalg RSA \
    -keystore keycloak.jks \
    -storepass secret \
    -keypass secret \
    -validity 10950
}

genkey auth.maslick.com
