resource "aws_dynamodb_table" "portfolio_views_count" {
  name           = "portfolio_views_count"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  attribute {
	name = "id"
	type = "S"
  }
  tags = {
	Name = "portfolio_views_count"
  }
}

resource "aws_iam_role_policy" "dynamodb-lambda-policy" {
	name = "dynamodb-lambda-policy" 
	role = aws_iam_role.lambda_role.id
	policy = jsonencode({
		Version = "2012-10-17",
		Statement = [
			{
				Action = [
					"dynamodb:PutItem",
					"dynamodb:GetItem",
					"dynamodb:UpdateItem",
					"dynamodb:DeleteItem"
				],
				Effect = "Allow",
				Resource = aws_dynamodb_table.portfolio_views_count.arn
			}
		]
	})
}