=keycloak-docker=
======
 - Docker image for the Keycloak auth server ``4.8.3.Final``
 - Postgres support (instead of the default **h2**)
 - HTTPS (SSL) support, so **Keycloak** can be easily deployed to the cloud (EC2, Azure) or used locally
 
----

## 1. Prerequisites
 - [Docker](https://gist.github.com/maslick/69291bd5ed649892fe1b)
 - [Docker-compose](https://gist.github.com/maslick/5f77efa8ba0f8df98548)


## 2. Installation
 ```
 $ ./ssl.sh          // self-signed certificate
 $ ./build.sh
 $ ./compose.sh
 ```
 This will:
- Generate a self-signed ssl certificate and deploy it to the keystore (see ``ssl.sh`` and [keycloak docs](https://www.keycloak.org/docs/latest/server_installation/index.html#enabling-ssl-https-for-the-keycloak-server) for more details)
- Build the docker image
- Run postgres and keycloak using ``docker-compose``
 
## 3. Run
Go to this address in your browser:
```
https://{your_host}/auth
```
Default password ``admin:admin`` can be changed in ``docker-compose.yml``: ``KEYCLOAK_USER``, ``KEYCLOAK_PASSWORD``



## Third-party signed certificate
 1. Get certificate from www.sslforfree.com
```
* ca_bundle.crt (root and intermediate certificates)
* certificate.crt (public key)
* private.key (private key)
```

2. Create a java keystore (jks) from files acquired in step 1
```
// combine letsencrypt certificate with the issued certificate
cat certificate.crt ca_bundle.crt > fullchain.pem

// convert to PKCS12 store
openssl pkcs12 -export -in fullchain.pem -inkey private.key -name activeclouder.ijs.si -out fullchain_plus_key.p12 -password pass:secret

// convert to java keystore
keytool -importkeystore -deststorepass secret -destkeypass secret -destkeystore keycloak.jks -srckeystore fullchain_plus_key.p12 -srcstoretype PKCS12 -srcstorepass secret
```
