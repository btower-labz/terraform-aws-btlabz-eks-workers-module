variable "eks_cluster" {
  description = "The name of your EKS Cluster"
}

variable "group_name" {
  description = "The name of your EKS Workers Group"
}

variable "instance_type" {
  description = "Worker Node EC2 instance type"
  default     = "t3.small"
}

variable "desired_capacity" {
  description = "Autoscaling Desired node capacity"
  default     = 2
}

variable "max_size" {
  description = "Autoscaling maximum node capacity"
  default     = 6
}

variable "min_size" {
  description = "Autoscaling Minimum node capacity"
  default     = 1
}

variable "subnets" {
  description = "A list of subnets to place the EKS cluster and workers within"
  type        = list(string)
  validation {
    condition     = length(var.subnets) > 1
    error_message = "Non-empty list of VPC subnets identifiers must be provided."
  }
}

variable "kube2iam_roles" {
  description = "The list of POD IAM roles for kube2iam (roles to assume)."
  type        = list(string)
  default     = ["*"]
}

variable "tags" {
  description = "Common Tags to attach to Resources"
  type        = map(string)
}
