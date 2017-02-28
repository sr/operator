package com.pardot.bread.bambooplugin.rest;

import com.atlassian.bamboo.build.PlanCreationDeniedException;
import com.atlassian.bamboo.build.PlanCreationException;
import com.atlassian.bamboo.build.creation.PlanCreationService;
import com.atlassian.bamboo.plan.PlanKey;
import com.atlassian.bamboo.plan.PlanManager;
import com.atlassian.bamboo.plan.branch.*;
import com.atlassian.bamboo.plan.cache.CachedPlanManager;
import com.atlassian.bamboo.plan.cache.ImmutableChain;
import com.atlassian.bamboo.plan.cache.ImmutableTopLevelPlan;
import com.atlassian.bamboo.security.ImpersonationHelper;
import com.atlassian.bamboo.trigger.TriggerDefinition;
import com.atlassian.bamboo.util.CacheAwareness;
import com.atlassian.bamboo.utils.BambooRunnables;
import com.atlassian.bamboo.v2.events.ChangeDetectionRequiredEvent;
import com.atlassian.event.api.EventPublisher;
import com.atlassian.plugin.spring.scanner.annotation.imports.ComponentImport;
import com.atlassian.plugins.rest.common.security.AnonymousAllowed;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.collect.*;
import com.pardot.bread.bambooplugin.GithubTriggeredPlan;
import com.pardot.bread.bambooplugin.trigger.GithubWebhookTriggerConfigurator;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.security.InvalidParameterException;
import javax.ws.rs.Consumes;
import javax.ws.rs.HeaderParam;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.Map;

@Path("/github/events")
@Component
public class GithubEventResource {
    private static final Logger log = Logger.getLogger(GithubEventResource.class);

    private final CachedPlanManager cachedPlanManager;
    private final PlanManager planManager;
    private final EventPublisher eventPublisher;
    private final BranchDetectionService branchDetectionService;

    @Autowired
    public GithubEventResource(@ComponentImport final CachedPlanManager cachedPlanManager,
                               @ComponentImport final PlanManager planManager,
                               @ComponentImport final EventPublisher eventPublisher,
                               @ComponentImport final BranchDetectionService branchDetectionService) {
        this.cachedPlanManager = cachedPlanManager;
        this.planManager = planManager;
        this.eventPublisher = eventPublisher;
        this.branchDetectionService = branchDetectionService;
    }

    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @AnonymousAllowed
    public Response postHook(@HeaderParam("X-GitHub-Event") final String githubEvent,
                             final Map<String, Object> body) {
        ObjectMapper mapper = new ObjectMapper();
        if (githubEvent == null) {
            log.warn("X-GitHub-Event header was not provided");
            return Response.status(Response.Status.BAD_REQUEST).build();
        } else if (githubEvent.equals("push")) {
            PushEvent event = mapper.convertValue(body, PushEvent.class);
            return postPushEvent(event);
        } else {
            log.warn("Unsupported X-GitHub-Event header value: " + githubEvent);
            return Response.noContent().build();
        }
    }

    private Response postPushEvent(final PushEvent event) {
        if (event.getRepository() == null) {
            log.warn("event.repository was null");
            return Response.status(Response.Status.BAD_REQUEST).build();
        }

        if (!event.refIsBranch()) {
            // This push didn't affect a branch. It shouldn't kick off a build
            log.info("event.ref was not a branch: " + event.getRef());
            return Response.noContent().build();
        }

        // System authority is required to see all of the build plans that might be triggered. Otherwise, only builds
        // visible to anonymous users would be triggered.
        ImpersonationHelper.runWithSystemAuthority(new BambooRunnables.NotThrowing() {
            @Override
            public void run() throws RuntimeException {
                log.info(String.format("Received GitHub push webhook for '%s', branch '%s'",
                        event.getRepository().getFullName(),
                        event.getBranchName()
                ));

                createOrTriggerBranchPlans(event.getRepository().getFullName(), event.getBranchName());
            }
        });

        return Response.noContent().build();
    }

    private void createOrTriggerBranchPlans(final String repositoryFullName, final String branchName) {
        for (ImmutableTopLevelPlan topLevelPlan : cachedPlanManager.getPlans()) {
            if (!GithubTriggeredPlan.hasActiveGitHubTrigger(topLevelPlan)) {
                continue;
            }
            if (!GithubTriggeredPlan.defaultRepositoryMatchesFullName(topLevelPlan, repositoryFullName)) {
                continue;
            }

            if (GithubTriggeredPlan.defaultRepositoryMatchesBranchName(topLevelPlan, branchName)) {
                triggerChangeDetection(topLevelPlan);
            } else {
                boolean foundExistingBranchPlan = false;
                for (ImmutableChain plan : cachedPlanManager.getBranchesForChain(topLevelPlan)) {
                    if (GithubTriggeredPlan.defaultRepositoryMatchesBranchName(plan, branchName)) {
                        foundExistingBranchPlan = true;
                        triggerChangeDetection(plan);
                        break;
                    }
                }

                if (!foundExistingBranchPlan) {
                    final BranchMonitoringConfiguration bmConfig = topLevelPlan.getBuildDefinition().getBranchMonitoringConfiguration();
                    if (bmConfig.isPlanBranchCreationEnabled()) {
                        createNewBranchPlan(topLevelPlan, branchName);
                    }
                }
            }
        }
    }

    private void createNewBranchPlan(final ImmutableTopLevelPlan topLevelPlan, String branchName) {
        log.info(String.format(
                "Creating branch plan for branch '%s' in plan '%s'",
                branchName,
                topLevelPlan.getPlanKey().toString()
        ));

        final VcsBranch vcsBranch = new VcsBranchImpl(branchName);
        final String chainBranchName = ChainBranchUtils.getValidChainBranchName(vcsBranch);
        try {
            final PlanKey branchKey = branchDetectionService.createChainBranch(
                    topLevelPlan,
                    chainBranchName,
                    vcsBranch,
                    null,
                    PlanCreationService.EnablePlan.ENABLED,
                    true
            );

            log.info(String.format(
                    "Created branch plan '%s' for branch '%s'",
                    branchKey,
                    branchName
            ));
        } catch (PlanCreationDeniedException|PlanCreationException|InvalidParameterException e) {
            log.warn("Unable to create branch plan: " + e.getMessage());
        }
    }

    private void triggerChangeDetection(final ImmutableChain plan) {
        log.info(String.format(
                "Triggering change detection for '%s'",
                plan.getPlanKey()
        ));

        ensurePlanEnabled(plan);
        final Iterable<TriggerDefinition> triggerDefinitions = Iterables.filter(plan.getTriggerDefinitions(),
                GithubWebhookTriggerConfigurator.IS_ACTIVE_GITHUB_WEBHOOK_TRIGGER);
        for (TriggerDefinition triggerDefinition : triggerDefinitions) {
            ChangeDetectionRequiredEvent cdrEvent = new ChangeDetectionRequiredEvent(this,
                    plan.getPlanKey(),
                    triggerDefinition,
                    true,
                    CacheAwareness.CHANGE_DETECTION
            );

            eventPublisher.publish(cdrEvent);
        }
    }

    private void ensurePlanEnabled(ImmutableChain cachedPlan) {
        if (cachedPlan.isSuspendedFromBuilding()) {
            planManager.setPlanSuspendedState(cachedPlan.getPlanKey(), false);
        }
    }
}