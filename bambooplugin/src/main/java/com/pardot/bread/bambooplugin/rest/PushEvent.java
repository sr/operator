package com.pardot.bread.bambooplugin.rest;

import com.fasterxml.jackson.annotation.JsonAnySetter;

public class PushEvent {
    private String ref;
    private boolean created;
    private boolean deleted;
    private Repository repository;

    public String getRef() {
        return ref;
    }

    public String getBranchName() {
        if (refIsBranch()) {
            return ref.replaceFirst("refs/heads/", "");
        } else {
            return null;
        }
    }

    public boolean refIsBranch() {
        return ref != null && ref.startsWith("refs/heads/");
    }

    public Repository getRepository() {
        return repository;
    }

    public boolean isCreated() {
        return created;
    }

    public boolean isDeleted() {
        return deleted;
    }

    @JsonAnySetter
    public void handleUnknown(String key, Object value) {
        // ignore extra fields
    }
}
