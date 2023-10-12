#!/bin/bash

# Define variables
clusterName="<eks-cluster-name>"
awsAccountId="<aws-account-id>"
region="<cluster-region>"
lambdaHandlerFile="aws-lambda/exception_handler.py"  # Python handler file
lambdaExecutionRoleArn="<role-arn>"  # Add your Lambda execution role ARN here

# Define your log group and log stream with wildcards in log-stream-name
logGroupArn="arn:aws:logs:$region:$awsAccountId:log-group:/aws/containerinsights/$clusterName/application:*"
logStreamName="*application.var.log.containers.demo*"

# Create a Lambda function for handling exception log events
aws lambda create-function \
  --function-name ExceptionHandler \
  --runtime python3.8 \
  --handler exception_handler.lambda_handler \
  --role "$lambdaExecutionRoleArn" \
  --zip-file "fileb://$lambdaHandlerFile" \
  --region "$region"

# Create a subscription filter to forward log events to the Lambda function
aws logs put-subscription-filter \
  --log-group-name "$logGroupArn" \
  --filter-name "ExceptionFilter" \
  --filter-pattern "" \
  --destination-arn "$(aws lambda list-functions --query 'Functions[?FunctionName==`ExceptionHandler`].FunctionArn' --output text)" \
  --role-arn "$lambdaExecutionRoleArn"

# Define the exception filter patterns and metric names in a JSON file
# This file can be used as input to create metric filters for different exceptions
exception_config='[
    {
        "filterName": "JavaNullPointerExceptionFilter",
        "filterPattern": "{ ($.log.level = \"ERROR\") && ($.log.message = \"*threw exception*java.lang.NullPointerException*\") }",
        "metricName": "NullPointerExceptionCount"
    },
    {
        "filterName": "JavaArithmeticExceptionFilter",
        "filterPattern": "{ ($.log.level = \"ERROR\") && ($.log.message = \"*threw exception*java.lang.ArithmeticException*\") }",
        "metricName": "ArithmeticExceptionCount"
    },
    {
        "filterName": "JavaArrayIndexOutOfBoundsExceptionFilter",
        "filterPattern": "{ ($.log.level = \"ERROR\") && ($.log.message = \"**threw exception*java.lang.ArrayIndexOutOfBoundsException*\") }",
        "metricName": "ArrayIndexOutOfBoundsExceptionCount"
    },
    {
        "filterName": "JavaNumberFormatExceptionFilter",
        "filterPattern": "{ ($.log.level = \"ERROR\") && ($.log.message = \"*threw exception*java.lang.NumberFormatException*\") }",
        "metricName": "NumberFormatExceptionCount"
    }
]'

# Create metric filters for different exceptions based on the configuration
for exception in $exception_config; do
    filterName=$(echo $exception | jq -r '.filterName')
    filterPattern=$(echo $exception | jq -r '.filterPattern')
    metricName=$(echo $exception | jq -r '.metricName')

    aws logs put-metric-filter \
      --log-group-name "$logGroupArn" \
      --filter-name "$filterName" \
      --filter-pattern "$filterPattern" \
      --metric-transformations '[{ "metricName": "'"$metricName"'", "metricValue": "1" }]' \
      --region "$region"
done
