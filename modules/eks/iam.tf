resource "aws_iam_role" "cluster" {
    name = "${var.cluster_name}-cluster-role"
    assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json
}


data "aws_iam_policy_document" "eks_assume_role" {
    statement {
    effect = "Allow"
        principals {
        type = "Service"
        identifiers = ["eks.amazonaws.com"]
        }
        actions = ["sts:AssumeRole"]
    }
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
    role = aws_iam_role.cluster.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


# Node group role
resource "aws_iam_role" "node_group" {
    name = "${var.cluster_name}-node-role"
    assume_role_policy = data.aws_iam_policy_document.node_assume_role.json
}


data "aws_iam_policy_document" "node_assume_role" {
    statement {
    actions = ["sts:AssumeRole"]
        principals {
        type = "Service"
        identifiers = ["ec2.amazonaws.com"]
        }
    }
}


resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
    role = aws_iam_role.node_group.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}


resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
    role = aws_iam_role.node_group.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
    role = aws_iam_role.node_group.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}