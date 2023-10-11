import json
import logging

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    # Parse the event data
    log_data = json.loads(event['awslogs']['data'])

    # Iterate over log events
    for log_event in log_data['logEvents']:
        log_message = log_event['message']

        # Determine the exception type based on the log message
        if "java.lang.NullPointerException" in log_message:
            exception_type = "NullPointerException"
        elif "java.lang.ArithmeticException" in log_message:
            exception_type = "ArithmeticException"
        elif "java.lang.ArrayIndexOutOfBoundsException" in log_message:
            exception_type = "ArrayIndexOutOfBoundsException"
        elif "java.lang.NumberFormatException" in log_message:
            exception_type = "NumberFormatException"
        else:
            exception_type = "UnknownException"

        # Print the detected exception type
        logger.info(f"Detected Exception: {exception_type}")

    return {
        'statusCode': 200,
        'body': json.dumps('Exception handler executed successfully!')
    }
