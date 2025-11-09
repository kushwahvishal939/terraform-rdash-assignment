## Configuration

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/kushwahvishal939/terraform-rdash-assignment.git
    cd terraform-rdash-assignment
    ```

2.  **Configure AWS Credentials:**
    Make sure your AWS CLI is configured with credentials that have permissions to create the resources defined in this project.
    ```sh
    aws configure
    ```
3.  **Prepare Terraform Variables:**
    The file `prod.tfvars` contains the configuration for the infrastructure. Review and adjust the values as needed. You can rename this file or create a new one (e.g., `dev.tfvars`).
```sh 
project_name          = "values"
vpc_cidr              = "values"
aws_region            = "values"
availability_zones    = "values"
public_subnet_cidrs   = "values"
private_subnet_cidrs  = "values"
database_subnet_cidrs = "values"
cache_subnet_cidrs    = "values"
# Storage configuration
bucket_name       = "values"
enable_versioning = "values"

# ECR configuration
ecr_repo_name = "values"
environment   = "values"
docker_path   = "dockerfile build docker_path"

#EKS
cluster_name       = "value"
node_instance_type = "value"
desired_capacity   = 3
max_size           = 2
min_size           = 1
aws_account_id     = "aws_ids"
repository_name    = "ECR repo name"
app_image_tag      = "latest"
docker_config_json = "cofig json path"
eks_admin_users = [
  {
    username = "aws username"
    userarn  = "arn:aws:iam::<account id>:user/user@exmaple.com"
    groups   = ["system:masters"]
  }
]
```

## Deployment Steps

1.  **Initialize Terraform:**
    ```sh
    terraform init
    ```
2. **Plan the Deployment:**
    ```sh
    terraform plan -var-file="prod.tfvars"
    ```

3.  **Deploy Infrastructure:**
    Run `plan` to review the changes and `apply` to provision the resources.
    ```sh
    terraform plan -var-file="prod.tfvars"
    terraform apply -var-file="prod.tfvars" --auto-approve
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
- **NAT Gateway:** NAT Processing, S3, ECR (low usage) = ~$5.00 - $20.00+
- **EC2 Worker Nodes:** Cost depends on the instance type (`t3.medium` by default) and the number of running nodes.
exampl: 2 x `t3.medium` instances (worker nodes) = ~$71

- **EBS Volumes:** Storage for the EC2 worker nodes.
example: 2 x 20 GB `gp3` volumes = ~$3.50

*   **Auto-Scaling**: The EKS node group is configured to scale between 1 (`min_size`) and 4 (`max_size`) nodes. The estimate above is based on the `desired_capacity` of 2 nodes. Costs will increase if the cluster scales up.
*   **Data Transfer**: Costs for data transfer out to the internet are variable and can be a significant factor depending on the application's workload.
*   **Savings Plans**: EC2 costs can be significantly reduced by using AWS Savings Plans.

Please review the AWS Pricing page for detailed information and use the AWS Cost Explorer to monitor your expenses.


| Service                    | Configuration                          | Estimated Monthly Cost (USD) |
| :------------------------- | :------------------------------------- | :--------------------------- |
| **Amazon EKS**             | 1 Cluster Control Plane                | ~$73.00                      |
| **Amazon EC2**             | 2 x `t3.medium` instances (worker nodes) | ~$71.50                      |
| **NAT Gateway**            | 1 x NAT Gateway (hourly charge)        | ~$40.00                      |
| **Amazon EBS**             | 2 x 20 GB `gp3` volumes                | ~$3.50                       |
| **Data Transfer & Other**  | NAT Processing, S3, ECR (low usage)    | ~$5.00 - $20.00+             |
| **Total Estimated Cost**   |                                        | **~$193.00 - $208.00**       |

