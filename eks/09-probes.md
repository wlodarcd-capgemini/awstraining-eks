# EKS & Kubernetes Workshop - Health Check (Probes)

In this module you will excercise how to inform Kubernetes about the state of the application and how Kubernetes uses the information to manage the pods.

## Prepare a test container

Please open another terminal and start a test container you will use to test the deployed application

```
kubectl run test -it --rm --restart Never --image docker.io/redhat/ubi9 -- bash
```

Type following command in the container termnal

```
while true; do curl person-service:8080/hello; done;
```

You should see the answer from the `/hello` service:

```
This is the default greeting from application.properties
This is the default greeting from application.properties
This is the default greeting from application.properties
...
```

You can also try to test the application by opening it in a browser using the ingress url and try to refresh it more times.

## Test the startup of the application

Please scale down the application deployment to 0, wait until the pod is terminated and scale it to 1 replica again

```
kubectrollout restart deployment person-service
```

Observe the result in the test container

```
curl: (7) Failed to connect to person-service port 8080: Connection refused
This is the default greeting from application.properties
curl: (7) Failed to connect to person-service port 8080: Connection refused
curl: (7) Failed to connect to person-service port 8080: Connection refused
This is the default greeting from application.properties
curl: (7) Failed to connect to person-service port 8080: Connection refused
This is the default greeting from application.properties
curl: (7) Failed to connect to person-service port 8080: Connection refused
curl: (7) Failed to connect to person-service port 8080: Connection refused
curl: (7) Failed to connect to person-service port 8080: Connection refused
curl: (7) Failed to connect to person-service port 8080: Connection refused
curl: (7) Failed to connect to person-service port 8080: Connection refused
curl: (7) Failed to connect to person-service port 8080: Connection refused
curl: (7) Failed to connect to person-service port 8080: Connection refused
...
```

Please check the status of the pods

```
kubectl get pods
```
```
NAME                              READY   STATUS        RESTARTS   AGE
person-db-6b7bcc8d4b-7x5fj        1/1     Running       0          70m
person-service-6dd8488f7d-gtq7x   1/1     Terminating   0          26s
person-service-866bc45fc8-7lz2c   1/1     Running       0          2s
```

Altough the pod is ready (`1/1`in `READY`column) you can still see `Connection refused` error in the test container terminal. After some time you should see again the successful connection in the test container. 

After the container starts and is ready Kubernetes starts to send incomming requests into this container. But The application within the container still needs some time until it initializes and is ready to process the requests. Kubernetes doesn't know about this and starts to send the requests to the container. It results with connection refused error.

Please scale the application to 3 replicas

```
kubectl scale deployment person-service --replicas 3
```

Observe the status of the pods and the result from the test container. Altough the new containers are ready, you see some `Connection refused` errors.

```
curl: (7) Failed to connect to person-service port 8080: Connection refused
This is the default greeting from application.properties
curl: (7) Failed to connect to person-service port 8080: Connection refused
curl: (7) Failed to connect to person-service port 8080: Connection refused
This is the default greeting from application.properties
curl: (7) Failed to connect to person-service port 8080: Connection refused
This is the default greeting from application.properties
curl: (7) Failed to connect to person-service port 8080: Connection refused
curl: (7) Failed to connect to person-service port 8080: Connection refused
...
```

This happens, because the new pods are ready but the application still starts in the container and is not ready to process the requests. After some time you should see only successful responses from the application. 

Please scale down the application to 1 replicas.

## Configure the Readiness Probe

Please review the file `person-service-deployment-v3.yaml` and apply it.

```
kubectl apply -f person-service-deployment-v3.yaml
```

Wait until the pod is up and running. Repeat the same procedure with rollout restart as above.

```
kubectrollout restart deployment person-service
```

After you have configured the Readiness Probe, Kubernetes has a mechanism to check whether the application inside the container is ready. The status of the container starts to be ready when the Readiness Probe decides that the application in the container is ready. Kubernetes even doesn't try to send the request to the container as long as the application is not ready.

Please scale the application to 3 replicas. You will not observe the `Connection refused` in this time, because as long as the application is not ready in the new pods, Kubernetes sends the requests only to the first container which is ready. As soon as the new pods are ready Kubernetes starts to send requests to the new pods too.

Scale the application to 1 replicas.

## (Optional) Check the failure of the Readiness Probe

Please change the url of the Readiness Probe in `person-service-deployment-v3.yaml` to something not extsting, e.g. `/hellooo`. This will simulate the problem with the application, because it will not answer on the defined endpoint.

Apply the file, scale the application to 1 replica and observe the result in the test container and status of the containers.

Because the Readiness Probe never gets a successful response from the readiness endpoint, the pod will never go into the ready state.

Correct the `person-service-deployment-v3.yaml` file and apply it again. Wait until the pod is in ready state and starts to serve a successful responses. 

## Configure Liveness Probe

Please review the file `person-service-deployment-v4.yaml` and apply it.

```
kubectl apply -f person-service-deployment-v4.yaml
```

Wait until application starts and serves the responses. Because our application has no problems, you will not see the Liveness Probe in action.

Let's simulate problems with Liveness Probe. Please change the url of the Liveness Probe in `person-service-deployment-v4.yaml` to something not extsting, e.g. `/hellooo` ans apply the file. Wait untill the application starts. 
```
NAME                             READY   STATUS    RESTARTS   AGE
person-db-6b7bcc8d4b-7x5fj       1/1     Running   0          81m
person-service-55b4b8474-pzz5k   1/1     Running   0          77s
```

After some more time you will observe the restart of the container 
```
NAME                             READY   STATUS    RESTARTS     AGE
person-db-6b7bcc8d4b-7x5fj       1/1     Running   0            81m
person-service-55b4b8474-pzz5k   0/1     Running   1 (6s ago)   87s
```

Please describe the pod

```
kubectl describe pod person-service-55b4b8474-pzz5k
```

In the events section you can see information about failing Liveness Probe call

```
Events:
  Type     Reason     Age                 From               Message
  ----     ------     ----                ----               -------
  Normal   Scheduled  116s                default-scheduler  Successfully assigned applications/person-service-55b4b8474-pzz5k to ip-10-0-40-151.eu-central-1.compute.internal
  Normal   Pulled     115s                kubelet            Successfully pulled image "quay.io/ksobkowiak/person-service:latest" in 500ms (500ms including waiting)
  Warning  Unhealthy  36s (x3 over 56s)   kubelet            Liveness probe failed: HTTP probe failed with statuscode: 404
  Normal   Killing    36s                 kubelet            Container person-service failed liveness probe, will be restarted
  Normal   Pulling    35s (x2 over 115s)  kubelet            Pulling image "quay.io/ksobkowiak/person-service:latest"
  Normal   Created    34s (x2 over 115s)  kubelet            Created container person-service
  Normal   Started    34s (x2 over 115s)  kubelet            Started container person-service
```

You can see the new container has been started. Wait some more time and you will observe the next restart

```
NAME                             READY   STATUS    RESTARTS      AGE
person-db-6b7bcc8d4b-7x5fj       1/1     Running   0             84m
person-service-55b4b8474-pzz5k   1/1     Running   2 (64s ago)   3m46s
```


It happens, because the Liveness Probe does not get successfull response from the endpoint and after 3 failures restarts the container.

Correct the Liveness endpoint in the deployment file and apply it again.

## Delete the test container

Please remove the test container.

```
kubectl delete pod test
```

You can also simply type `exit` int the container terminal.
