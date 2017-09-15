# Basic Okta setup for multiple accounts

See http://saml-doc.okta.com/SAML_Docs/How-to-Configure-SAML-2.0-for-Amazon-Web-Service#scenarioB for more information, documentation, etc.  

1. First, setup Okta application and download the metdatafile to ../saml-metadata.xml
2.  Setup in ~/.aws/credentials
```
[master_account]
aws_access_key_id = access_key_here
aws_secret_access_key = api_secret_key
```

3.  Then for each account you want Okta to allow access to...
create a file (or add it to the master_user.tf file)
```
module "alpha_account" {
  source = "modules/okta_access"
  profile = "alpha_account"
}
```
and in credentials file
```
[alpha_account]
aws_access_key_id = alpha_account access key
aws_secret_access_key = alpha_account secret key
```

4. Finally run
```
terraform plan -var master_account_profile=master_account -out terraform.out
terraform apply terraform.out
```

## Note that there are some tweaks that could be made to make this significantly more secure.  E.g. the master account could be setup so that it can ONLY assume the Okta IDP roles in the remote accounts.  The remote accounts can be setup so that they restrict access to the svc_okta account.  Etc.  Additionally, I don't get into state management, credential management, access key management, etc.
