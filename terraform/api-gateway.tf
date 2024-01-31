resource "aws_apigatewayv2_api" "main" {
  name 		= "viewer_count_api"
  protocol_type = "HTTP"
#   target        = aws_lambda_function.viewer_count_lambda.invoke_arn
}

resource "aws_apigatewayv2_stage" "prod" {
  api_id = aws_apigatewayv2_api.main.id
  name   = "prod"

  auto_deploy = true

  access_log_settings {
	destination_arn = aws_cloudwatch_log_group.lambda_log_group.arn

	format = jsonencode({
	requestId = "$context.requestId",
	ip = "$context.identity.sourceIp",
	user = "$context.identity.user",
	requestTime = "$context.requestTime",
	httpMethod = "$context.httpMethod",
	routeKey = "$context.routeKey",
	statusCode = "$context.status",
	responseLength = "$context.responseLength"
	integrationError = "$context.integrationErrorMessage"
	source = "apigateway"
	protocol = "$context.protocol",
	})
  }
}

resource "aws_apigatewayv2_integration" "viewer_count_lambda" {
  api_id = aws_apigatewayv2_api.main.id

  integration_uri = aws_lambda_function.viewer_count_lambda.invoke_arn
  integration_method = "POST"
  integration_type = "AWS_PROXY"
}

resource "aws_apigatewayv2_route" "get" {
  api_id = aws_apigatewayv2_api.main.id

  route_key = "GET /viewer_count"
  target = "integrations/${aws_apigatewayv2_integration.viewer_count_lambda.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.viewer_count_lambda.function_name
  principal = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

output "lambda_url" {
  value = aws_apigatewayv2_api.main.api_endpoint
}