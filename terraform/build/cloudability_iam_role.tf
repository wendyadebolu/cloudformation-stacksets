data "aws_iam_policy_document" "AWSCloudFormationStackSetAdministrationRole_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["cloudformation.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_organizations_organization" "example" {}

resource "aws_iam_role" "AWSCloudFormationStackSetAdministrationRole" {
  assume_role_policy = data.aws_iam_policy_document.AWSCloudFormationStackSetAdministrationRole_assume_role_policy.json
  name               = "AWSCloudFormationStackSetAdministrationRole"
}

data "aws_iam_policy_document" "AWSCloudFormationStackSetExecutionRole_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = [aws_iam_role.AWSCloudFormationStackSetAdministrationRole.arn]
      type        = "AWS"
    }
  }
}

resource "aws_iam_role" "AWSCloudFormationStackSetExecutionRole" {
  assume_role_policy = data.aws_iam_policy_document.AWSCloudFormationStackSetExecutionRole_assume_role_policy.json
  name               = "AWSCloudFormationStackSetExecutionRole"
}

resource "aws_cloudformation_stack_set" "example" {
  name                = "CCOE-Finops-Apptio-Cloudability"
  administration_role_arn = aws_iam_role.AWSCloudFormationStackSetAdministrationRole.arn
  execution_role_name = "ApptioCloudabilityRole"

  # ... other configuration ...

  auto_deployment {
    enabled                       = true
    retain_stacks_on_account_removal = false
  }
  parameters = {
    ExternalId = "799c9320-63d8-4291-ac14-47c456760f36"
    RoleName = "CCOE-Finops-Cloudability-Role"
    TrustedAccountId = "165736516723"
    User = "Cloudability"
  }
}

resource "aws_cloudformation_stack_set_instance" "example" {
  deployment_targets {
    organizational_unit_ids = [data.aws_organizations_organization.example.id]
  }

  region         = var.region
  stack_set_name = aws_cloudformation_stack_set.example.name
}