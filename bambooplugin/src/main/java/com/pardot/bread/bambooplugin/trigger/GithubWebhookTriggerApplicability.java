package com.pardot.bread.bambooplugin.trigger;

import com.atlassian.bamboo.trigger.applicability.CanTriggerPlansWithRepositories;
import com.atlassian.plugin.spring.scanner.annotation.export.ExportAsService;

@ExportAsService
public class GithubWebhookTriggerApplicability extends CanTriggerPlansWithRepositories {
}
