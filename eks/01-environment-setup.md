# EKS & Kubernetes Workshop - Environment Setup

## Requirements

* AWS account with Administrator access
* [awscli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) v2 installed
* [kubectl](https://kubernetes.io/docs/tasks/tools/) (1.28, 1.29) installed

## Generate and configure aws cli credentials

First generate AWS cli credentials on your AWS account. Save the generated `ACCESS_KEY_ID` and `SECRET_ACCESS_KEY`  

> **NOTE**  
> DO NOT USE ROOT USER CREDENTIALS! Instead, create admin user in IAM, assign him AdministratorAccess policy and generate credentials for this non-root user.

Configure the credentials on your system using AWS CLI:

```
aws configure --profile backend-test
```

You should have following files:
* `C:\Users\YOURUSER\.aws\credentials` 
    ```
    [backend-test]
    aws_access_key_id = ACCESS_KEY_ID
    aws_secret_access_key = SECRET_ACCESS_KEY
    ```
* `C:\Users\YOURUSER\.aws\config`
    ```
    [profile backend-test]
    output=json
    region = eu-central-1
    ```

You can also create the files manually.

## Provision infrastructure (GitHub)
First, you should fork this repository to your account.

Then, you should go to **GitHub -> Your fork repo -> Settings -> Secrets and variables** and create two repository secrets:
* BACKEND_EMEA_TEST_AWS_KEY
* BACKEND_EMEA_TEST_AWS_SECRET

and set accordingly `ACCESS_KEY_ID` and `SECRET_ACCESS_KEY`, same as locally in `..\.aws\credentials`.

Then, you should run **Provision with Terraform** pipeline under **Actions** tab. This will automatically provision AWS infrastructure. Choose **eks** as deployment type.

#### Destroying infrastructure (GitHub)
In order to destroy your infrastructure you can simply call the **Destroy Infrastructure with Terraform** workflow in GitHub. Choose **eks** as deployment type. It will do the whole work for you.

### Configure `kubectl`

After the creation is complete, use following command to configure EKS cluster on your system. This is required for accessing cluster with `kubectl`. 
```
aws eks update-kubeconfig --name backend-eks --profile backend-test
```
as output you should get the name of the current context
```
Updated context arn:aws:eks:eu-central-1:058264348876:cluster/backend-eks in C:\Users\YOURUSER\.kube\config
```

After executing this command, there will be new entry in your `C:\Users\YOURUSER\.kube\config` file for new cluster

## Explore the EKS cluster

Execute following command to display current context (current cluster you are working on). 
```
kubectl config current-context
```
As output you should see tne name of the context you have created previously using the `aws` command
```
arn:aws:eks:eu-central-1:058264348876:cluster/backend-eks
```

List all contexts configured on your system
```
kubectl config get-contexts
```

If your current context is not the cluster you created via terraform, use following command (put your context name as defined in kubeconfig)
```
kubectl config use-context arn:aws:eks:eu-central-1:058264348876:cluster/backend-eks
```

## Prepare the namespace

Execute following command to list namespaces in a cluster. 
```
kubectl get namespace
```
```
NAME              STATUS   AGE
default           Active   2d3h
kube-node-lease   Active   2d3h
kube-public       Active   2d3h
kube-system       Active   2d3h
```

> **INFO** 
> In Kubernetes, namespaces provides a mechanism for isolating groups of resources within a single cluster. Names of resources need to be unique within a namespace, but not across namespaces

* **default** - Kubernetes includes this namespace so that you can start using your new cluster without first creating a namespace.
* **kube-node-lease** - This namespace holds [Lease](https://kubernetes.io/docs/concepts/architecture/leases/) objects associated with each node. Node leases allow the kubelet to send heartbeats so that the control plane can detect node failure.
* **kube-public** - This namespace is readable by all clients (including those not authenticated). This namespace is mostly reserved for cluster usage, in case that some resources should be visible and readable publicly throughout the whole cluster. The public aspect of this namespace is only a convention, not a requirement.
* **kube-system** - The namespace for objects created by the Kubernetes system

Create new namespace where you will deploy your application. 
```
kubectl create namespace applications
```

Set this namespace as to be default in your current context, so you don't need to specify it explicitly each time.
``` 
kubectl config set-context arn:aws:eks:eu-central-1:058264348876:cluster/backend-eks --namespace=applications
```

Verify that namespace is set in a context
```
contexts:
- context:
    cluster: arn:aws:eks:eu-central-1:058264348876:cluster/backend-eks
    namespace: applications
    user: arn:aws:eks:eu-central-1:058264348876:cluster/backend-eks
  name: arn:aws:eks:eu-central-1:058264348876:cluster/backend-eks
current-context: arn:aws:eks:eu-central-1:058264348876:cluster/backend-eks
```