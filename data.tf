data "aws_region" "current" {}

data "aws_subnet" "main" {
  id = element(sort(compact(var.subnets)), 0)
}

data "aws_vpc" "main" {
  id = data.aws_subnet.main.vpc_id
}

data "aws_eks_cluster" "main" {
  name = var.eks_cluster
}
