resource "aws_dynamodb_table" "webapp-storage-table" {
 name = var.dynamoDbTableName
 billing_mode = "PAY_PER_REQUEST"
 attribute {
  name = "key1"
  type = "S"
 }
 hash_key = "key1"
}

resource "aws_dynamodb_table_item" "webapp-dynamic-content-table-item" {
  table_name = aws_dynamodb_table.webapp-storage-table.name
  hash_key   = aws_dynamodb_table.webapp-storage-table.hash_key
  item = <<ITEM
{
  "key1": {"S": "dynamic-content"},
  "data": {"S": "stored in DynamoDb!"}
}
ITEM
}