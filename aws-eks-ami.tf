
# See: https://docs.aws.amazon.com/eks/latest/userguide/retrieve-ami-id.html

locals {
  eks_worker_ami_k8s_version = data.aws_eks_cluster.main.version
  eks_worker_ami_linux_options = [
    "amazon-linux-2",
    "amazon-linux-2-gpu",
    "amazon-linux-2-arm64",
  ]
  eks_worker_ami_linux_variation = local.eks_worker_ami_linux_options[0]
  eks_worker_ami_ssm_path = format(
    "/aws/service/eks/optimized-ami/%s/%s/recommended/image_id",
    local.eks_worker_ami_k8s_version,
    local.eks_worker_ami_linux_variation
  )
}

data "aws_ssm_parameter" "eks_worker_ami" {
  name = local.eks_worker_ami_ssm_path
}

data "aws_ami" "eks_worker_ami" {
  filter {
    name   = "image-id"
    values = [data.aws_ssm_parameter.eks_worker_ami.value]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
  owners = [
    "amazon",
    "558608220178", # amazon in me-south-1
  ]
  most_recent = true
}

locals {
  eks_worker_ami_id = data.aws_ami.eks_worker_ami.id
}

output "eks_worker_ami_id" {
  value = local.eks_worker_ami_id
}

output "eks_worker_ami_arn" {
  value = data.aws_ami.eks_worker_ami.arn
}

output "eks_worker_ami_name" {
  value = data.aws_ami.eks_worker_ami.name
}

output "eks_worker_ami_description" {
  value = data.aws_ami.eks_worker_ami.description
}
