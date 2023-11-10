import logging
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ec2 = boto3.client('ec2')


def get_current_launch_template_version(template_id):
    response = ec2.describe_launch_templates(
        LaunchTemplateIds=[template_id]
    )
    return str(response['LaunchTemplates'][0]['LatestVersionNumber'])


def create_launch_template_version(template_id, ami_id):
    response = ec2.create_launch_template_version(
        LaunchTemplateId=template_id,
        SourceVersion="$Latest",
        VersionDescription="Latest-AMI",
        LaunchTemplateData={
            'ImageId': ami_id
        }
    )
    logger.info(
        'Launch template version %s created',
        response['LaunchTemplateVersion']['VersionNumber']
    )


def delete_previous_launch_template_version(template_id, previous_version):
    ec2.delete_launch_template_versions(
        LaunchTemplateId=template_id,
        Versions=[previous_version]
    )
    logger.info('Launch template version %s deleted', previous_version)


def update_launch_template(template_id, ami_id):
    previous_version = get_current_launch_template_version(template_id)

    create_launch_template_version(template_id, ami_id)

    ec2.modify_launch_template(
        LaunchTemplateId=template_id,
        DefaultVersion="$Latest"
    )
    logger.info('Launch template %s modified', template_id)

    delete_previous_launch_template_version(template_id, previous_version)
