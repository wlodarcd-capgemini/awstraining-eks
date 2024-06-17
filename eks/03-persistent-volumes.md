# EKS & Kubernetes Workshop - Adding Persistent Volume to the Database Pod

## Simulate the pod failure

Please check there is still data you have created previously in the database
```
kubectl exec -it person-db-d849cd696-w4k9j -- psql -U postgres person -c 'select * from person;'
```

Delete the existing pod using the `kubectl delete` command, wait until the new pod is in state `Running` and test the database again

```
kubectl exec -it person-db-d849cd696-w4k9j -- psql -U postgres person -c 'select * from person;'
```

You should get error like this
```
ERROR:  relation "person" does not exist
LINE 1: select * from person;
                      ^
command terminated with exit code 1
```
This happens, because the previously created pod with the created table was deleted and the data was not persisted anywhere. To solve the issue you need to create a persistent volume and attach it to the deployment.

## Create the persitent volume

Please review the content of the `person-db-pvc.yaml` file. Apply it using following command
```
kubectl apply -f person-db-pvc.yaml 
```

List existing pvcs
```
kubectl get pvc
```
```
NAME         STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
person-pvc   Pending                                      gp2            <unset>                 32s
```

Describe the pvc using
 ```
kubectl describe pvc person-pvc
```

Check the events to see why the pvc is in `Pending` status.

## Attach the persistent volume to deployment

Now you need to attach the pvc to the deployment. Please review the content of `person-db-deployment-v2.yaml` file. Please review the `volumes`, `volumeMounts` elements and the `PGDATA` environment variable. Please apply the data using 

```
kubectl apply -f person-db-deployment-v2.yaml
```
Check whether the new pod has been started and is in status `Running`. Describe the deployment using 
```
kubectl describe deployments person-db
```

You should see following information
```
    Mounts:
      /var/lib/postgresql/data from pgdata (rw)
  Volumes:
   pgdata:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  person-pvc
    ReadOnly:   false
```
It means the persistent volume has been successfully attached to the deployment. 

List again the existing pvcs. 
```
kubectl get pvc
```
You should see the pvc in status `Bound`.
```
NAME         STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
person-pvc   Bound    pvc-0d6b3ac0-6e8e-4048-a103-8f89d9de887c   2Gi        RWO            gp2            <unset>                 20m
```

## Test the pod failure again

Create the table in the database and import the data using the commands used previously

```
kubectl exec -it person-db-787bb5d566-jg46z -- psql -U postgres person -c 'create table Person (id int8 not null, first_name varchar(255), last_name varchar(255), salutation varchar(255), primary key (id));'

kubectl exec -it person-db-787bb5d566-jg46z -- psql -U postgres person -c "insert into person(id, first_name, last_name, salutation) values (1, 'Bobby', 'Brown', 'Mr');"
```

Check there is some data in the database
```
kubectl exec -it person-db-787bb5d566-jg46z -- psql -U postgres person -c 'select * from person;'
```

Delete the pod, wait until the new pod is created and is in `Running` state and check the database again. 

```
kubectl exec -it person-db-787bb5d566-fpk47 -- psql -U postgres person -c 'select * from person;'
```
You should see the data you have created before deleting the pod.

---
---

## (Optional) Modify existing deployment using a patch file

If you have existing deployment and you want to modify it, you can 
* use the yaml file used for the deployment, modify it and apply again
* export existing deployment to yaml file (if not exist), modify it and apply again
* use `kibectl edit` command and modify the running deployment
* create a patch file and apply it

Please review the file `person-db-deployment-patch.yaml`. It contains the elements you want to add/change in your existing deployment.  You can apply it using
```
kubectl patch deployment person-db --patch-file person-db-deployment-patch.yaml
```
 You could apply this step instead of applying the `person-db-deployment-v2.yaml` file.