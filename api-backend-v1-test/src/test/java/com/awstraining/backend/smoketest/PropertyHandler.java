package com.awstraining.backend.smoketest;

import static java.lang.System.getProperty;

import java.io.FileReader;
import java.io.IOException;
import java.util.Properties;

class PropertyHandler {

    private String url;
    private String username;
    private String password;

    public PropertyHandler() throws IOException {

        url = getProperty("smoketest.backend.url");
        username = getProperty("smoketest.backend.username");
        password = getProperty("smoketest.backend.password");

        if (url == null) {
            final Properties properties = new Properties();
            properties.load(new FileReader("../buildprofiles/NONE-CI-config.properties"));

            url = properties.getProperty("smoketest.backend.url");
            username = properties.getProperty("smoketest.backend.username");
            password = properties.getProperty("smoketest.backend.password");
        }
    }

    public String getUrl() {
        return url;
    }

    public String getUsername() {
        return username;
    }

    public String getPassword() {
        return password;
    }
}
