pip3 install --user awsiotsdk

mkdir -p ~/environment/dummy_client/certs/
aws s3 cp --recursive s3://iot-bucket-20230624/keys ~/environment/dummy_client/certs/

# shellcheck disable=SC2164
cd ~/environment/dummy_client/
wget https://awsj-iot-handson.s3-ap-northeast-1.amazonaws.com/aws-iot-core-workshop/dummy_client/device_main.py -O device_main.py

# shellcheck disable=SC2164
cd ~/environment/dummy_client
wget https://www.amazontrust.com/repository/AmazonRootCA1.pem -O certs/AmazonRootCA1.pem

# shellcheck disable=SC2164
cd ~/environment/dummy_client/

DEVICES_NAME="iot-thing-20230624"
IOT_ENDPOINT="a1bm0h386spjrl-ats.iot.us-east-2.amazonaws.com"
python3 device_main.py --device_name $DEVICES_NAME --endpoint $IOT_ENDPOINT