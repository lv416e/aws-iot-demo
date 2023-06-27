CREATE EXTERNAL TABLE IF NOT EXISTS `${athena_db_name}`.`${athena_tbl_name}`
(
    `DEVICE_NAME` string,
    `HUMIDITY`    string,
    `TEMPERATURE` string
)
    PARTITIONED BY (`orderdate` string)
    ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
        WITH SERDEPROPERTIES (
        'serialization.format' = '1'
        )
    LOCATION 's3://${s3_bucket_name}/logs/'
    TBLPROPERTIES (
        'projection.enabled' = 'true',
        'projection.orderdate.type' = 'date',
        'projection.orderdate.range' = '2023/06/01,2023/06/30',
        'projection.orderdate.format' = 'yyyy/MM/dd',
        'projection.orderdate.interval' = '1',
        'projection.orderdate.interval.unit' = 'DAYS',
        'storage.location.template' = 's3://${s3_bucket_name}/logs/$${orderdate}'
        );