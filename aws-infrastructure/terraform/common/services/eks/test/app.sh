#!/bin/bash

kubectl create secret generic person-db --from-literal user=postgres --from-literal password=postgres --from-literal db=person
kubectl create deployment person-db --image docker.io/postgres:16 --replicas 0
kubectl set env  deployment person-db --from=secret/person-db --prefix=POSTGRES_
kubectl scale deployment person-db --replicas 1
kubectl expose deployment person-db --name=person-db --port 5432

kubectl create configmap person-db --from-literal host=person-db
kubectl create deployment person-service --image quay.io/ksobkowiak/person-service:latest --replicas 0
kubectl set env deployment person-service --from=secret/person-db --prefix=DB_
kubectl set env deployment person-service --from=configmap/person-db --prefix=DB_
kubectl scale deployment person-service --replicas 1
kubectl expose deployment person-service --name person-service --port 8080