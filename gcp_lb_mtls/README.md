# mTLS configuration for Apigee Hybrid Ingress for North and Southbound traffic 

This README describes how to configure [mTLS for Apigee Hybrid](https://cloud.google.com/apigee/docs/hybrid/v1.11/ingress-tls).

## Create Northbound mTLS

### Create a new Apigee Hybrid Environment
I completed these steps in my Cloud Shell environment. 

**You can skip this step if you already created an Apigee Envionment.**

1. Create a new Apigee Hybrid Environment by following these [steps](https://cloud.google.com/apigee/docs/hybrid/v1.11/environment-create)

2. Generate [new certificate](https://cloud.google.com/apigee/docs/hybrid/v1.11/environment-self-signed-tls).

```shell
export DOMAIN=DOMAIN
openssl req  -nodes -new -x509 -keyout ./certs/keystore_hybrid_mtls.key -out \
    ./certs/keystore_hybrid_mtls.pem -subj "/CN=$DOMAIN" -days 3650
```

3. Update `overrides.yaml` file.  However, for my `overrides.yaml` file I modified it by adding the following items.

```yaml
virtualhosts:
- name: hybrid-mtls-group # should be the Apigee Env Group Name
  selector:
    app: apigee-ingressgateway
    ingress_name: apigee-hybridmtls
  sslCertPath: certs/keystore_hybrid_mtls.pem
  sslKeyPath:  certs/keystore_hybrid_mtls.key

envs:
- name: hybrid-mtls-env

ingressGateways:
- name: apigee-hybridmtls # maximum 17 characters.
  replicaCountMin: 2
  replicaCountMax: 10
  svcType: ClusterIP # adding this because I added a publicly accessible LB
```

Create a new `apigee-ingress.yaml` named `apigee-ingress-mtls.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: apigee-nonprod-mtls
  namespace: apigee
spec:
  ports:
  - name: status-port
    port: 15021
    protocol: TCP
    targetPort: 15021
  - name: https
    port: 443
    protocol: TCP
    targetPort: 8443
  selector:
    app: apigee-ingressgateway #required
    ingress_name: apigee-hybridmtls
    org: MYORGID
  type: LoadBalancer
  loadBalancerIP: MYIP  #kubectl get svc -n apigee -l app=apigee-ingressgateway
```

4. Connect to the cluster. Google Cloud Console will give you the CLI command for your cluster and environment.

```shell
gcloud container clusters get-credentials CLUSTER_NAME --region CLUSTER_REGION --project PROJECT_ID
```

5. Apply the changes with Helm. 

```shell
export ENV_NAME=NAME
helm upgrade $ENV_NAME apigee-env/ \
  --install \
  --namespace apigee \
  --atomic \
  --set env=$ENV_NAME \
  -f overrides.yaml
```

6.  Once you execute the command above, then the output will list several other IAM commands that you must execute as well.

7. Install the Virtual Hosts.
```shell
export ENVGROUP=GROUP
helm upgrade $ENVGROUP apigee-virtualhost/ \
  --install \
  --namespace apigee \
  --atomic \
  --set envgroup=$ENVGROUP \
  -f overrides.yaml
```

8. Create the Apigee Ingress Service with the config file that you created in step 3. 

```shell
kubectl apply -f apigee-ingress-mtls.yaml
```

Check that the service was created.
```shell
kubectl get service apigee-nonprod-mtls  -n apigee
```

```shell
NAME                  TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)                         AGE
apigee-nonprod-mtls   LoadBalancer   10.x.x.x       x.x.x.x        15021:31900/TCP,443:32226/TCP   45s
```

9. Update the org and make sure to execute the iam gcloud commands returned in the output.

```shell
export ORG_NAME=org
helm upgrade $ORG_NAME apigee-org/ \
  --namespace apigee \
  --atomic \
  -f overrides.yaml
```

#### Troubleshooting
* [TLS Errors](https://cloud.google.com/apigee/docs/api-platform/troubleshoot/playbooks/ingressgateway/api-calls-failing-tls-errors)


### Configure mTLS for the Environment
mTLS configuration is described [here](https://cloud.google.com/apigee/docs/hybrid/v1.11/ingress-tls#option-1:-keycert-pair-and-ca-file).

1. [Create a Root CA with intermediate certs](https://cloud.google.com/load-balancing/docs/https/setting-up-mtls-ccm#generate_a_key_and_signed_certificates)

```shell
cat > apigee-client-example.cnf << EOF
[req]
distinguished_name = empty_distinguished_name
[empty_distinguished_name]
# Kept empty to allow setting via -subj command line arg.
[ca_exts]
basicConstraints=critical,CA:TRUE
keyUsage=keyCertSign
extendedKeyUsage=clientAuth
EOF
```

Create root cert
```shell
openssl req -x509 \
    -new -sha256 -newkey rsa:2048 -nodes \
    -days 3650 -subj '/CN=root' \
    -config apigee-client-example.cnf \
    -extensions ca_exts \
    -keyout apigee-mtls-client-root.key -out apigee-mtls-client-root.cert
```

create signing request
```shell
openssl req \
    -new -sha256 -newkey rsa:2048 -nodes \
    -subj '/CN=int' \
    -config apigee-client-example.cnf \
    -extensions ca_exts \
    -keyout int.key -out int.req
```

create intermediate cert.
```shell
openssl x509 -req \
    -CAkey apigee-mtls-client-root.key -CA apigee-mtls-client-root.cert \
    -set_serial 1 \
    -days 3650 \
    -extfile apigee-client-example.cnf \
    -extensions ca_exts \
    -in int.req -out int-apigee-client.cert
```

Create the client private key, create the CSR, sign it.
```shell
openssl genrsa -out myclient.key 2048 
openssl req -new -key myclient.key -out myclient.csr
openssl x509 -req \
    -CAkey int.key -CA int-apigee-client.cert \
    -set_serial 1 \
    -days 3650 \
    -extfile apigee-client-example.cnf \
    -extensions ca_exts \
    -in myclient.csr -out myclient.cert

# optional 
openssl x509 -in myclient.cert -text -noout

```

#### Confirm mTLS works with openssl

If you get an error at the end of the output with `openssl Alert 47`, then this is likely due to TLS version incompatibility.
```shell
openssl s_client -connect DOMAIN:443 -cert apigee-example-client-mtls-certs/myclient.cert -key apigee-example-client-mtls-certs/myclient.key  -CAfile apigee-hybrid/helm-charts/apigee-virtualhost/certs/keystore_hybrid_mtls.pem
```

Output with error below.
```shell
Verify return code: 0 (ok)
---
139702167307584:error:14094417:SSL routines:ssl3_read_bytes:sslv3 alert illegal parameter:../ssl/record/rec_layer_s3.c:1562:SSL alert number 47
```


Try the command again with `-tls1_2` and it should succeed without any errors displayed at the end of the output.
```shell
openssl s_client -connect DOMAIN:443 -cert apigee-example-client-mtls-certs/myclient.cert -key apigee-example-client-mtls-certs/myclient.key  -CAfile apigee-hybrid/helm-charts/apigee-virtualhost/certs/keystore_hybrid_mtls.pem -tls1_2
```


**This creates a self signed certificate. No need to use this command; use the commands above.**
```shell
openssl req -x509 \
    -new -sha256 -newkey rsa:2048 -nodes \
    -days 3650 -subj '/CN=myclient' \
    -config apigee-client-example.cnf \
    -extensions ca_exts \
    -keyout myclient.key -out myclient.cert
```


#### Continue Updating Apigee Hybrid Environment
2. Create the bundle `ca-bundle.pem` file with the root cert listed last.

3. Update the `overrides.yaml` file with the Certificate Authority Bundle file.

```yaml
virtualhosts:
- name: hybrid-group2 # should be the Apigee Env Group Name
  selector:
    app: apigee-ingressgateway
    ingress_name: apigee-hybridmtls
  tlsMode: MUTUAL
  caCertPath: certs/ca-bundle.pem
  sslCertPath: certs/keystore_hybrid_mtls.pem
  sslKeyPath:  certs/keystore_hybrid_mtls.key
```

4. Apply the changes. 

```shell
export ORG_NAME=org
helm upgrade $ORG_NAME apigee-org/ \
  --namespace apigee \
  --atomic \
  -f overrides.yaml
```

5. Apply the changes with Helm. 

```shell
export ENV_NAME=NAME
helm upgrade $ENV_NAME apigee-env/ \
  --install \
  --namespace apigee \
  --atomic \
  --set env=$ENV_NAME \
  -f overrides.yaml
```

6.  Once you execute the command above, then the output will list several other IAM commands that you must execute as well.

7. Install the Virtual Hosts.
```shell
export ENVGROUP=GROUP
helm upgrade $ENVGROUP apigee-virtualhost/ \
  --install \
  --namespace apigee \
  --atomic \
  --set envgroup=$ENVGROUP \
  -f overrides.yaml
```


#### Test the updated connection.

If you are using the hello world test proxy then send the following command.

```shell
export DOMAIN=YOURDOMAIN
curl https://$DOMAIN/hello?apikey=YOUR_APIKEY -k -w "\n"
```

You should receive the following error message. 
```shell
curl: (56) LibreSSL SSL_read: LibreSSL/3.3.6: error:1404C45C:SSL routines:ST_OK:reason(1116), errno 0
```

##### You can also use OpenSSL to test that a certificate is now required.
```shell
openssl s_client -connect $DOMAIN:443
```

##### You can also use OpenSSL to test that a certificate is now required.
```shell
openssl s_client -connect $DOMAIN:443
```
You should see something like the following. 
```shell
...

138578324809024:error:1409445C:SSL routines:ssl3_read_bytes:tlsv13 alert certificate required:../ssl/record/rec_layer_s3.c:1562:SSL alert number 116
```
#### Send Curl Request with private cert

```shell
export DOMAIN=YOURDOMAIN
curl --cert myclient.cert --key myclient.key --cacert ca.crt https://$DOMAIN/hello?apikey=YOUR_APIKEY -k -w "\n"
```

Curl command with TLS version specified.
```shell
curl --http1.1 --cert myclient.cert --key myclient.key --cacert ca.crt https://$DOMAIN/hello?apikey=YOUR_APIKEY -k -w "\n"
```

## Configure Southbound mTLS

TODO