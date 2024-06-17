# EKS & Kubernetes Workshop - Create Ingress

## Create the ingress

Till now you were able to communicate with the application by creating a temporary pod and calling the rest service. To expose a service for communication from outside of the cluster you need to create an ingress.

Please review the file `person-service-ingress.yaml` and apply it
```
kubectl apply -f person-service-ingress.yaml
```
Check the created ingress
```
kubectl get ingress
```
```
NAME             CLASS   HOSTS   ADDRESS                                                                      PORTS   AGE
person-ingress   alb     *       k8s-applicat-personin-299d04082d-1384484175.eu-central-1.elb.amazonaws.com   80      7s
```

Please note the address value. 

## Test the connection

Wait some minutes untill the address is provided by the dns servers and open following urls in your browser (use host name provided by `kubectl get ingress` command)
* http://k8s-applicat-personin-299d04082d-1384484175.eu-central-1.elb.amazonaws.com/hello
* http://k8s-applicat-personin-299d04082d-1384484175.eu-central-1.elb.amazonaws.com/person

> **NOTE**  
> Please delete this ingress before destroying the cluster using the `kubectl delete ingress person-ingress` command. Otherwise you will have problems while destroying the cluster.