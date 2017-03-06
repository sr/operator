package com.pardot.bread.bambooplugin.trigger;

import com.atlassian.bamboo.collections.ActionParametersMap;
import com.atlassian.bamboo.trigger.TriggerConfigurator;
import com.atlassian.bamboo.trigger.TriggerDefinition;
import com.atlassian.bamboo.utils.error.ErrorCollection;
import com.google.common.base.Predicate;
import com.google.common.collect.Maps;
import org.apache.log4j.Logger;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

import java.util.Map;

public class GithubWebhookTriggerConfigurator implements TriggerConfigurator {
    private static final Logger log = Logger.getLogger(GithubWebhookTriggerConfigurator.class);

    private static final String PLUGIN_KEY = "com.pardot.bread.bambooplugin.pardot-bamboo-plugin:github-webhook-trigger";

    public static final Predicate<TriggerDefinition> IS_ACTIVE_GITHUB_WEBHOOK_TRIGGER = new Predicate<TriggerDefinition>()  {
        @Override
        public boolean apply(@javax.annotation.Nullable TriggerDefinition triggerDefinition) {
            return triggerDefinition != null && triggerDefinition.isEnabled() && PLUGIN_KEY.equals(triggerDefinition.getPluginKey());
        }
    };

    @Override
    public void populateContextForCreate(@NotNull Map<String, Object> map) {

    }

    @Override
    public void populateContextForEdit(@NotNull Map<String, Object> map, @NotNull TriggerDefinition triggerDefinition) {

    }

    @Override
    public void populateContextForView(@NotNull Map<String, Object> map, @NotNull TriggerDefinition triggerDefinition) {

    }

    @Override
    public void validate(@NotNull ActionParametersMap actionParametersMap, @NotNull ErrorCollection errorCollection) {

    }

    @NotNull
    @Override
    public Map<String, String> generateTriggerConfigMap(@NotNull ActionParametersMap actionParametersMap, @Nullable TriggerDefinition triggerDefinition) {
        return Maps.newHashMap();
    }

    @NotNull
    @Override
    public RepositorySelectionMode getRepositorySelectionMode() {
        return RepositorySelectionMode.ALL;
    }
}
