package com.awstraining.backend.business.measurements.repository;

import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBAttribute;
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBHashKey;
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBRangeKey;
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBTable;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@DynamoDBTable(tableName = "Measurements")
public class MeasurementDBEntity {
    @DynamoDBHashKey
    private String deviceId;
    @DynamoDBRangeKey
    private Long creationTime;
    @DynamoDBAttribute
    private Double value;
    @DynamoDBAttribute
    private String type;
    @DynamoDBAttribute
    private Long expiresAt;
}
