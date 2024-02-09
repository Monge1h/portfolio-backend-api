import json
import boto3
import pytest
import os
from moto import mock_dynamodb
from viewer_count import lambda_handler

@pytest.fixture
def aws_credentials():
    """Mocked AWS Credentials for moto."""
    os.environ["AWS_ACCESS_KEY_ID"] = "testing"
    os.environ["AWS_SECRET_ACCESS_KEY"] = "testing"
    os.environ["AWS_SECURITY_TOKEN"] = "testing"
    os.environ["AWS_SESSION_TOKEN"] = "testing"

@pytest.fixture
def dynamodb(aws_credentials):
    with mock_dynamodb():
        yield boto3.resource("dynamodb", region_name="us-east-1")

def create_visitor_count_table(dynamodb):
    table = dynamodb.create_table(
        TableName="portfolio_views_count",
        KeySchema=[{'AttributeName': 'id', 'KeyType': 'HASH'}],
        AttributeDefinitions=[{'AttributeName': 'id', 'AttributeType': 'S'}],
        ProvisionedThroughput={'ReadCapacityUnits': 1, 'WriteCapacityUnits': 1}
    )

    # Wait until the table exists.
    table.meta.client.get_waiter('table_exists').wait(TableName='portfolio_views_count')

    # Put an initial item
    table.put_item(Item={"id": "monge1h.com", "count": 0})
    return table

def test_lambda_handler(dynamodb):
    # Create mock table
    create_visitor_count_table(dynamodb)

    # Invoke lambda function
    response = lambda_handler(None, None)

    # Parse the response
    data = json.loads(response['body'])

    # Assertions
    assert response['statusCode'] == 200
    assert 'views' in data
    assert data['views'] == 1
