#!/bin/bash

# Define variables
clusterName="<eks-cluster-name>"
awsAccountId="<aws-account-id>"
region="<cluster-region>"
lambdaHandlerFile="aws-lambda/exception_handler.py"  # Python handler file
lambdaExecutionRoleArn="<role-arn>"  # Add your Lambda execution role ARN here
metricNamespace="<metric-namespace>"  # Define the metric namespace here
logGroupName="/aws/containerinsights/$clusterName/application"

# Define your log group with a specific log stream pattern for the "demo" deployment
logGroupArn="arn:aws:logs:$region:$awsAccountId:log-group:/aws/containerinsights/$clusterName/application:*"

# Create a Lambda function for handling exception log events
functionArn=$(aws lambda create-function \
  --function-name ExceptionHandler \
  --runtime python3.8 \
  --handler exception_handler.lambda_handler \
  --role "$lambdaExecutionRoleArn" \
  --zip-file "fileb://$lambdaHandlerFile" \
  --region "$region" \
  --output json | jq -r '.FunctionArn')

# Create metric filter for JavaNullPointerException
aws logs put-metric-filter \
  --log-group-name "$logGroupName" \
  --filter-name "JavaNullPointerExceptionFilter" \
  --filter-pattern '{ ($.log.level = "ERROR") && ($.log.message = "*threw exception*java.lang.NullPointerException*") && ($.kubernetes.container_name = "demo") }' \
  --metric-transformations '[{ "metricName": "NullPointerExceptionCount", "metricValue": 1, "metricNamespace": "$metricNamespace" }]' \
  --region "$region"

# Create metric filter for JavaArithmeticException
aws logs put-metric-filter \
  --log-group-name "$logGroupName" \
  --filter-name "JavaArithmeticExceptionFilter" \
  --filter-pattern '{ ($.log.level = "ERROR") && ($.log.message = "*threw exception*java.lang.ArithmeticException*") && ($.kubernetes.container_name = "demo") }' \
  --metric-transformations '[{ "metricName": "ArithmeticExceptionCount", "metricValue": 1, "metricNamespace": "$metricNamespace" }]' \
  --region "$region"

# Create metric filter for JavaArrayIndexOutOfBoundsException
aws logs put-metric-filter \
  --log-group-name "$logGroupName" \
  --filter-name "JavaArrayIndexOutOfBoundsExceptionFilter" \
  --filter-pattern '{ ($.log.level = "ERROR") && ($.log.message = "*threw exception*java.lang.ArrayIndexOutOfBoundsException*") && ($.kubernetes.container_name = "demo") }' \
  --metric-transformations '[{ "metricName": "ArrayIndexOutOfBoundsExceptionCount", "metricValue": 1, "$metricNamespace": "LokatechDemo" }]' \
  --region "$region"

# Create metric filter for JavaNumberFormatException
aws logs put-metric-filter \
  --log-group-name "$logGroupName" \
  --filter-name "JavaNumberFormatExceptionFilter" \
  --filter-pattern '{ ($.log.level = "ERROR") && ($.log.message = "*threw exception*java.lang.NumberFormatException*") && ($.kubernetes.container_name = "demo") }' \
  --metric-transformations '[{ "metricName": "NumberFormatExceptionCount", "metricValue": 1, "$metricNamespace": "LokatechDemo" }]' \
  --region "$region"

aws lambda add-permission \
  --function-name "ExceptionHandler" \
  --statement-id "ExceptionHandler" \
  --principal "logs.amazonaws.com" \
  --action "lambda:InvokeFunction" \
  --source-arn "$functionArn" \
  --source-account "$awsAccountId"

# Add subscription filter to route log events to the Lambda function
aws logs put-subscription-filter \
  --log-group-name "$logGroupName" \
  --filter-name "SubscriptionFilter" \
  --filter-pattern '{$.log.level = "ERROR"}' \
  --destination-arn "$functionArn" \
  --region "$region"

echo "Setup completed!"