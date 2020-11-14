output "cluster_name" {
  description = "The name of the cluster."
  value       = data.aws_eks_cluster.main.id
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster."
  value       = data.aws_eks_cluster.main.arn
}

output "cluster_k8s_version" {
  description = "The K8S version for the cluster"
  value       = data.aws_eks_cluster.main.version
}

output "cluster_platform_version" {
  description = "The AWS EKS Platform Version"
  value       = data.aws_eks_cluster.main.platform_version
}

output "worker_node_role_name" {
  description = "Worker node role name."
  value       = aws_iam_role.node.name
}

output "worker_node_role_arn" {
  description = "Worker node role ARN."
  value       = aws_iam_role.node.arn
}

output "worker_node_profile_name" {
  description = "Worker node instance profile name."
  value       = aws_iam_instance_profile.node.name
}

output "worker_node_profile_arn" {
  description = "Worker node instance profile ARN."
  value       = aws_iam_instance_profile.node.arn
}
