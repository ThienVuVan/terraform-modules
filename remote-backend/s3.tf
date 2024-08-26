resource "aws_s3_bucket" "s3_bucket" {
  bucket = "s3-remote-backend"
  force_destroy = false
  tags = {
    Name = "tf-bucket"
  }
}

resource "aws_s3_bucket_versioning" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_kms_key" "kms_key" {
  tags = {
    Name = "tf-bucket-kms"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.kms_key.arn
    }
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}


data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    sid       = "Stmt1680819929502"
    effect    = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::<account>:user/USER"]
    }

    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::S3-BUCKET-NAME",
      "arn:aws:s3:::S3-BUCKET-NAME/global/s3/terraform.tfstate",
    ]
  }

  statement {
    sid       = "Stmt1680819959950"
    effect    = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:DeleteBucket",
    ]

    resources = [
      "arn:aws:s3:::S3-BUCKET-NAME",
    ]
  }
}