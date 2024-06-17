package com.awstraining.backend.business.measurements;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class MeasurementDO {
    private String deviceId;
    private Double value;
    private String type;
    private Long creationTime;
}
