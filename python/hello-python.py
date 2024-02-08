import json
import boto3

def lambda_handler(event, context):
    try:
        visit_count = 0
        
        # dynamodb client
        dynamodb = boto3.resource("dynamodb")
        table_name = "portfolio_views_count"
        
        table = dynamodb.Table(table_name)
        
        
        # visit
        
        response = table.get_item(Key={"id": "monge1h.com"})
        if "Item" in response:
            visit_count = int(response["Item"]["count"])
            
        visit_count += 1
        
        table.put_item(Item={"id":"monge1h.com", "count": visit_count})

        return {
            'statusCode': 200,
            'body': json.dumps({"views": visit_count})
        }

    except Exception as e:
        error_message = str(e)
        return {
            'statusCode': 500,
            'body': json.dumps({"error": error_message})
        }