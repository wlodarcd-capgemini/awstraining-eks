# EKS & Kubernetes Workshop - Application Deployment

## Deploy the application

You have now the database running and know how to deploy and configure pods in Kubernetes. Now you need to deploy the application.

Please review the `person-service-deployment-v1.yaml` file and apply it
``` 
kubectl apply -f person-service-deployment-v1.yaml
```

You can check the pod is up and running
```
kubectl get pods
```
```
NAME                              READY   STATUS    RESTARTS        AGE
person-db-6b7bcc8d4b-5npsl        1/1     Running   0               7m18s
person-service-66f7dff787-wn9pq   1/1     Running   0               17s
```

Check the logs of the application using `kubectl logs` command.

# Deploy the service

Please review the file `person-service-service.yaml` containinmg the definition of the service and apply it
```
kubectl apply -f person-service-service.yaml
```

Using the command `kubectl describe service person-service` you should check whether there is 1 endpoint available for the service.

## Test the application

The application provides 2 rest services
* `/hello`
* `/person`

Please test the `/hello` service by creating a temporary pod and call the service
```
kubectl run test -it --rm --restart Never --image docker.io/redhat/ubi9 -- curl person-service:8080/hello
```
You should get the result
```
This is the default greeting from application.properties
```

Please test the `/person` service by creating a temporary pod and call the service
```
kubectl run test -it --rm --restart Never --image docker.io/redhat/ubi9 -- curl person-service:8080/person
```
You should get the result
```
[{"id":1,"firstName":"Bobby","lastName":"Brown","salutation":"Mr"}]
```

## Scale the application

You can scale the aplication to provide more pods to process the requests. The traffic comming into the service will be dispatched to the pods using the round-robin strategy.

You can scale the deployment using
```
kubectl scale deployment person-service --replicas 3
```

You should ses 3 pods available for the application
```
kubectl get pods
```
```
NAME                              READY   STATUS    RESTARTS        AGE
person-db-6b7bcc8d4b-5npsl        1/1     Running   0               7m18s
person-service-66f7dff787-bfcq7   1/1     Running   0             45s
person-service-66f7dff787-twwsj   1/1     Running   0             45s
person-service-66f7dff787-wn9pq   1/1     Running   0             20m
```

Describing the service you should see 3 endpoints available for the service
```
kubectl describe service person-service 
```
```
...
Endpoints:         10.0.35.87:8080,10.0.38.20:8080,10.0.41.183:8080
...
```

---
---

## (Optional) Modify application configuration using environemnt variables

The deplyed application defines following configuration parameter in `application.properties` file
```
app.greeting=This is the default greeting from application.properties
```
When you test the application using following command
```
kubectl run test -it --rm --restart Never --image docker.io/redhat/ubi9 -- curl person-service:8080/hello
```
you should get following result
```
This is the default greeting from application.properties
```

You can override the parameters for Quarkus or Spring Boot applications by setting a proper environment variable, in this case `APP_GREETING`.

Please set the variable (with value `This is a greeting from an environment variable`) using one of the following methods
* Modify the yaml file you have applied previously, add the env variable and apply it
* Create a patch file containing the variable and apply it
* Use the imperative command

To use the imperative command perform this
```
kubectl set env deployment person-service APP_GREETING="This is a greeting from an environment variable"
```

Wait, until the new pod is created and is in `Running` state. Now, when you test the application
```
kubectl run test -it --rm --restart Never --image docker.io/redhat/ubi9 -- curl person-service:8080/hello
```
you should get following result
```
This is a greeting from an environment variable
```


## (Optional) Deploy the application using the imperative commands

Please perform following commands to deploy the application and expose the service

```
kubectl create deployment person-service --image quay.io/ksobkowiak/eks-wks-person-service:latest --replicas 0

kubectl set env deployment person-service --from=secret/person-secret --prefix=DB_

kubectl set env deployment person-service --from=configmap/person-configmap --prefix=DB_
kubectl scale deployment person-service --replicas 1

kubectl expose deployment person-service --name person-service --port 8080
```