import subprocess

print("Getting the K8S credentials...")
subprocess.run('gcloud container clusters get-credentials ${var.name} ; kubectl apply -f storageclass.yaml')
# subprocess.run(['kubectl', 'apply', '-f', 'storageclass.yaml'])
   