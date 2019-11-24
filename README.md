Utility to creating a new S3 bucket and get limited user credentials.

-----------------------

1. Put AWS credentials in $HOME/.aws/credentials

```
[terraform]
aws_access_key_id=AKIfdsfdsf
aws_secret_access_key=qtUfndssdfdfrrtjggkd
```

2. Run commands

```
terraform init
make s3 name=super-bucket-name
```

Terraform will create bucket and user named *****super-bucket-name** in **eu-central** region.
