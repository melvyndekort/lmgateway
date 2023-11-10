import os
import logging

from ami_refresher import refresher, terminator, ami_fetcher

logger = logging.getLogger()
logger.setLevel(logging.INFO)

template_arn_x86 = os.environ['TEMPLATE_ARN_X86']
template_arn_arm = os.environ['TEMPLATE_ARN_ARM']

ami_param_path_x86 = os.environ['AMI_PARAM_PATH_X86']
ami_param_path_arm = os.environ['AMI_PARAM_PATH_ARM64']


def handle(event, context):
    logger.info('Event: %s', event)

    logger.info('Updating X86 launch template')
    ami_id_x86 = ami_fetcher.get_ami_id(ami_param_path_x86)
    refresher.update_launch_template(
        template_id=template_arn_x86,
        ami_id=ami_id_x86
    )

    logger.info('Updating ARM launch template')
    ami_id_arm = ami_fetcher.get_ami_id(ami_param_path_arm)
    refresher.update_launch_template(
        template_id=template_arn_x86,
        ami_id=ami_id_arm
    )

    logger.info('Terminating running instances')
    terminator.terminate_instances()
