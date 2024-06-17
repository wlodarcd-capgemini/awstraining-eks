# EKS & Kubernetes Workshop - Config Maps & Secrets

## Create config map and secret

While creating the database pod you have set some configuration parameters to configure the database name, user and password. The parameters are set as environmebnt variables. You can set the values in a config map and secret and attach them as environment variables in the deployment. When other pod (e.g. the person service you will deploy in the next steps) will need the information to be able to connect to the database, the same secrets can be attached to the pod to provide the informations.

Please create a config map with the database name and database host name. Review the file `person-configmap.yaml` and apply it
```
kubectl apply -f person-configmap.yaml
```

You can list available config maps using
```
kubectl get configmaps
```
```
NAME               DATA   AGE
person-configmap   2      2m31s
```

Please create the secret containing user and password for the database. Review the file `person-secret.yaml`. You can see the values are base64 encoded in this file.

Apply the file
```
kubectl apply -f person-secret.yaml
```

You can list available secrets using
```
kubectl get secrets
```
```
NAME            TYPE     DATA   AGE
person-secret   Opaque   2      2m14s
```

## Attach config map and secret as environment variables

Now you can attach the config map and secret as environment variables in the deployment. Please review the file `person-db-deployment-v3.yaml` and appy it
```
kubectl apply -f person-db-deployment-v3.yaml
```

Wait until the new pod is created and is in status `Running`

---

## (Optional) Create config map and secret using imperative commands

In the previous steps you have created the objects using declarative way from yaml file. You can do the same using imperative way

Create the config map
```
kubectl create configmap person-configmap --from-literal db=person --from-literal host=person-db
```

Create the secret
```
kubectl create secret generic person-secret --from-literal user=postgres --from-literal password=postgres
```