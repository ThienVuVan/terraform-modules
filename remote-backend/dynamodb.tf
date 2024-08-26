resource "aws_dynamodb_table" "dynamodb_table" {
  name         = "tfstate-locking"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "tfstate-locking"
  }

}