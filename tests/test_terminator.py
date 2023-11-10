import boto3

from moto import mock_ec2

@mock_ec2
def test_terminator_success(monkeypatch, aws_credentials):
    from ami_refresher import terminator

    client = boto3.client('ec2')

    ami_id = 'ami-03cf127a'
    resp = client.run_instances(
        ImageId=ami_id,
        MinCount=1,
        MaxCount=1,
        TagSpecifications=[
            {
                'ResourceType': 'instance',
                'Tags': [
                    {
                        'Key': 'Name',
                        'Value': 'lmgateway',
                    },
                ],
            },
        ],
    )
    assert len(resp["Instances"]) == 1

    terminator.terminate_instances()

    reservation = client.describe_instances()["Reservations"][0]
    instance = reservation['Instances'][0]
    assert instance['ImageId'] == ami_id
    assert instance['State']['Name'] == "terminated"
