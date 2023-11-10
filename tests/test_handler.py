import pytest
import os

@pytest.fixture
def test_variables():
    os.environ["TEMPLATE_ARN_X86"] = "template-arn"
    os.environ["TEMPLATE_ARN_ARM"] = "template-arn"
    os.environ["AMI_PARAM_PATH_X86"] = "ami-path"
    os.environ["AMI_PARAM_PATH_ARM64"] = "ami-path"

def test_handler_success(monkeypatch, test_variables, aws_credentials):
    ami_patch_called = 0
    template_patch_called = 0
    terminate_patch_called = 0

    from ami_refresher import handler, refresher, terminator, ami_fetcher

    def mock_get_ami_id(path):
        nonlocal ami_patch_called
        ami_patch_called += 1
        assert path == 'ami-path'
        return 'mocked-ami-id'

    def mock_update_launch_template(template_id, ami_id):
        nonlocal template_patch_called
        template_patch_called += 1
        assert template_id == 'template-arn'
        assert ami_id == 'mocked-ami-id'

    def mock_terminate_instances():
        nonlocal terminate_patch_called
        terminate_patch_called += 1

    monkeypatch.setattr(ami_fetcher, "get_ami_id", mock_get_ami_id)
    monkeypatch.setattr(refresher, "update_launch_template", mock_update_launch_template)
    monkeypatch.setattr(terminator, "terminate_instances", mock_terminate_instances)

    handler.handle(None, None)

    assert ami_patch_called == 2
    assert template_patch_called == 2
    assert terminate_patch_called == 1
