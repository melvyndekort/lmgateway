import boto3

from moto import mock_ssm

@mock_ssm
def test_ami_fetcher_success(aws_credentials):
    from ami_refresher import ami_fetcher

    param_name = 'foo'
    param_value = 'bar'

    ssm = boto3.client("ssm")

    ssm.put_parameter(
        Name=param_name,
        Value=param_value,
        Type="String",
    )

    value = ami_fetcher.get_ami_id(param_name)
    assert value == param_value
