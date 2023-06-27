import datetime
import json
import os
import traceback

import boto3
from boto3.dynamodb.conditions import Key

# -----Dynamo Info change here------
TABLE_NAME = os.environ.get('TABLE_NAME', "default")
DDB_PRIKEY = "deviceid"
DDB_SORT_KEY = "timestamp"
# -----Dynamo Info change here------

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(TABLE_NAME)


# ------------------------------------------------------------------------
def dynamoQuery(deviceid, requestTime):
    print("dynamoQuery start")
    valList = []
    res = table.query(
        KeyConditionExpression=
        Key(DDB_PRIKEY).eq(deviceid) &
        Key(DDB_SORT_KEY).lt(requestTime),
        ScanIndexForward=False,
        Limit=30
    )

    for row in res['Items']:
        val = row['TEMPERATURE']
        itemDict = {
            "timestamp": row['timestamp'],
            "value": int(val)
        }
        valList.append(itemDict)

    return valList


# ------------------------------------------------------------------------
# call by Lambda here.
#  Event structure : API-Gateway Lambda proxy post
# ------------------------------------------------------------------------
def lambda_handler(event, context):
    # Lambda Proxy response back template
    HttpRes = {
        "statusCode": 200,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": "",
        "isBase64Encoded": False
    }

    try:
        print("lambda_handler start")
        print(json.dumps(event))

        # get Parameters
        pathParameters = event.get('pathParameters')
        deviceid = pathParameters["deviceid"]
        requestTime = datetime.datetime.now().strftime('%Y-%m-%dT%H:%M:%S')

        resItemDict = {deviceid: ""}
        resItemDict[deviceid] = dynamoQuery(deviceid, requestTime)
        HttpRes['body'] = json.dumps(resItemDict)

    except Exception as e:
        print(traceback.format_exc())
        HttpRes["statusCode"] = 500
        HttpRes["body"] = "Lambda error. check lambda log"

    print("response:{}".format(json.dumps(HttpRes)))
    return HttpRes
