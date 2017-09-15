variable "master_account_id" {
  type = "string"
}

variable "profile" {
  type = "string"
}
variable "saml_file" {
  default = "../saml-metadata.xml"
}

provider "aws" {
  profile = "${var.profile}"
  alias = "single_account"
  region = "us-east-1"
}

resource "aws_iam_saml_provider" "default" {
  provider = "aws.single_account"
  name                   = "Okta"
  saml_metadata_document = "${file("${var.saml_file}")}"
}

resource "aws_iam_policy" "okta_read_roles_policy" {
  provider = "aws.single_account"
  name = "svc_okta_read_roles_policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:GenerateCredentialReport",
                "iam:GenerateServiceLastAccessedDetails",
                "iam:Get*",
                "iam:List*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "okta_idp_role" {
  provider = "aws.single_account"
  name = "Okta-Idp-cross-account-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.master_account_id}:user/svc_okta"
      },
      "Action": "sts:AssumeRole",
      "Condition": {}
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "attach_policy_to_okta_role" {
  provider = "aws.single_account"
  name       = "attachment"
  roles      = ["${aws_iam_role.okta_idp_role.name}"]
  policy_arn = "${aws_iam_policy.okta_read_roles_policy.arn}"
}
