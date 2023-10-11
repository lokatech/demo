#!/bin/bash

# Define variables
clusterName="<cluster-name>"
awsAccountId="<aws-account-id>"
region="<your-region>"
lambdaHandlerFile="aws-lambda/exception_handler.py"  # Python handler file
lambdaExecutionRoleArn="<your-lambda-execution-role-arn>"  # Add your Lambda execution role ARN here

# Define your log group and log stream with wildcards in log-stream-name
logGroupArn="arn:aws:logs:$region:$awsAccountId:log-group:/aws/containerinsights/$clusterName/application:*"
logStreamName="*application.var.log.containers.demo*"

# Create a Lambda function for handling exception log events
aws lambda create-function \
  --function-name ExceptionHandler \
  --runtime python3.8 \
  --handler aws-lambda/exception_handler.lambda_handler \
  --role "lambdaExecutionRoleArn" \
  --code file://$lambdaHandlerFile \
  --region $region

# Create an Event Source Mapping for the ExceptionHandler Lambda function
aws lambda create-event-source-mapping \
  --function-name ExceptionHandler \
  --batch-size 1 \
  --event-source /aws/logs/"$logGroupArn"/ExceptionFilter \
  --region $region

# Define the exception filter patterns and metric names in a JSON file
# This file can be used as input to create metric filters for different exceptions
exception_config='[
    {
        "filterName": "JavaNullPointerExceptionFilter",
        "filterPattern": "{ ($.log.level = \"ERROR\") && ($.log.message = \"*java.lang.NullPointerException*\") }",
        "metricName": "NullPointerExceptionCount"
    },
    {
        "filterName": "JavaArithmeticExceptionFilter",
        "filterPattern": "{ ($.log.level = \"ERROR\") && ($.log.message = \"*java.lang.ArithmeticException*\") }",
        "metricName": "ArithmeticExceptionCount"
    },
    {
        "filterName": "JavaArrayIndexOutOfBoundsExceptionFilter",
        "filterPattern": "{ ($.log.level = \"ERROR\") && ($.log.message = \"*java.lang.ArrayIndexOutOfBoundsException*\") }",
        "metricName": "ArrayIndexOutOfBoundsExceptionCount"
    },
    {
        "filterName": "JavaNumberFormatExceptionFilter",
        "filterPattern": "{ ($.log.level = \"ERROR\") && ($.log.message = \"*java.lang.NumberFormatException*\") }",
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
