variable "enable_amazon_ssm_managed_instance_core" {
  type        = bool
  description = "Enable AmazonSSMManagedInstanceCore Managed Policy"
  default     = true
}

variable "enable_cloud_watch_agent_server_policy" {
  type        = bool
  description = "Enable CloudWatchAgentServerPolicy Managed Policy"
  default     = true
}

variable "enable_amazon_eks_worker_node_policy" {
  type        = bool
  description = "Enable AmazonEKSWorkerNodePolicy Managed Policy"
  default     = true
}

variable "enable_amazon_eks_cni_policy" {
  type        = bool
  description = "Enable AmazonEKS_CNI_Policy Managed Policy"
  default     = true
}

variable "enable_amazon_ec2_container_registry_read_only" {
  type        = bool
  description = "Enable AmazonEC2ContainerRegistryReadOnly Managed Policy"
  default     = true
}

data "aws_iam_policy_document" "ec2_trust" {
  version = "2012-10-17"

  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "assume_roles" {
  version = "2012-10-17"

  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    resources = var.kube2iam_roles
  }
}

resource "aws_iam_role" "node" {
  name = "${var.eks_cluster}-eks-node-role"

  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json

  tags = merge(
    map(
      "Name", "${var.eks_cluster}-eks-node-role"
    ),
    var.tags
  )
}

resource "aws_iam_role_policy" "assume_roles" {
  name   = "assume-roles"
  role   = aws_iam_role.node.name
  policy = data.aws_iam_policy_document.assume_roles.json
}

resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  count      = var.enable_amazon_eks_worker_node_policy ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  count      = var.enable_amazon_eks_cni_policy ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  count      = var.enable_amazon_ec2_container_registry_read_only ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

resource "aws_iam_instance_profile" "node" {
  name = "${var.eks_cluster}-eks-node-instance-profile"
  role = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "amazon_ssm_managed_instance_core" {
  count      = var.enable_amazon_ssm_managed_instance_core ? 1 : 0
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloud_watch_agent_server_policy" {
  count      = var.enable_cloud_watch_agent_server_policy ? 1 : 0
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
