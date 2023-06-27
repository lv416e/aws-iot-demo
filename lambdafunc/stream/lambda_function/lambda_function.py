import base64
import json
import os
import traceback

import boto3

# -----Dynamo Info change here------
TABLE_NAME = os.environ.get('TABLE_NAME', "default")
DDB_PRIKEY = "deviceid"
DDB_SORT_KEY = "timestamp"
DDB_ATTR = "temp"
# -----Dynamo Info change here------

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(TABLE_NAME)


def checkItem(str_data):
    try:
        # String to Json object
        json_data = json.loads(str_data)
        # adjust your data format
        resDict = {
            DDB_PRIKEY: json_data['DEVICE_NAME'],
            DDB_SORT_KEY: json_data['TIMESTAMP'],
            "HUMIDITY": json_data['HUMIDITY'],
            "TEMPERATURE": json_data['TEMPERATURE']
        }

        print("resDict:{}".format(resDict))
        return resDict

    except Exception as e:
        print(traceback.format_exc())
        return None


def writeItemInfo(datas):
    ItemInfoDictList = []
    try:
        for data in datas:
            itemDict = checkItem(data)
            if None != itemDict:
                ItemInfoDictList.append(itemDict)
            # if data does not have key info, just pass
            else:
                print("Error data found:{}".format(data))
                pass

    except Exception as e:
        print(traceback.format_exc())
        print("Error on writeItemInfo")

    return ItemInfoDictList


def DynamoBulkPut(datas):
    try:
        putItemDictList = writeItemInfo(datas)
        with table.batch_writer() as batch:
            for putItemDict in putItemDictList:
                batch.put_item(Item=putItemDict)
        return

    except Exception as e:
        print("Error on DynamoBulkPut()")
        raise e


def decodeKinesisData(dataList):
    decodedList = []
    try:
        for data in dataList:
            payload = base64.b64decode(data['kinesis']['data'])
            print("payload={}".format(payload))
            decodedList.append(payload)

        return decodedList

    except Exception as e:
        print("Error on decodeKinesisData()")
        raise e


# ------------------------------------------------------------------------
# call by Lambda here.
# ------------------------------------------------------------------------
def lambda_handler(event, context):
    print("lambda_handler start")

    try:
        print("---------------json inside----------------")
        print(json.dumps(event))
        encodeKinesisList = event['Records']
        print(encodeKinesisList)
        decodedKinesisList = decodeKinesisData(encodeKinesisList)
        # Dynamo Put
        if 0 < len(decodedKinesisList):
            DynamoBulkPut(decodedKinesisList)
        else:
            print("there is no valid data in Kinesis stream, all data passed")

        return

    except Exception as e:
        print(traceback.format_exc())
        # This is sample source. When error occur this return success and ignore the error.
        raise e
