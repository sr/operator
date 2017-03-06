package com.pardot.bread.bambooplugin.rest;

import com.fasterxml.jackson.annotation.JsonAnySetter;
import com.fasterxml.jackson.annotation.JsonProperty;

public class Repository {
    private int id;

    @JsonProperty("full_name")
    private String fullName;

    public int getId() {
        return id;
    }

    public String getFullName() {
        return fullName;
    }

    @JsonAnySetter
    public void handleUnknown(String key, Object value) {
        // ignore extra fields
    }
}
