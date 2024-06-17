package com.awstraining.backend.business.measurements.repository;

import java.util.List;

import com.awstraining.backend.business.measurements.exceptions.CouldNotSaveMeasurementException;

public interface MeasurementRepository {
    void save(final MeasurementDBEntity measurementDbEntity) throws CouldNotSaveMeasurementException;
    List<MeasurementDBEntity> getAll();
}
