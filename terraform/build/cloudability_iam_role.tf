data "aws_iam_policy_document" "CloudFormationStackSetsOrgAdminServiceRolePolicy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["cloudformation.amazonaws.com"]
      type        = "Service"
    }
  }
}

# data "aws_organizations_organization" "example" {}

resource "aws_iam_role" "CloudFormationStackSetsOrgAdminServiceRolePolicy" {
  assume_role_policy = data.aws_iam_policy_document.CloudFormationStackSetsOrgAdminServiceRolePolicy.json
  name               = "CCOE-Finops-Cloudability"
}

data "aws_iam_policy_document" "AWSCloudFormationStackSetExecutionRole_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = [aws_iam_role.CloudFormationStackSetsOrgAdminServiceRolePolicy.arn]
      type        = "AWS"
    }
  }
}

resource "aws_iam_role" "AWSCloudFormationStackSetExecutionRole" {
  assume_role_policy = data.aws_iam_policy_document.AWSCloudFormationStackSetExecutionRole_assume_role_policy.json
  name               = "CCOE-Finops-Cloudability-Execution"
}

resource "aws_cloudformation_stack_set" "example" {
  name                = "CCOE-Finops-Apptio-Cloudability"
  permission_model = "SERVICE_MANAGED"
  capabilities            = ["CAPABILITY_NAMED_IAM"]
#   administration_role_arn = aws_iam_role.CloudFormationStackSetsOrgAdminServiceRolePolicy.arn
#   execution_role_name = aws_iam_role.AWSCloudFormationStackSetExecutionRole.name

  # ... other configuration ...

  auto_deployment {
    enabled                       = true
    retain_stacks_on_account_removal = false
  }
  parameters = {
    ExternalId = "799c9320-63d8-4291-ac14-47c456760f36"
    RoleName = "CCOE-Finops-Cloudability"
    TrustedAccountId = "165736516723"
    User = "Cloudability"
  }

  template_body = file("${path.module}/cloudabilitystacksets.yaml")
}

resource "aws_cloudformation_stack_set_instance" "example" {
  deployment_targets {
    organizational_unit_ids = ["ou-fx8h-r5x0ih9d", "ou-fx8h-oey8c1qc"]
  }
  region         = var.region
  stack_set_name = aws_cloudformation_stack_set.example.name
}