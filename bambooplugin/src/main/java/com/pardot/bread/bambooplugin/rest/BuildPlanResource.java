package com.pardot.bread.bambooplugin.rest;

import com.atlassian.bamboo.build.BuildDefinition;
import com.atlassian.bamboo.build.BuildDefinitionManager;
import com.atlassian.bamboo.build.PlanCreationDeniedException;
import com.atlassian.bamboo.build.PlanCreationException;
import com.atlassian.bamboo.build.creation.*;
import com.atlassian.bamboo.caching.DashboardCachingManager;
import com.atlassian.bamboo.collections.ActionParametersMap;
import com.atlassian.bamboo.deletion.DeletionService;
import com.atlassian.bamboo.event.BuildConfigurationUpdatedEvent;
import com.atlassian.bamboo.fieldvalue.BuildDefinitionConverter;
import com.atlassian.bamboo.plan.*;
import com.atlassian.bamboo.plan.branch.BranchIntegrationConfiguration;
import com.atlassian.bamboo.plan.branch.BranchIntegrationConfigurationImpl;
import com.atlassian.bamboo.plan.branch.BranchMonitoringConfiguration;
import com.atlassian.bamboo.plan.cache.CachedPlanManager;
import com.atlassian.bamboo.plan.cache.ImmutableJob;
import com.atlassian.bamboo.plan.cache.ImmutablePlan;
import com.atlassian.bamboo.repository.*;
import com.atlassian.bamboo.spring.ComponentAccessor;
import com.atlassian.bamboo.task.*;
import com.atlassian.bamboo.trigger.TriggerConfigurationService;
import com.atlassian.bamboo.trigger.TriggerDefinition;
import com.atlassian.bamboo.trigger.TriggerModuleDescriptor;
import com.atlassian.bamboo.trigger.TriggerTypeManager;
import com.atlassian.bamboo.trigger.polling.PollingTriggerConfigurationConstants;
import com.atlassian.bamboo.vcs.configuration.PartialVcsRepositoryData;
import com.atlassian.bamboo.vcs.configuration.PlanRepositoryDefinition;
import com.atlassian.bamboo.webwork.util.ActionParametersMapImpl;
import com.atlassian.bamboo.ww2.actions.build.admin.create.BuildConfiguration;
import com.atlassian.event.api.EventPublisher;
import com.pardot.bread.bambooplugin.trigger.GithubWebhookTriggerConfigurator;
import org.apache.commons.configuration.HierarchicalConfiguration;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.HashMap;
import java.util.HashSet;

@Path("/buildplans")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class BuildPlanResource {
    private static final Logger log = Logger.getLogger(BuildPlanResource.class);

    private static final String scriptTaskKey = "com.atlassian.bamboo.plugins.scripttask:task.builder.script";
    private static final String pollTriggerKey = "com.atlassian.bamboo.triggers.atlassian-bamboo-triggers:poll";
    private static final String githubWebhookTriggerKey = GithubWebhookTriggerConfigurator.PLUGIN_KEY;

    private BuildDefinitionManager buildDefinitionManager;
    private ChainCreationService chainCreationService;
    private DashboardCachingManager dashboardCachingManager;
    private JobCreationService jobCreationService;
    private CachedPlanManager cachedPlanManager;
    private PlanManager planManager;
    private TaskManager taskManager;
    private TaskConfigurationService taskConfigurationService;
    private TriggerConfigurationService triggerConfigurationService;
    private TriggerTypeManager triggerTypeManager;
    private EventPublisher eventPublisher;
    private DeletionService deletionService;
    private RepositoryDefinitionManager repositoryDefinitionManager;

    public void setChainCreationService(ChainCreationService chainCreationService) {
        this.chainCreationService = chainCreationService;
    }

    public void setDashboardCachingManager(DashboardCachingManager dashboardCachingManager) {
        this.dashboardCachingManager = dashboardCachingManager;
    }

    public void setJobCreationService(JobCreationService jobCreationService) {
        this.jobCreationService = jobCreationService;
    }

    public void setCachedPlanManager(CachedPlanManager cachedPlanManager) {
        this.cachedPlanManager = cachedPlanManager;
    }

    public void setTaskManager(TaskManager taskManager) {
        this.taskManager = taskManager;
    }

    public void setTaskConfigurationService(TaskConfigurationService taskConfigurationService) {
        this.taskConfigurationService = taskConfigurationService;
    }

    public void setPlanManager(PlanManager planManager) {
        this.planManager = planManager;
    }

    public void setBuildDefinitionManager(BuildDefinitionManager buildDefinitionManager) {
        this.buildDefinitionManager = buildDefinitionManager;
    }

    public void setTriggerConfigurationService(TriggerConfigurationService triggerConfigurationService) {
        this.triggerConfigurationService = triggerConfigurationService;
    }

    public void setTriggerTypeManager(TriggerTypeManager triggerTypeManager) {
        this.triggerTypeManager = triggerTypeManager;
    }

    public void setEventPublisher(EventPublisher eventPublisher) {
        this.eventPublisher = eventPublisher;
    }

    public void setDeletionService(DeletionService deletionService) {
        this.deletionService = deletionService;
    }

    public void setRepositoryDefinitionManager(RepositoryDefinitionManager repositoryDefinitionManager) {
        this.repositoryDefinitionManager = repositoryDefinitionManager;
    }

    public BuildPlanResource() {
        // NOTE(alindeman): It's not clear why this doesn't work as a regular <component-import> but I could not get it to work
        setTaskManager(ComponentAccessor.TASK_MANAGER.get());
    }

    static class PlanRequest {
        public String key;
        public String name;
        public String description;
        public long defaultRepositoryId;

        public int removedBranchCleanupDays;
        public int inactiveBranchCleanupDays;
        public boolean automaticMergingEnabled;
        public boolean automaticBranchCreationEnabled;
    }

    static class PlanInformation {
        public String key;
        public String name;
        public String description;
        public long defaultRepositoryId;

        public int removedBranchCleanupDays;
        public int inactiveBranchCleanupDays;
        public boolean automaticMergingEnabled;
        public boolean automaticBranchCreationEnabled;

        public static PlanInformation newFromPlan(final ImmutablePlan plan, final BuildDefinition buildDefinition) {
            PlanInformation information = new PlanInformation();
            information.key = plan.getPlanKey().toString();
            information.name = plan.getBuildName();
            information.description = plan.getDescription();

            PlanRepositoryDefinition planRepositoryDefinition = PlanHelper.getDefaultPlanRepositoryDefinition(plan);
            if (planRepositoryDefinition != null) {
                // Linked repositories get unique IDs, but are linked to the parent. The parent is all we care about.
                if (planRepositoryDefinition.getParentId() != null) {
                    information.defaultRepositoryId = planRepositoryDefinition.getParentId();
                } else {
                    information.defaultRepositoryId = planRepositoryDefinition.getId();
                }
            }

            final BranchMonitoringConfiguration branchMonitoringConfiguration = buildDefinition.getBranchMonitoringConfiguration();
            // Branch monitoring configuration will be null for branch plans themselves.
            if (branchMonitoringConfiguration != null) {
                information.automaticBranchCreationEnabled = branchMonitoringConfiguration.isPlanBranchCreationEnabled();
                if (branchMonitoringConfiguration.isRemovedBranchCleanUpEnabled()) {
                    information.removedBranchCleanupDays = branchMonitoringConfiguration.getRemovedBranchCleanUpPeriodInDays();
                } else {
                    information.removedBranchCleanupDays = -1;
                }
                if (branchMonitoringConfiguration.isInactiveBranchCleanUpEnabled()) {
                    information.inactiveBranchCleanupDays = branchMonitoringConfiguration.getInactiveBranchCleanUpPeriodInDays();
                } else {
                    information.inactiveBranchCleanupDays = -1;
                }

                final BranchIntegrationConfiguration integrationConfiguration = branchMonitoringConfiguration.getDefaultBranchIntegrationConfiguration();
                information.automaticMergingEnabled = integrationConfiguration.isEnabled();
            } else {
                information.removedBranchCleanupDays = -1;
                information.inactiveBranchCleanupDays = -1;

                final BranchIntegrationConfiguration integrationConfiguration = buildDefinition.getBranchIntegrationConfiguration();
                information.automaticMergingEnabled = integrationConfiguration.isEnabled();
            }

            return information;
        }
    }

    @GET
    @Path("/{key}")
    public Response get(@PathParam("key") final String key) {
        final Plan plan = planManager.getPlanByKey(PlanKeys.getPlanKey(key));
        if (plan == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        BuildDefinition buildDefinition = buildDefinitionManager.getUnmergedBuildDefinition(plan.getPlanKey());
        PlanInformation information = PlanInformation.newFromPlan(plan, buildDefinition);
        return Response.ok(information).build();
    }

    @POST
    public Response create(final PlanRequest planRequest) {
        final PartialVcsRepositoryData parentVcsRepositoryData = repositoryDefinitionManager.getVcsRepositoryDataForEditing(planRequest.defaultRepositoryId);
        if (parentVcsRepositoryData == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        String planKey;
        try {
            planKey = createPlan(planRequest, parentVcsRepositoryData);
        } catch (PlanCreationDeniedException e) {
            log.error("permission denied while creating plan", e);
            return Response.status(Response.Status.FORBIDDEN).build();
        } catch (PlanCreationException e) {
            log.error("unable to create plan", e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        }

        String jobKey;
        try {
            jobKey = createDefaultJob(planKey);
        } catch (PlanCreationDeniedException e) {
            log.error("permission denied while creating job", e);
            return Response.status(Response.Status.FORBIDDEN).build();
        } catch (PlanCreationException e) {
            log.error("unable to create job", e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        }

        Plan plan = planManager.getPlanByKey(PlanKeys.getPlanKey(planKey));
        PlanRepositoryDefinition defaultRepositoryDefinition = PlanHelper.getDefaultPlanRepositoryDefinition(plan);

        createDefaultTask(planKey, jobKey);
        setupWebhookTrigger(planKey, defaultRepositoryDefinition);
        setupDailyPoll(planKey, defaultRepositoryDefinition);

        BuildDefinition buildDefinition = buildDefinitionManager.getUnmergedBuildDefinition(plan.getPlanKey());
        configureBranchManagement(buildDefinition, planRequest);
        buildDefinitionManager.savePlanAndDefinition(plan, buildDefinition);

        eventPublisher.publish(new BuildConfigurationUpdatedEvent(this, plan.getPlanKey()));
        dashboardCachingManager.updatePlanCache(PlanKeys.getPlanKey(planKey));

        PlanInformation information = PlanInformation.newFromPlan(plan, buildDefinition);
        return Response.ok(information)
                .status(Response.Status.CREATED)
                .build();
    }

    @PUT
    @Path("/{key}")
    public Response update(@PathParam("key") final String key, final PlanRequest planRequest) {
        final Plan plan = planManager.getPlanByKey(key);
        if (plan == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        final PartialVcsRepositoryData vcsRepositoryData = repositoryDefinitionManager.getVcsRepositoryDataForEditing(planRequest.defaultRepositoryId);
        if (vcsRepositoryData == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        plan.setBuildName(planRequest.name);
        plan.setDescription(planRequest.description);
        // TODO(alindeman): changing defaultRepositoryId is not implemented

        BuildDefinition buildDefinition = buildDefinitionManager.getUnmergedBuildDefinition(plan.getPlanKey());
        configureBranchManagement(buildDefinition, planRequest);
        buildDefinitionManager.savePlanAndDefinition(plan, buildDefinition);

        eventPublisher.publish(new BuildConfigurationUpdatedEvent(this, plan.getPlanKey()));
        dashboardCachingManager.updatePlanCache(PlanKeys.getPlanKey(key));

        PlanInformation information = PlanInformation.newFromPlan(plan, buildDefinition);
        return Response.ok(information).build();
    }

    @DELETE
    @Path("/{key}")
    public Response delete(@PathParam("key") final String key) {
        final Plan plan = planManager.getPlanByKey(PlanKeys.getPlanKey(key));
        if (plan == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        deletionService.deletePlan(plan);
        return Response.noContent().build();
    }

    private String createPlan(final PlanRequest planRequest, final PartialVcsRepositoryData vcsRepositoryData) throws PlanCreationDeniedException {
        HashMap<String,String> configuration = new HashMap<>();
        configuration.put("existingProjectKey", PlanKeys.getProjectKeyPart(PlanKeys.getPlanKey(planRequest.key)));
        configuration.put("chainName", planRequest.name);
        configuration.put("chainKey", PlanKeys.getPlanKeyPart(PlanKeys.getPlanKey(planRequest.key)));
        configuration.put("chainDescription", planRequest.description);
        configuration.put("selectedRepository", Long.toString(vcsRepositoryData.getId()));
        configuration.put("repositoryTypeOption", "LINKED");

        BuildConfiguration buildConfiguration = new BuildConfiguration();
        buildConfiguration.setProperty("selectedRepository", Long.toString(vcsRepositoryData.getId()));

        return chainCreationService.createPlan(
                buildConfiguration,
                new ActionParametersMapImpl(configuration),
                PlanCreationService.EnablePlan.ENABLED
        );
    }

    private String createDefaultJob(final String planKey) throws PlanCreationDeniedException {
        ActionParametersMap map = new ActionParametersMapImpl(new HashMap<>());
        JobParamMapHelper.setBuildKey(map, planKey);
        JobParamMapHelper.setBuildName(map, "Build and Test");
        JobParamMapHelper.setSubBuildKey(map, "TEST");
        JobParamMapHelper.setStageName(map, "Test Jobs");
        JobParamMapHelper.setExistingStage(map, JobCreationConstants.NEW_STAGE_MARKER);

        BuildConfiguration buildConfiguration = new BuildConfiguration();
        buildConfiguration.setProperty(BuildDefinitionConverter.INHERIT_REPOSITORY, "true");

        String jobKey = jobCreationService.createSingleJob(
                buildConfiguration,
                map,
                PlanCreationService.EnablePlan.ENABLED
        );

        jobCreationService.triggerCreationCompleteEvents(PlanKeys.getPlanKey(jobKey));
        return jobKey;
    }

    private TaskDefinition createDefaultTask(final String planKey, final String jobKey) {
        ImmutableJob job = cachedPlanManager.getPlanByKeyIfOfType(PlanKeys.getPlanKey(jobKey), ImmutableJob.class);
        TaskModuleDescriptor taskDescriptor = taskManager.getTaskDescriptor(scriptTaskKey);
        TaskRootDirectorySelector rootDirectorySelector = new TaskRootDirectorySelector();
        rootDirectorySelector.setTaskRootDirectoryType(TaskRootDirectoryType.INHERITED);
        rootDirectorySelector.setRepositoryDefiningWorkingDirectory(-1L);

        HashMap<String, String> configuration = new HashMap<>();
        configuration.put("scriptLocation", "INLINE");
        configuration.put("scriptBody", "#!/usr/bin/env bash\nset -euo pipefail\n\nexec script/cibuild");

        return taskConfigurationService.createTask(
                PlanKeys.getPlanKey(jobKey),
                taskDescriptor,
                "Run script/cibuild",
                true,
                configuration,
                rootDirectorySelector
        );
    }

    private TriggerDefinition setupWebhookTrigger(final String planKey, final PlanRepositoryDefinition repositoryDefinition) {
        TriggerModuleDescriptor triggerDescriptor = triggerTypeManager.getTriggerDescriptor(githubWebhookTriggerKey);

        HashSet<Long> triggeringRepositories = new HashSet<>();
        triggeringRepositories.add(repositoryDefinition.getId());

        HashMap<String, String> configuration = new HashMap<>();

        return triggerConfigurationService.createTrigger(
                PlanKeys.getPlanKey(planKey),
                triggerDescriptor,
                "",
                true,
                triggeringRepositories,
                configuration,
                new HashMap<>()
            );
    }

    private TriggerDefinition setupDailyPoll(final String planKey, final PlanRepositoryDefinition repositoryDefinition) {
        TriggerModuleDescriptor triggerDescriptor = triggerTypeManager.getTriggerDescriptor(pollTriggerKey);

        HashSet<Long> triggeringRepositories = new HashSet<>();
        triggeringRepositories.add(repositoryDefinition.getId());

        HashMap<String, String> configuration = new HashMap<>();
        configuration.put(PollingTriggerConfigurationConstants.POLLING_TYPE, "CRON");
        configuration.put(PollingTriggerConfigurationConstants.POLLING_PERIOD, "180");
        configuration.put(PollingTriggerConfigurationConstants.CRON_EXPRESSION, "0 0 0 ? * *");

        return triggerConfigurationService.createTrigger(
                PlanKeys.getPlanKey(planKey),
                triggerDescriptor,
                "detect deleted branches (do not remove)",
                true,
                triggeringRepositories,
                configuration,
                new HashMap<>()
        );
    }

    private void configureBranchManagement(final BuildDefinition buildDefinition, final PlanRequest request) {
        BranchMonitoringConfiguration branchMonitoringConfiguration = buildDefinition.getBranchMonitoringConfiguration();
        if (branchMonitoringConfiguration != null) {
            branchMonitoringConfiguration.setPlanBranchCreationEnabled(request.automaticBranchCreationEnabled);
            branchMonitoringConfiguration.setMatchingPattern(StringUtils.EMPTY);
            if (request.removedBranchCleanupDays >= 0) {
                branchMonitoringConfiguration.setRemovedBranchCleanUpEnabled(true);
                branchMonitoringConfiguration.setRemovedBranchCleanUpPeriodInDays(request.removedBranchCleanupDays);
            } else {
                branchMonitoringConfiguration.setRemovedBranchCleanUpEnabled(false);
            }
            if (request.inactiveBranchCleanupDays >= 0) {
                branchMonitoringConfiguration.setInactiveBranchCleanUpEnabled(true);
                branchMonitoringConfiguration.setInactiveBranchCleanUpPeriodInDays(request.inactiveBranchCleanupDays);
            } else {
                branchMonitoringConfiguration.setInactiveBranchCleanUpEnabled(false);
            }

            HierarchicalConfiguration integrationConfiguration = new HierarchicalConfiguration();
            if (request.automaticMergingEnabled) {
                integrationConfiguration.setProperty("branches.defaultBranchIntegration.enabled", "true");
                integrationConfiguration.setProperty("branches.defaultBranchIntegration.strategy", "BRANCH_UPDATER");
                integrationConfiguration.setProperty("branches.defaultBranchIntegration.branchUpdater.mergeFromBranch", request.key);
                integrationConfiguration.setProperty("branches.defaultBranchIntegration.branchUpdater.pushEnabled", "true");
            } else {
                integrationConfiguration.setProperty("branches.defaultBranchIntegration.enabled", "false");
            }
            branchMonitoringConfiguration.setDefaultBranchIntegrationConfiguration(
                    BuildDefinitionConverter.populate(
                            integrationConfiguration,
                            new BranchIntegrationConfigurationImpl(true)
                    )
            );
        } else {
            // This is a branch plan. Instead of having a 'default' configuration that will be copied to each branch
            // plan, we modify the configuration directly.
            HierarchicalConfiguration integrationConfiguration = new HierarchicalConfiguration();
            if (request.automaticMergingEnabled) {
                integrationConfiguration.setProperty("branchIntegration.enabled", "true");
                integrationConfiguration.setProperty("branchIntegration.strategy", "BRANCH_UPDATER");
                integrationConfiguration.setProperty("branchIntegration.branchUpdater.mergeFromBranch", request.key);
                integrationConfiguration.setProperty("branchIntegration.branchUpdater.pushEnabled", "true");
            } else {
                integrationConfiguration.setProperty("branchIntegration.enabled", "false");
            }
            buildDefinition.setBranchIntegrationConfiguration(
                    BuildDefinitionConverter.populate(
                            integrationConfiguration,
                            new BranchIntegrationConfigurationImpl(false)
                    )
            );
        }
    }
}
