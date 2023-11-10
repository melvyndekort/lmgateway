import boto3

from moto import mock_ec2

@mock_ec2
def test_refresher_success(monkeypatch, aws_credentials):
    from ami_refresher import refresher

    client = boto3.client('ec2')

    result = client.create_launch_template(
        LaunchTemplateName='foobar',
        LaunchTemplateData={}
    )
    assert result['LaunchTemplate']['LatestVersionNumber'] == 1
    template_id = result['LaunchTemplate']['LaunchTemplateId']

    def mock_modify_launch_template(LaunchTemplateId, DefaultVersion):
        assert LaunchTemplateId == template_id

    def mock_delete_launch_template_versions(LaunchTemplateId, Versions):
        assert LaunchTemplateId == template_id

    monkeypatch.setattr(client, "modify_launch_template", mock_modify_launch_template)
    monkeypatch.setattr(client, "delete_launch_template_versions", mock_delete_launch_template_versions)
    monkeypatch.setattr(refresher, "ec2", client)

    refresher.update_launch_template(
        template_id=template_id,
        ami_id='foobar'
    )

    templates = client.describe_launch_templates()
    assert templates['LaunchTemplates'][0]['LatestVersionNumber'] == 2
