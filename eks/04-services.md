# EKS & Kubernetes Workshop - Exposing Deployment as a Service


## Create the service

Pods communicate with each other using services. The service name is the hsot name to be used to communicate with the pods. To provide the person database to other pods, e.g. our person service, we need to expose the pod using a service.

Please review the file `person-db-service.yaml` and appy it using
```
kubectl apply -f person-db-service.yaml
```

List the existing services using 
```
kubectl get service
```
```
NAME        TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
person-db   ClusterIP   172.20.82.39   <none>        5432/TCP   2m5s
```

Please review the service using
```
kubectl describe service person-db
```
You should see 1 endpoint available for the service. This is the ip (of the pod) and port, where the traffic comming to the service will be routed.
```
Endpoints:         10.0.35.87:5432
```

## Test the service

You can test the service by cteating a temporary test pod with postgresql client and call the database using the service name.
```
kubectl run person-db-test -it --rm --restart Never --image docker.io/postgres:16 --env PGPASSWORD=postgres  -- psql -h person-db -U postgres person -c 'select * from person;'
```
You should see the data in the database.


---
---

## (Optional) Expose service using imperative command

You can create a service for the given deployment using following command

```
kubectl expose deployment person-db --name person-db --port 5432
```