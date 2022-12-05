const AWS = require('aws-sdk');
const docClient = new AWS.DynamoDB.DocumentClient();

const params = {
  TableName : process.env.DYNAMODB_TABLE_NAME,
  Key: {
    key1: 'dynamic-content'
  }
}

async function getItem(){
  try {
    const data = await docClient.get(params).promise()
    return data
  } catch (err) {
    return err
  }
}

exports.handler = async () => {
  try {
    const data = await getItem()
    return { 
      statusCode: 200,
      body: data.Item.data }
  } catch (err) {
    return { error: err }
  }
}