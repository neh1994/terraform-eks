
provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "abhi-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.7.0"

  name                 = "abhi-eks-vpc"
  cidr                 = var.vpc_cidr
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

#Categorization: Tags help you categorize AWS resources (e.g., EC2 instances, S3 buckets, VPCs) by assigning metadata. You can use tags to group resources by projects, environments (dev, prod), teams, owners, cost centers, or any other criteria.
#Search and Filter: AWS resources can be filtered and searched based on their tags, which makes it easier to navigate through large AWS environments.
#Key: "kubernetes.io/cluster/${local.cluster_name}" — This is a tag used by Kubernetes to identify and manage resources that are part of the same Kubernetes cluster. The ${local.cluster_name} dynamically inserts the cluster name, which is likely defined elsewhere in your Terraform configuration (in the locals block).

#Value: "shared" — This indicates that the resources with this tag can be shared between multiple services or components within the cluster.

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}
