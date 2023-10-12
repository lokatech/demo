# Demo For Creating Lambda Functions as Exception Handlers for a Java Spring Web App Using Cloudwatch Application Logs

## Prerequisites
1. An EKS cluster.
2. AWS CLI installed.
3. A storage class (mine is named `ebs-sc` in YAML).
4. Some kind of EKS application logs set up (I followed this tutorial: [CloudWatch Stream Container Logs in EKS](https://repost.aws/knowledge-center/cloudwatch-stream-container-logs-eks)).

## Steps
1. Fill in your own host name and other values into `demo-k8s.yaml`.
2. Fill in your own AWS account ID, region, and Lambda execution role ARN values into `install.sh`.
3. Create a Lambda execution role with the necessary permissions. This IAM role grants permissions for your AWS Lambda function to interact with AWS services and resources, including CloudWatch Logs. Follow these steps to create the role:
    1. Open the AWS IAM Console: Log in to your AWS Management Console and navigate to the Identity and Access Management (IAM) console.
    2. Create a New Role:
        - In the left navigation pane, select "Roles."
        - Click the "Create role" button.
    3. Select Your Use Case:
        - In the "Select type of trusted entity" section, select "AWS service."
        - In the "Choose the use case" section, search for and select "Lambda."
    4. Add Permissions:
        - In the "Permissions" section, attach policies to the role based on the specific permissions your Lambda function needs. For your use case, you will need at least the following permissions:
          - In the "Permissions" section, attach policies to the role based on the specific permissions your Lambda function needs. For your use case, you can create custom policies with the required permissions. Here is an example policy JSON with the necessary permissions for Lambda and CloudWatch Logs:

        ```json
        {
          "Version": "2012-10-17",
          "Statement": [
            {
              "Effect": "Allow",
              "Action": [
                "lambda:CreateFunction",
                "lambda:CreateEventSourceMapping",
                "logs:PutMetricFilter",
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogGroups"
              ],
              "Resource": "*"
            }
          ]
        }
        ```
    5. Add Tags (Optional):
        - You can add tags for easier identification if desired.
    6. Review and Create:
        - Give your role a name and optionally a description.
        - Review the role configuration to ensure it has the necessary permissions.
    7. Create Role:
        - Click the "Create role" button to create the role.
    8. Copy the Role ARN:
        - After creating the role, you will see a summary page for the role. Copy the Role ARN from this page.
    9. Update Your Script:
        - Replace `<your-lambda-execution-role-arn>` in your script with the actual Role ARN you copied in the previous step.
4. Fill in your Lambda execution role ARN, clusterName, AWS account ID, and region into the top of `create-aws-exception-handler.sh`.
5. Run `install.sh`.
6. Run `create-aws-exception-handler.sh`.


## About
These Lambda exception handler functions provide a powerful mechanism to enhance the resilience and monitoring capabilities of your Java Spring web application on AWS. By deploying these functions, you empower your application to proactively detect and respond to critical exceptions, such as `NullPointerException`, `ArithmeticException`, `ArrayIndexOutOfBoundsException`, and `NumberFormatException`. Beyond just error logging, these handlers can be configured to trigger various actions, including sending notifications to your operations team, recording detailed error reports, and updating custom metrics for performance monitoring. This not only ensures that your development team can quickly identify and resolve issues but also enables automated responses to critical errors, leading to improved application reliability and a smoother user experience. With these Lambda exception handlers, you're not just managing errors; you're elevating the operational maturity and overall robustness of your Java Spring web application in the AWS ecosystem.
