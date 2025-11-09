# Cloud Infrastructure and Kubernetes RBAC Assignment

This project provisions a complete cloud infrastructure on AWS using Terraform and deploys a Kubernetes cluster (EKS) with specific RBAC and cloud identity configurations.

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Prerequisites](#prerequisites)
- [Directory Structure](#directory-structure)
- [Configuration](#configuration)
- [Deployment Steps](#deployment-steps)
- [Validation](#validation)
  - [Deploy Test Pod](#1-deploy-test-pod)
  - [Test RBAC Permissions](#2-test-rbac-permissions)
  - [Test Storage Access](#3-test-storage-access)
- [Cleanup](#cleanup)
- [Estimated Costs](#estimated-costs)

## Architecture Overview

The infrastructure consists of the following components:
- **VPC**: A custom Virtual Private Cloud with public, private, database, and cache subnets spread across two Availability Zones for high availability.
- **Networking**: An Internet Gateway for public subnets and NAT Gateways for private subnets to allow outbound internet access.
- **EKS Cluster**: A managed Kubernetes cluster with its control plane publicly accessible and worker nodes running securely in private subnets.
- **S3 Bucket**: A private S3 bucket for application storage.
- **IAM & RBAC**:
  - An IAM Role for Service Accounts (IRSA) is configured to grant a specific Kubernetes service account (`rbac-test-sa`) secure access to the S3 bucket.
  - Kubernetes RBAC policies are set up to enforce least-privilege access for the `rbac-test-sa` account across different namespaces.
- **ECR**: An Elastic Container Registry to store the custom Docker image for the test pod.

## Prerequisites

Ensure you have the following tools installed and configured:

- **Terraform**: `v1.0.0` or newer
- **AWS CLI**: `v2.x` or newer, configured with administrator access credentials.
- **kubectl**: `v1.24` or newer
- **Docker**: `v20.x` or newer

## Directory Structure

```
├── kubernetes-manifests/ # K8s manifests for RBAC and testing
├── modules/              # Reusable Terraform modules
│   ├── eks/
│   ├── iam/
│   ├── storage/
│   └── vpc/
├── docker/               # Dockerfile for the test pod image
│   └── Dockerfile
├── main.tf               # Root module configuration
├── output.tf             # Root module outputs
├── provider.tf           # Terraform provider configuration
├── variable.tf           # Root module variable definitions
├── prod.tfvars           # Example configuration values (DO NOT COMMIT SENSITIVE DATA)
└── README.md             # This file
```

## Configuration

1.  **Clone the repository:**
    ```sh
    git clone <your-repo-url>
    cd <your-repo-name>
    ```

2.  **Configure AWS Credentials:**
    Make sure your AWS CLI is configured with credentials that have permissions to create the resources defined in this project.
    ```sh
    aws configure
    ```

3.  **Prepare Terraform Variables:**
    The file `prod.tfvars` contains the configuration for the infrastructure. Review and adjust the values as needed. You can rename this file or create a new one (e.g., `dev.tfvars`).

## Deployment Steps

1.  **Initialize Terraform:**
    ```sh
    terraform init
    ```

2.  **Build and Push Docker Image:**
    The test pod requires a Docker image with `kubectl` and `aws-cli`. The included `ecr` module will create a repository. You need to build and push the image to it.

    *Note: You may need to run `terraform apply` once to create the ECR repository first, or manually create it.*

    ```sh
    # Login to AWS ECR
    aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 715418180138.dkr.ecr.ap-south-1.amazonaws.com

    # Build the Docker image
    docker build -t tech-vishal-ecr-repo:latest docker/

    # Tag the image for ECR
    docker tag tech-vishal-ecr-repo:latest 715418180138.dkr.ecr.ap-south-1.amazonaws.com/tech-vishal-ecr-repo:latest

    # Push the image to ECR
    docker push 715418180138.dkr.ecr.ap-south-1.amazonaws.com/tech-vishal-ecr-repo:latest
    ```
    *(Replace the AWS Account ID, region, and repo name with your configuration)*

3.  **Deploy Infrastructure:**
    Run `plan` to review the changes and `apply` to provision the resources.
    ```sh
    terraform plan -var-file="prod.tfvars"
    terraform apply -var-file="prod.tfvars" --auto-approve
    ```

4.  **Automatic `kubectl` Configuration:**
    The Terraform setup includes a `local-setup.tf` file that automatically installs `kubectl` (if not present) and configures the `~/.kube/config` file to connect to the new EKS cluster.

    After `terraform apply` completes, you can immediately start using `kubectl`. Verify the connection:
    ```sh
    kubectl get nodes
    ```

## Validation

Follow these steps to verify that all RBAC and storage permissions are working as expected.

### 1. Deploy Test Pod

The test pod `rbac-test-pod` is automatically deployed by Terraform. You can verify that it is running:

kubectl get pod rbac-test-pod

### 2. Test RBAC Permissions

Get a shell inside the running test pod:
```sh
kubectl exec -it rbac-test-pod -- /bin/bash
```

Now, run the following commands from *inside the pod's shell* and check the output.

| Command                               | Expected Result                                     | Reason                               |
| ------------------------------------- | --------------------------------------------------- | ------------------------------------ |
| `kubectl get namespaces`              | **Success** (Lists all namespaces)                  | Cluster-wide list permission.        |
| `kubectl get pods -n default`         | **Failure** (Error from server: forbidden)          | No access to `default` namespace.    |
| `kubectl get pods -n kube-system`     | **Failure** (Error from server: forbidden)          | No access to `kube-system` namespace.|
| `kubectl get pods -n rbac-a`          | **Success** (No resources found or lists pods)      | Read-only access to `rbac-a`.        |
| `kubectl create deployment nginx --image=nginx -n rbac-a` | **Failure** (Error from server: forbidden) | Read-only access, cannot create.     |
| `kubectl get pods -n rbac-b`          | **Success** (No resources found or lists pods)      | Full access to `rbac-b`.             |
| `kubectl create deployment nginx --image=nginx -n rbac-b` | **Success** (`deployment.apps/nginx created`) | Full access, can create.             |
| `kubectl delete deployment nginx -n rbac-b` | **Success** (`deployment.apps "nginx" deleted`) | Full access, can delete.             |

### 3. Test Storage Access

From *inside the pod's shell*, test read/write access to the S3 bucket.

```sh
# Replace 'your-bucket-name' with the bucket name from prod.tfvars
BUCKET_NAME="production-terraform-state-vishal"

# Create a test file
echo "hello world" > test.txt

# Upload the file to S3 (should succeed)
aws s3 cp test.txt s3://${BUCKET_NAME}/test.txt
# Expected output: upload: ./test.txt to s3://<bucket-name>/test.txt

# Download the file from S3 (should succeed)
aws s3 cp s3://${BUCKET_NAME}/test.txt downloaded.txt
# Expected output: download: s3://<bucket-name>/test.txt to ./downloaded.txt

# Verify content
cat downloaded.txt
# Expected output: hello world

# Clean up the test files
rm test.txt downloaded.txt
aws s3 rm s3://${BUCKET_NAME}/test.txt
```

## Cleanup

To destroy all the resources created by this project and avoid incurring further costs, follow these steps:

1.  **Delete Kubernetes Resources:**
    Use Terraform to destroy all AWS resources.
    ```sh
    terraform destroy -var-file="prod.tfvars" --auto-approve
    ```

2.  **Delete ECR Image (Optional):**
    If you want to remove the Docker image from ECR, you can do so from the AWS Management Console or via the AWS CLI.

## Estimated Costs

Running this infrastructure will incur costs on AWS. The primary cost drivers are:
- **EKS Control Plane:** ~$0.10 per hour (~$73 per month).
- **NAT Gateway:** ~$0.045 per hour per gateway + data processing charges. With 2 NAT Gateways, this is ~$65 per month plus data charges.
- **EC2 Worker Nodes:** Cost depends on the instance type (`t3.medium` by default) and the number of running nodes.
- **EBS Volumes:** Storage for the EC2 worker nodes.

Please review the AWS Pricing page for detailed information and use the AWS Cost Explorer to monitor your expenses.
