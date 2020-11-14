resource "aws_security_group" "node" {
  name        = "${data.aws_eks_cluster.main.name}-eks-node-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = data.aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"                                                    = "${data.aws_eks_cluster.main.name}-eks-node-sg"
    "kubernetes.io/cluster/${data.aws_eks_cluster.main.name}" = "owned"
    #"Stack"                                     = local.stack
    #"Environment"                               = local.environment
    #"Origin"                                    = local.origin
  }
}

resource "aws_security_group_rule" "node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.node.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = data.aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  to_port                  = 65535
  type                     = "ingress"
}

# https://github.com/istio/istio/issues/10637
resource "aws_security_group_rule" "node_ingress_istio" {
  description              = "Allow the port 443 from control plane to worker nodes "
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = data.aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  to_port                  = 443
  type                     = "ingress"
}


resource "aws_security_group_rule" "cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = data.aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  source_security_group_id = aws_security_group.node.id
  to_port                  = 443
  type                     = "ingress"
}
