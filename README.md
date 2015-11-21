=keycloak-docker=
======
 - Docker image for the Keycloak auth server ``1.6.1 Final``
 - This image comes with a **postgres** database (instead of the native **h2**)
 - HTTPS (SSL) is supported, so **Keycloak** can be easily deployed to the cloud (EC2, Azure, etc.)
 
----

#### 1. Prerequisites
 - [Docker](https://gist.github.com/maslick/69291bd5ed649892fe1b)
 - [Docker-compose](https://gist.github.com/maslick/5f77efa8ba0f8df98548)


#### 2. Installation
 ```
 $ ./ssl.sh
 $ ./build.sh
 $ ./compose.sh
 ```
 This will:
- Generate a self-signed ssl certificate and deploy it to the keystore (see ``ssl.sh`` and [keycloak docs](http://docs.jboss.org/keycloak/docs/1.2.0.Beta1/userguide/html_single/index.html#d4e278) for more details)
- Build the docker image
- Run postgres and keycloak using ``docker-compose``
 
#### 3. Run
Go to this address in your browser:
```
https://{your_host}/auth
```

