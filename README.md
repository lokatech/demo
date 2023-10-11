# Demo For Creating Lambda Functions as Exception Handlers for a Java Spring Web App Using Cloudwatch Application Logs

## Prerequisites
1. An EKS cluster.
2. AWS CLI installed.
3. A storage class (mine is named `ebs-sc` in YAML).
4. Some kind of EKS application logs set up (I followed this tutorial: [CloudWatch Stream Container Logs in EKS](https://repost.aws/knowledge-center/cloudwatch-stream-container-logs-eks)).

## Steps
1. Fill in your own host name and other values into `demo-k8s.yaml`, 
2. Fill in your own aws-account-id and region values into install.sh
3. Create a lambda execution role. The LambdaExecutionRoleArn is required to specify the AWS Identity and Access Management (IAM) role that grants necessary permissions for your AWS Lambda function to interact with AWS services and resources. You can set it up by creating an IAM role with the required policies and attaching it to your Lambda function during its creation or update.
4. Fill in your lambda execution role arn, clusterName, awsAccountId, and region into the top of create-aws-exception-handler.sh
5. run install.sh and then create-aws-exception-handler.sh.

## About
These Lambda exception handler functions provide a powerful mechanism to enhance the resilience and monitoring capabilities of your Java Spring web application on AWS. By deploying these functions, you empower your application to proactively detect and respond to critical exceptions, such as `NullPointerException`, `ArithmeticException`, `ArrayIndexOutOfBoundsException`, and `NumberFormatException`. Beyond just error logging, these handlers can be configured to trigger various actions, including sending notifications to your operations team, recording detailed error reports, and updating custom metrics for performance monitoring. This not only ensures that your development team can quickly identify and resolve issues but also enables automated responses to critical errors, leading to improved application reliability and a smoother user experience. With these Lambda exception handlers, you're not just managing errors; you're elevating the operational maturity and overall robustness of your Java Spring web application in the AWS ecosystem.
