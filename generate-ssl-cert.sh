#!/bin/bash

# Shared variables
PW="password"

# CA variables
CA_COUNTRY="DE"
CA_STATE="BW"
CA_LOCALITY="Karlsruhe"
CA_ORG_NAME="CA Provider GmbH"
CA_ORG_UNIT="CA responsible"
# IDP (Keycloak) variables
IDP_COUNTRY="DE"
IDP_STATE="BY"
IDP_LOCALITY="Muenchen"
IDP_ORG_NAME="IDP Security Provider Inc"
IDP_ORG_UNIT="Keycloak Dept"
IDP_SERVER_CN="keycloak"
# Identity client variables
USER_COUNTRY="DE"
USER_STATE="BY"
USER_LOCALITY="Muenchen"
USER_ORG_NAME="Camunda"
USER_ORG_UNIT="Identity"
USER_SERVER_CN="identity"
USER_EMAIL_ADDRESS="identity@camunda.com"

WORKDIR=$(pwd)
SSL_CONFIGS=$WORKDIR/ssl_configs

function generate_root_ca() {
    # Generate new CA key and certificate
    cd $SSL_CONFIGS
    openssl req -x509 -sha256 -days 3650 -newkey rsa:4096 -keyout rootCA.key -out rootCA.crt -subj "/C=$CA_COUNTRY/ST=$CA_STATE/L=$CA_LOCALITY/O=$CA_ORG_NAME/OU=$CA_ORG_UNIT/CN=Root CA" -passout pass:$PW
}

function generate_keycloak_cert() {
    cd $SSL_CONFIGS/keycloak/certs
    # Generate new Keycloak key and certificate
    openssl req -new -newkey rsa:4096 -keyout keycloak.key -out keycloak.csr -nodes -subj "/C=$IDP_COUNTRY/ST=$IDP_STATE/L=$IDP_LOCALITY/O=$IDP_ORG_NAME/OU=$IDP_ORG_UNIT/CN=$IDP_SERVER_CN" -passout pass:$PW
    # Define extension params for Keycloak
    cat <<EOF >keycloak.ext
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
subjectAltName = @alt_names

[alt_names]
DNS.1 = $IDP_SERVER_CN
DNS.2 = localhost
EOF
    # set keycloak ssl environment variables
    cat >$SSL_CONFIGS/keycloak/env <<EOL
KC_HTTPS_CERTIFICATE_KEY_FILE: /opt/keycloak/conf/localhost.key.pem
KC_HTTPS_CERTIFICATE_FILE: /opt/keycloak/conf/localhost.crt.pem
KC_HTTPS_TRUST_STORE_FILE: /opt/keycloak/conf/truststore.jks
KC_HTTPS_TRUST_STORE_PASSWORD: password
KC_HTTPS_CLIENT_AUTH: request
KC_LOG: console
KC_LOG_CONSOLE_LEVEL: ALL
KC_LOG_LEVEL: DEBUG
KEYCLOAK_HTTPS_PORT: 18443
EOL

    # Sign keycloak key with CA certificate
    openssl x509 -req -CA $SSL_CONFIGS/rootCA.crt -CAkey $SSL_CONFIGS/rootCA.key -in keycloak.csr -out keycloak.crt -days 365 -CAcreateserial -extfile keycloak.ext -passin pass:$PW
    # Convert keycloak certificate to PEM format
    openssl x509 -in keycloak.crt -out keycloak-crt.pem -outform PEM
    # Convert keycloak key to PEM format
    openssl rsa -in keycloak.key -out keycloak-key.pem
    # rename certificates
    mv keycloak-key.pem localhost.key.pem
    mv keycloak-crt.pem localhost.crt.pem

    # remove tmp certificates
    rm -v keycloak*

    # copy truststore.jks
    cp $SSL_CONFIGS/truststore.jks ./
    cd $SSL_CONFIGS
}

function generate_truststore() {
    # Create truststore
    cd $SSL_CONFIGS
    keytool -import -alias root.ca -file $SSL_CONFIGS/rootCA.crt -keypass $PW -keystore truststore.jks -storepass $PW -noprompt
}

function generate_identity_cert() {
    cd $SSL_CONFIGS/identity/certs
    # Create user certificate
    openssl req -new -newkey rsa:4096 -nodes -keyout identity.key -out identity.csr -subj "/emailAddress="$USER_EMAIL_ADDRESS"/C=$USER_COUNTRY/ST=$USER_STATE/L=$USER_LOCALITY/O=$USER_ORG_NAME/OU=$USER_ORG_UNIT/CN=$USER_SERVER_CN"
    # Sign user certificate with CA
    openssl x509 -req -CA $SSL_CONFIGS/rootCA.crt -CAkey $SSL_CONFIGS/rootCA.key -in identity.csr -out identity.crt -days 365 -CAcreateserial -passin pass:$PW
    # Export user certificate
    openssl pkcs12 -export -out identity.p12 -name "identity" -inkey identity.key -in identity.crt -passout pass:$PW
    # Convert identity certificate to PEM format
    openssl x509 -in identity.crt -out identity-crt.pem -outform PEM
    # Convert identity key to PEM format
    openssl rsa -in identity.key -out identity-key.pem

    cp $SSL_CONFIGS/truststore.jks ./

    cd $SSL_CONFIGS

    # set identity ssl environment variables
    cat >$SSL_CONFIGS/identity/env <<EOL
_JAVA_OPTIONS="-Djavax.net.ssl.trustStorePassword=password -Djavax.net.ssl.trustStore=/opt/security/conf/truststore.jks -Djavax.net.ssl.keyStorePassword=password -Dserver.ssl.key-store=/opt/security/conf/identity.p12 -Dserver.ssl.key-store-password=password -Djavax.net.ssl.keyStore=/opt/security/conf/identity.p12 -Dserver.ssl.trust-store=/opt/security/conf/truststore.jks -Dserver.ssl.trust-store-password=password -Djdk.internal.httpclient.disableHostnameVerification=true -Djavax.net.debug=ssl:handshake:verbose:keymanager:sslctx"
EOL
}

function set_ssl_ports() {
    cd $WORKDIR
    sed -i "" "s/18080/18443/g" .env
}

function reset_ssl_ports() {
    cd $WORKDIR
    sed -i "" "s/18443/18080/g" .env
}

function cleanup() {
    # reset ssl ports
    reset_ssl_ports

    # remove certtificates
    rm -rf $SSL_CONFIGS/keycloak/certs
    rm -rf $SSL_CONFIGS/identity/certs
    rm $SSL_CONFIGS/rootCA*
    rm $SSL_CONFIGS/truststore.jks

    # cleanup env files
    cat /dev/null >ssl_configs/keycloak/env
    cat /dev/null >ssl_configs/identity/env
}

function make_cert_structure() {
    mkdir -p $SSL_CONFIGS/keycloak/certs
    mkdir -p $SSL_CONFIGS/identity/certs
    touch $SSL_CONFIGS/keycloak/env
    touch $SSL_CONFIGS/identity/env

    set_ssl_ports
}

OPTIND=1         # Reset in case getopts has been used previously in the shell.
verbose=0
name=""

while getopts "h?ic" opt; do
    case "$opt" in
    h|\?)
        echo "Usage: $0 [-i] [-c]"
        echo "-i    initialize ssl infra"
        echo "-c    cleanup and reset ssl infra"
        exit 0
        ;;
    i)
        make_cert_structure
        generate_root_ca
        generate_truststore
        generate_keycloak_cert
        generate_identity_cert
        ;;
    c)
        cleanup
        ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift
