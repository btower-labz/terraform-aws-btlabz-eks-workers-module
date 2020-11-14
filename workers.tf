locals {
  labels = [
    "foo=bar",
    "bar=foo"
  ]
}

data "template_file" "worker_node" {
  template = file("${path.module}/templates/worker-node.sh")

  vars = {
    name     = data.aws_eks_cluster.main.id
    endpoint = data.aws_eks_cluster.main.endpoint
    auth     = data.aws_eks_cluster.main.certificate_authority[0].data
    labels   = join(",", local.labels)
  }
}

resource "aws_launch_configuration" "eks" {
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.node.name
  image_id                    = local.eks_worker_ami_id
  instance_type               = var.instance_type
  name_prefix                 = "${var.eks_cluster}-eks-"
  security_groups             = [aws_security_group.node.id]
  user_data_base64            = base64encode(data.template_file.worker_node.rendered)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "eks" {
  desired_capacity     = var.desired_capacity
  launch_configuration = aws_launch_configuration.eks.id
  max_size             = var.max_size
  min_size             = var.min_size
  name                 = "${var.eks_cluster}-eks-asg"
  vpc_zone_identifier  = var.subnets

  tags = [
    {
      key                 = "Name"
      value               = "${var.eks_cluster}-${var.group_name}"
      propagate_at_launch = true
    },
    {
      key                 = "kubernetes.io/cluster/${data.aws_eks_cluster.main.id}"
      value               = "owned"
      propagate_at_launch = true
    },
    #{
    #  key                 = "Stack"
    #  value               = local.stack
    #  propagate_at_launch = true
    #},
    #{
    #  key                 = "Environment"
    #  value               = local.environment
    #  propagate_at_launch = true
    #},
    #{
    #  key                 = "Origin"
    #  value               = local.origin
    #  propagate_at_launch = true
    #},
    #{
    #  key                 = "RunAWSInspector"
    #  value               = "yes"
    #  propagate_at_launch = true
    #},
    #{
    #  key                 = "Patch Group"
    #  value               = "yes"
    #  propagate_at_launch = true
    #},
    {
      # Cluster Autoscaler Autodiscovery Tags
      key                 = "k8s.io/cluster-autoscaler/enabled"
      value               = ""
      propagate_at_launch = false
    },
    {
      key                 = "k8s.io/cluster-autoscaler/${data.aws_eks_cluster.main.id}"
      value               = ""
      propagate_at_launch = false
    },
  ]

  lifecycle {
    ignore_changes = [desired_capacity]
  }

  #depends_on = [null_resource.aws_auth]
}
