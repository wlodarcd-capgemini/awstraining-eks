package com.awstraining.backend.smoketest;

import com.awstraining.backend.smoketest.api.MeasurementsApi;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class SmokeBackendTest {

    private MeasurementsApi measurementsApi;
    private ApiClient apiClient;

    private static PropertyHandler propertyHandler;

    @BeforeAll
    static void beforeAll() throws Exception {
        propertyHandler = new PropertyHandler();
    }

    @BeforeEach
    void init() {
        measurementsApi = new MeasurementsApi();
        apiClient = measurementsApi.getApiClient();


        final String url = propertyHandler.getUrl();
        final String user = propertyHandler.getUsername();
        final String pass = propertyHandler.getPassword();

        apiClient.setBasePath(url + "/backend/v1");
        apiClient.setUsername(user);
        apiClient.setPassword(pass);
        apiClient.setVerifyingSsl(false);
    }

    @Test
    void testSomething() {
        // <<TODO: test something>>
    }
}
