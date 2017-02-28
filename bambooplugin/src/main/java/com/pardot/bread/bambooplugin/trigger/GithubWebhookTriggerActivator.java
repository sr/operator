package com.pardot.bread.bambooplugin.trigger;

import com.atlassian.bamboo.trigger.TriggerActivator;
import com.atlassian.bamboo.trigger.TriggerDefinition;
import com.atlassian.bamboo.trigger.Triggerable;
import com.atlassian.plugin.spring.scanner.annotation.export.ExportAsService;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

import java.util.Date;

@ExportAsService
public class GithubWebhookTriggerActivator implements TriggerActivator {
    @Override
    public void initAndActivate(@NotNull Triggerable triggerable, @NotNull TriggerDefinition triggerDefinition, @Nullable Date date) {
    }

    @Override
    public void activate(@NotNull Triggerable triggerable, @NotNull TriggerDefinition triggerDefinition) {
    }

    @Override
    public void deactivate(@NotNull Triggerable triggerable, @NotNull TriggerDefinition triggerDefinition) {
    }
}
