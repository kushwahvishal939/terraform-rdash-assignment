data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource "aws_security_group" "cluster" {
  name   = "${var.cluster_name}-cluster-sg"
  vpc_id = var.vpc_id
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
    description = "Allow cluster communication from within VPC"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "nodes" {
  name   = "${var.cluster_name}-nodes-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "Allow worker nodes to talk to control plane"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.cluster.id]
  }

  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    cidr_blocks     = [data.aws_vpc.selected.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}