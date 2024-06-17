# EKS & Kubernetes Workshop - PostgreSQL Database Deployment

## Deploy PostgreSQL database using declarative way

Navigate to `eks/workloads` folder in a training project. Please review the content of `person-db-deployment-v1.yaml` Deploy Postgres database into namespace using the yaml manifest.

```
kubectl apply -f person-db-deployment-v1.yaml
```

> **INFO**
> You can also use an imperative way to deploy the pod. Please see the optional material at the end of this file

## Review the deployment

Verify which object have been created

```
kubectl get all
```
```
NAME                            READY   STATUS    RESTARTS   AGE
pod/person-db-d849cd696-hc292   1/1     Running   0          7m23s

NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/person-db   1/1     1            1           7m23s

NAME                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/person-db-d849cd696   1         1         1       7m23s
```

Get the pods available in the namespace
```
kubectl get pods
```
```
NAME                        READY   STATUS    RESTARTS   AGE
person-db-d849cd696-hc292   1/1     Running   0          31s
```
Get more informations about existing pods
```
kubectl get pods -o wide
```
```
NAME                        READY   STATUS    RESTARTS   AGE     IP           NODE                                           NOMINATED NODE   READINESS GATES
person-db-d849cd696-hc292   1/1     Running   0          6m25s   10.0.35.87   ip-10-0-40-151.eu-central-1.compute.internal   <none>           <none>
```
Get all existing pods and show labels associated with the pods
```
kubectl get pods --show-labels
```
```
NAME                        READY   STATUS    RESTARTS   AGE     LABELS
person-db-d849cd696-hc292   1/1     Running   0          6m12s   app=person-db,pod-template-hash=d849cd696
```

Select pods with the given label
```
kubectl get pods -l app=person-db
```
```
NAME                        READY   STATUS    RESTARTS   AGE     LABELS
person-db-d849cd696-hc292   1/1     Running   0          6m12s   app=person-db,pod-template-hash=d849cd696
```

Play with `kubectl` and get list of existing deployments using commands
```
kubectl get deployments
```
```
kubectl get deployments -o wide
```
```
kubectl get deployments --show-labels
```
```
kubectl get deployments -l app=person-db
```

Check logs of a new pod using 
```
kubectl logs person-db-d849cd696-hc292
```

Check details of the pod using 
```
kubectl describe pod person-db-d849cd696-hc292
```

Export the configuration of the pod to yaml format using
```
kubectl get pod person-db-d849cd696-hc292 -o yaml
```

Please play with the `kubectl` commands and display the pod configuration in the json format. 

Play with the same commands and display configuration of the deployment in yaml and json formats. Check details of the deployment using `kubectl describe` command.

## Test the autohealing of the deployment

Please delete the existing pod
```
kubectl delete pod person-db-d849cd696-hc292
```
List the existing pods using the command
```
kubectl get pods
```
After some seconds you should see a new pod has been created and being in status `Runnung`.

## Create and test the database

You can exec a process in existing pod using the `kubectl exec´ command. Please check, whether the Postgres database is working using command

```
kubectl exec -it person-db-d849cd696-4wkg6 -- psql -U postgres person -c 'select 1;'
```

Create the table using command
```
kubectl exec -it person-db-d849cd696-4wkg6 -- psql -U postgres person -c 'create table Person (id int8 not null, first_name varchar(255), last_name varchar(255), salutation varchar(255), primary key (id));'
```

Insert some data 
```
kubectl exec -it person-db-d849cd696-4wkg6 -- psql -U postgres person -c "insert into person(id, first_name, last_name, salutation) values (1, 'Bobby', 'Brown', 'Mr');"
```

Check whether the data has been persisted
```
kubectl exec -it person-db-d849cd696-4wkg6 -- psql -U postgres person -c 'select * from person;'
```

---
---

## (Optional) Deploy Postgres using imperative way (optional)

Skip this step if you have performed the deployment using the declarative command.

Please run following command do deploy the Postgres pod
```
kubectl create deployment person-db --image docker.io/postgres:16 --env POSTGRES_DB=person --env POSTGRES_PASSWORD=postgres --env POSTGRES_USER=postgres
```

## (Optional) Generate declarative resources from imperative commands

Usually when you prepare deployments for your application first time you have not ready to use declarative resources. You can use imperative commands to create and configure your deployments. You can also use the imperative commands to generate the yaml or json files with the resources

Please run the previous command to generate a yaml file with the deployment
```
kubectl create deployment person-db --image docker.io/postgres:16 --env POSTGRES_DB=person --env POSTGRES_PASSWORD=postgres --env POSTGRES_USER=postgres --dry-run=client -o yaml
```
Next you can copy the content into a yaml file. You need to remove some unnecessary fragments of this file like the complete `status` part or `creationTimestamp`, `resourceVersion`, `uid`, `generation` from `metadata` and some unnecessary annotations. 