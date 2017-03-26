package com.pardot.bread.bambooplugin;

import com.atlassian.bamboo.plan.Plan;
import com.atlassian.bamboo.plan.TopLevelPlan;
import com.atlassian.bamboo.v2.build.BaseBuildConfigurationAwarePlugin;
import com.atlassian.bamboo.v2.build.configuration.MiscellaneousBuildConfigurationPlugin;
import com.atlassian.bamboo.ww2.actions.build.admin.create.BuildConfiguration;
import org.jetbrains.annotations.NotNull;

import java.util.Map;

public class GithubStatusBuildConfiguration extends BaseBuildConfigurationAwarePlugin implements MiscellaneousBuildConfigurationPlugin {
    static final String GITHUB_STATUS_ENABLED = "custom.githubstatus.enabled";

    public static boolean isGithubStatusEnabled(final Map<String,String> customConfiguration) {
        return customConfiguration.getOrDefault(GITHUB_STATUS_ENABLED, Boolean.toString(true)).equalsIgnoreCase(Boolean.toString(true));
    }

    @Override
    public boolean isApplicableTo(@NotNull Plan plan) {
        return plan instanceof TopLevelPlan;
    }

    @Override
    public void prepareConfigObject(@NotNull BuildConfiguration buildConfiguration) {
        super.prepareConfigObject(buildConfiguration);

        if (buildConfiguration.getString(GITHUB_STATUS_ENABLED) == null) {
            buildConfiguration.setProperty(GITHUB_STATUS_ENABLED, Boolean.toString(true));
        }
    }
}
