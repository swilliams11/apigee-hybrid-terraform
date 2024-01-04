# /bin/sh
ENV_GROUP=apigee-hybrid-group
DOMAIN=test.domain.com
APIGEE_HELM_CHARTS_HOME=$1

echo "copy overrides.yaml to helm charts home directory."
cp ./overrides.yaml ~/$APIGEE_HELM_CHARTS_HOME/

