# /bin/sh

PROJECT_ID=$1
ACCT_EMAIL=$2

gcloud projects get-iam-policy ${PROJECT_ID}  \
--flatten="bindings[].members" \
--format='table(bindings.role)' \
--filter="bindings.members:${ACCT_EMAIL}"

# add the Apigee org admin role to the K8S Service Account that is used to install K8S
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
--member user:${ACCT_EMAIL} \
--role roles/apigee.admin

export TOKEN=$(gcloud auth print-access-token)

# apigee-synchronizer@ORG_ID.iam.gserviceaccount.com

curl -X POST -H "Authorization: Bearer ${TOKEN}" \
-H "Content-Type:application/json" \
"https://apigee.googleapis.com/v1/organizations/${PROJECT_ID}:setSyncAuthorization" \
-d '{"identities":["'"serviceAccount:apigee-synchronizer@${PROJECT_ID}.iam.gserviceaccount.com"'"]}'

# Alternative Syntax
# curl -X POST -H "Authorization: Bearer $TOKEN" \
#   -H "Content-Type:application/json" \
#   "https://apigee.googleapis.com/v1/organizations/PROJECT_ID:setSyncAuthorization" \
#   -d '{"identities":["serviceAccount:apigee-synchronizer@PROJECT_ID.iam.gserviceaccount.com"]}'

echo `curl -X GET -H "Authorization: Bearer $TOKEN" -H "Content-Type:application/json" "https://apigee.googleapis.com/v1/organizations/${PROJECT_ID}:getSyncAuthorization"`


    