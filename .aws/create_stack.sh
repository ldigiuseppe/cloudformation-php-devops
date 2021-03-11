#!/bin/sh



# Replace config variables in template
source config

echo "creating templates from variables"

sed "s/{app_name}/$app_name/" cloud-formation/cluster.yml > cloud-formation/temp-cluster.yml
sed -i "s/{environment}/$environment/" cloud-formation/temp-cluster.yml

sed "s/{app_name}/$app_name/" cloud-formation/task.yml > cloud-formation/temp-task.yml
sed -i "s/{environment}/$environment/" cloud-formation/temp-task.yml

stack_name="$app_name"-"$environment"

# debug
set -x
echo "crating VPC"
vpc_stack_id=$( aws cloudformation create-stack --template-body file://$PWD/cloud-formation/vpc.yml --stack-name "vpc-${stack_name}" | jq -r '.StackId' ) 
aws cloudformation wait stack-create-complete --stack-name $vpc_stack_id

echo "crating IAM"
iam_stack_id=$( aws cloudformation create-stack --template-body file://$PWD/cloud-formation/iam.yml --stack-name "iam-${stack_name}" --capabilities CAPABILITY_IAM | jq -r '.StackId' ) 
aws cloudformation wait stack-create-complete --stack-name $iam_stack_id

echo "crating Cluster"
cluster_stack_id=$( aws cloudformation create-stack --template-body file://$PWD/cloud-formation/temp-cluster.yml --stack-name "cluster-${stack_name}" | jq -r '.StackId' ) 
aws cloudformation wait stack-create-complete --stack-name $cluster_stack_id

echo "crating Tasks"
task_stack_id=$( aws cloudformation create-stack --template-body file://$PWD/cloud-formation/temp-task.yml --stack-name "task-${stack_name}" | jq -r '.StackId' ) 
aws cloudformation wait stack-create-complete --stack-name $task_stack_id

echo "all resources created"

rm cloud-formation/temp-task.yml
rm cloud-formation/temp-cluster.yml

set +x