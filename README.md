## Demo For Creating Lambda Functions as Exception Handlers for a Java Spring Web App Using Cloudwatch Application Logs 

**Prerequisites:**
1. An EKS cluster.
2. AWS CLI installed.
3. A storage class (mine is named `ebs-sc` in YAML).
4. Some kind of EKS application logs set up (I followed this tutorial: [CloudWatch Stream Container Logs in EKS](https://repost.aws/knowledge-center/cloudwatch-stream-container-logs-eks)).

**Steps:**
1. Fill in your own log group, cluster name, host name, etc. values into `demo-k8s.yaml`, `install.sh`, and `create-aws-exception-handler.sh`.
2. Run `install.sh`, then `create-aws-exception-handler.sh`.
