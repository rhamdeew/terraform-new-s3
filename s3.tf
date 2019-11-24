variable "bucket_name" {
  type = string
}
provider "aws" {
  region = "eu-central-1"
  profile = "terraform"
}
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  acl = "private"

  lifecycle_rule {
    enabled = true

    transition {
      days = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days = 60
      storage_class = "GLACIER"
    }
  }
}

resource "aws_iam_user" "lb" {
  name = var.bucket_name
}

resource "aws_iam_access_key" "lb" {
  user = aws_iam_user.lb.name
}

resource "aws_iam_user_policy" "lb" {
  name = "s3"
  user = aws_iam_user.lb.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["s3:ListAllMyBuckets", "s3:GetBucketLocation"],
      "Resource": "arn:aws:s3:::*",
      "Effect": "Allow"
    },
    {
      "Action": ["s3:ListBucket", "s3:GetBucketAcl"],
      "Resource": "arn:aws:s3:::*",
      "Effect": "Allow"
    },
    {
      "Action": ["s3:Put*", "s3:Get*", "s3:Del*"],
      "Resource": "arn:aws:s3:::${var.bucket_name}/*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

output "s3cmd" {
  value = <<EOF
${aws_iam_access_key.lb.id}
${aws_iam_access_key.lb.secret}

docker run --rm schickling/s3cmd --access_key=${aws_iam_access_key.lb.id} --secret_key=${aws_iam_access_key.lb.secret} ls s3://${var.bucket_name}/

docker run --rm -v $datadir:/s3 schickling/s3cmd --delete-removed --access_key=${aws_iam_access_key.lb.id} --secret_key=${aws_iam_access_key.lb.secret} sync . s3://${var.bucket_name}/
EOF
}
