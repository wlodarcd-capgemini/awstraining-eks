## Requirements

* AWS account with Administrator access
* [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-cli) installed (~> v1.7.0)
* [awscli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) v2 installed
* [kubectl](https://kubernetes.io/docs/tasks/tools/) (1.28, 1.29) installed

## Generate and configure aws cli credentials

First generate AWS cli credentials on your AWS account and then configure the credentials on your system

> aws configure --profile training

## Provision infrastructure (locally)

### Remote state bucket
You need to first go to ```remote-state-bucket/``` directory and run

```
terraform init
```

and

```
terraform apply
```

To create a S3 remote state bucket. This state bucket will be used for saving Terraform state.

### EKS Cluster
Go to ```cluster/``` directory.

First update the `terraform.tfvars` file to put your desired configurations

Download and install provider and modules
> terraform init

Validate infrastructure configurations
> terraform validate

Plan VPC and EKS cluster
> terraform plan -out planfile -target module.vpc -target module.eks -target null_resource.next

Create VPC and EKS cluster
>terraform apply planfile

Plan EKS cluster nodes
> terraform plan -out planfile

Create EKS cluster nodes
> terraform apply planfile

### Destroying infrastructure

Go to ```cluster/``` directory and run
> terraform destroy

At the end go to S3 and empty state bucket and remove it.

## Provision infrastructure (GitHub)
First, you should fork this repository to your account.

Then, you should go to **GitHub -> Your fork repo -> Settings -> Secrets and variables**
and create two repository secrets:
* BACKEND_EMEA_TEST_AWS_KEY
* BACKEND_EMEA_TEST_AWS_SECRET

and set accordingly **AWS_KEY** and **AWS_SECRET**, same as locally in ```..\.aws\credentials```.

Then, you should run ```provisionWithTerraform``` pipeline under **Actions** tab.
This will automatically provision AWS infrastructure. Choose **eks** as deployment type.

### Destroying infrastructure (GitHub)
In order to destroy your infrastructure you can simply call the **Destroy Infrastructure**
workflow in GitHub. Choose **eks** as deployment type. It will do the whole work for you.