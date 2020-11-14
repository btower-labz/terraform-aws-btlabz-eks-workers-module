#!/usr/bin/env bash

set -o nounset
set -o noclobber
set -o errexit
set -o pipefail
set -o xtrace

function log {
  echo "user_data: $1"
  logger --id "user_data: $1"
}

log 'started'

# Update packages
yum update --assumeyes && rc=$? || rc=$?
echo "update result is $rc"

# See: https://github.com/awslabs/amazon-eks-ami/blob/master/files/bootstrap.sh
# See: https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/

/etc/eks/bootstrap.sh \
  --apiserver-endpoint '${endpoint}' \
  --b64-cluster-ca '${auth}' \
  --kubelet-extra-args '%{ if length(labels)>0 }--node-labels=${labels}%{ endif } ' \
 ${name}

log 'k8s bootstrapped ...'

# See: https://github.com/aws/containers-roadmap/issues/789
# See: https://github.com/mumoshu/kube-ssm-agent/blob/master/Dockerfile

yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

log 'ssm agent installed ...'
systemctl enable amazon-ssm-agent
systemctl status amazon-ssm-agent

log 'finished'
