import logging
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ssm = boto3.client('ssm')


def get_ami_id(param_name):
    response = ssm.get_parameter(
        Name=param_name
    )

    value = response['Parameter']['Value']
    logger.info('Retrieved AMI_ID from parameter store: %s', value)
    return value
