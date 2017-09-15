variable "master_account_profile" {
  type = "string"
}
provider "aws" {
  profile = "${var.master_account_profile}"
  region = "us-east-1"
}

resource "aws_iam_user" "okta" {
  name = "svc_okta"
}

resource "aws_iam_access_key" "okta" {
  user = "${aws_iam_user.okta.name}"
}

resource "aws_iam_user_policy" "okta_policy" {
  name = "access_to_remote_accounts"
  user = "${aws_iam_user.okta.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:GetAccountSummary",
                "iam:ListRoles",
                "iam:ListAccountAliases",
                "iam:GetUser",
                "sts:AssumeRole"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

data "aws_caller_identity" "current" {}

module "alpha_account" {
  master_account_id = "${data.aws_caller_identity.current.account_id}"
  source = "modules/okta_access"
  profile = "alpha_account"
}
