# Helloworld Target Server - GKE

This example demonstrates how to deploy a Helloworld target server to GKE.

## Setup
1. Create a new GKE cluster in the on the same network as the Apigee cluster.
2. Connect to the K8S Cluster and obtain the credentials using Cloud Shell.
3. You can create helloworld target server with the following command.
```shell
kubectl create deployment hello-server --image=us-docker.pkg.dev/google-samples/containers/gke/hello-app:1.0
```

4. Expose the service with an internal load balancer.  This will create an Internal TCP load balancer.
```shell
kubectl apply -f helloworld-service-ilb.yaml
```

5. You can configure DNS to avoid specifying the IP address in the Apigee Target Endpoint.

### Apigee Proxy
1. You must create a target server named `hello-gke` in the Apigee Hybrid environment before you deploy the Apigee proxy. Use the domain name that you configured for your hello target server or use the Services Ingress IP address. 
2. Deploy the Apigee Proxy to the Apigee Hybrid environment. 


### Cloud DNS
I created a producer project that has a DNS server configured for my domain. I created a DNS peering zone in the hybrid project to lookup domain names in my DNS producer project, so that I can use a domain name in the Apigee Target server.  

### TODOs
1. Enable TLS on GKE target server and Internal Load Balancer.