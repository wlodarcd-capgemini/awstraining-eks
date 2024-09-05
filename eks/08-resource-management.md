# EKS & Kubernetes Workshop - CPU/Memory requests and limits

## Setting resource (memory & cpu) requests and limits

Please review the file `person-service-deployment-v2.yaml` and apply it
```
kubectl apply -f person-service-deployment-v2.yaml
```
When you list the pods (try to repeat the command below more times) you can see the application pod is in status `OOMKilled`
```
kubectl get pods -w
```
```
NAME                              READY   STATUS      RESTARTS     AGE
person-db-6b7bcc8d4b-7x5fj        1/1     Running     0            9m10s
person-service-68cc8cb485-t8g7p   0/1     OOMKilled   1 (6s ago)   10s
```

Please observe the pod for some time. You will see the container is restarted and transits into `OOMKilled` state again. At the end Kubernetes gives away and you will see the status `CrashLoopBackOff`.

This happens because you have set to low memory limit (`10Mi`) for the container. 

Please correct the values in the file and apply it again. 
```
resources:
    limits:
        cpu: 200m
        memory: 512Mi
    requests:
        cpu: 100m
        memory: 256Mi   
```
Now the container starts, because it has sufficient memory to start the application.

---
---

## (Optional) Setting resources using imperative command

You can set the resources also using the imperative command
```
kubectl set resources deployment person-service --limits=cpu=200m,memory=512Mi --requests=cpu=100m,memory=256Mi
```
