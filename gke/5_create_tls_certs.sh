# /bin/sh
ENV_GROUP=apigee-hybrid-group
DOMAIN=test.domain.com

mkdir $APIGEE_HELM_CHARTS_HOME/certs
mkdir $APIGEE_HELM_CHARTS_HOME/apigee-virtualhost/certs

openssl req  -nodes -new -x509 -keyout $APIGEE_HELM_CHARTS_HOME/apigee-virtualhost/certs/keystore_$ENV_GROUP.key -out \
    $APIGEE_HELM_CHARTS_HOME/certs/keystore_$ENV_GROUP.pem -subj '/CN='$DOMAIN'' -days 3650