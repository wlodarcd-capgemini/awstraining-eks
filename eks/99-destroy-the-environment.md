# EKS & Kubernetes Workshop - Destroy the environment

## Delete the ingres

You need to delete the ingres before removing the environemnt. Otherwise you will have problems while destroying the cluster.

Please perform following command
```
kubectl delete ingress person-ingress
```

Check whether there is no ingress available
```
kubectl get ingress
```
```
NAME             CLASS   HOSTS   ADDRESS     PORTS   AGE
```

## Destroy the cluster

In order to destroy your infrastructure you can simply call the **Destroy Infrastructure with Terraform** workflow in GitHub. Choose **eks** as deployment type. It will do the whole work for you.