# /bin/sh

HOME=`pwd`
APIGEE_HELM_CHARTS_HOME=$HOME/$1
PROJECT_ID=$2
APIGEE_ENV_GROUP=$3
APIGEE_ENV=$4

cd $APIGEE_HELM_CHARTS_HOME

echo `helm upgrade operator apigee-operator/ --install --create-namespace --namespace apigee-system --atomic -f overrides.yaml --dry-run`

helm upgrade operator apigee-operator/ --install --create-namespace --namespace apigee-system --atomic -f overrides.yaml

# verify the apigee operator
result=$(helm ls -n apigee-system)
echo $result

# verify its up and running
result=$(kubectl -n apigee-system get deploy apigee-controller-manager)
echo $result

result_dry=$(helm upgrade datastore apigee-datastore/ --install --namespace apigee --atomic -f overrides.yaml --dry-run)
echo $result_dry
helm upgrade datastore apigee-datastore/ --install --namespace apigee --atomic -f overrides.yaml


result=$(kubectl -n apigee get apigeedatastore default)
echo $result


helm upgrade telemetry apigee-telemetry/ --install --namespace apigee --atomic -f overrides.yaml

result=$(kubectl -n apigee get apigeetelemetry apigee-telemetry)
echo $result

helm upgrade redis apigee-redis/ --install --namespace apigee --atomic -f overrides.yaml

result=$(kubectl -n apigee get apigeeredis default)
echo $result


helm upgrade ingress-manager apigee-ingress-manager/ --install --namespace apigee --atomic -f overrides.yaml

result=$(kubectl -n apigee get deployment apigee-ingressgateway-manager)
echo $result


helm upgrade $PROJECT_ID apigee-org/ --install --namespace apigee --atomic -f overrides.yaml

result=$(kubectl -n apigee get apigeeorg)
echo $result


helm upgrade $APIGEE_ENV apigee-env/ --install --namespace apigee --atomic --set env=$APIGEE_ENV -f overrides.yaml

result=$(kubectl -n apigee get apigeeenv)
echo $result


helm upgrade $APIGEE_ENV_GROUP apigee-virtualhost/ --install --namespace apigee --atomic --set envgroup=$APIGEE_ENV_GROUP -f overrides.yaml

result=$(kubectl -n apigee get arc)
echo $result

echo $(kubectl -n apigee get ar)