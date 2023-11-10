import logging
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ec2 = boto3.client('ec2')


def get_instances():
    response = ec2.describe_instances(
        Filters=[
            {
                'Name': 'tag:Name',
                'Values': ['lmgateway']
            }, {
                'Name': 'instance-state-name',
                'Values': ['running']
            }
        ]
    )

    instance_list = []

    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            instance_list.append(instance['InstanceId'])

    return instance_list


def terminate_instances():
    instance_list = get_instances()
    logger.info('Terminating instances: %s', instance_list)

    ec2.terminate_instances(
        InstanceIds=instance_list
    )
