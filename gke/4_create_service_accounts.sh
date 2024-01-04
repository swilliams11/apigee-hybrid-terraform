# /bin/sh

PROJECT_ID=apigee-hybrid-terraform-test
FILE_SUFFIX="-apigee-non-prod"
#export HYBRID=apigee-hybrid
#export HELM_CHARTS=helm-charts
HOME=`pwd`
APIGEE_HELM_CHARTS_HOME="$HOME/$1"
echo "APIGEE_HELM_CHARTS_HOME: $APIGEE_HELM_CHARTS_HOME"

# change the permission on the create-service-account shell script
cp ./create-service-account -f $APIGEE_HELM_CHARTS_HOME/apigee-operator/etc/tools/create-service-account
chmod 744 $APIGEE_HELM_CHARTS_HOME/apigee-operator/etc/tools/create-service-account
ls -la $APIGEE_HELM_CHARTS_HOME/apigee-operator/etc/tools/create-service-account

# create the service accounts
$APIGEE_HELM_CHARTS_HOME/apigee-operator/etc/tools/create-service-account \
  --env non-prod \
  --dir $APIGEE_HELM_CHARTS_HOME/apigee-datastore

echo "`ls $APIGEE_HELM_CHARTS_HOME/apigee-datastore`"

cp $APIGEE_HELM_CHARTS_HOME/apigee-datastore/$PROJECT_ID$FILE_SUFFIX.json $APIGEE_HELM_CHARTS_HOME/apigee-telemetry/

cp $APIGEE_HELM_CHARTS_HOME/apigee-datastore/$PROJECT_ID$FILE_SUFFIX.json $APIGEE_HELM_CHARTS_HOME/apigee-org/

cp $APIGEE_HELM_CHARTS_HOME/apigee-datastore/$PROJECT_ID$FILE_SUFFIX.json $APIGEE_HELM_CHARTS_HOME/apigee-env/