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
import com.atlassian.bamboo.webwork.util.ActionParametersMapImpl;
import com.atlassian.bamboo.ww2.actions.build.admin.create.BuildConfiguration;
import com.atlassian.event.api.EventPublisher;
import com.pardot.bread.bambooplugin.trigger.GithubWebhookTriggerConfigurator;
import org.apache.commons.configuration.HierarchicalConfiguration;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.springframework.stereotype.Component;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.HashMap;
import java.util.HashSet;

@Path("/buildplans")
@Component
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
    }

    static class PlanInformation {
        public String key;
        public String name;
        public String description;
        public long defaultRepositoryId;

        public static PlanInformation newFromPlan(ImmutablePlan plan) {
            PlanInformation information = new PlanInformation();
            information.key = plan.getPlanKey().toString();
            information.name = plan.getBuildName();
            information.description = plan.getDescription();

            RepositoryDefinition repositoryDefinition = PlanHelper.getDefaultRepositoryDefinition(plan);
            if (repositoryDefinition != null) {
                information.defaultRepositoryId = repositoryDefinition.getId();
            }

            return information;
        }
    }

    @GET
    @Path("/{key}")
    public Response get(@PathParam("key") final String key) {
        final ImmutablePlan plan = cachedPlanManager.getPlanByKey(PlanKeys.getPlanKey(key));
        if (plan == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        PlanInformation information = PlanInformation.newFromPlan(plan);
        return Response.ok(information).build();
    }

    @POST
    public Response create(final PlanRequest planRequest) {
        final RepositoryDataEntity repositoryDataEntity = repositoryDefinitionManager.getRepositoryDataEntity(planRequest.defaultRepositoryId);
        if (repositoryDataEntity == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        final RepositoryData repositoryData = new RepositoryDataImpl(repositoryDataEntity);

        String planKey;
        try {
            planKey = createPlan(planRequest, repositoryData);
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

        createDefaultTask(planKey, jobKey);
        setupWebhookTrigger(planKey);
        setupDailyPoll(planKey, repositoryData);
        configureBranchManagement(planKey);
        dashboardCachingManager.updatePlanCache(PlanKeys.getPlanKey(planKey));

        Plan plan = planManager.getPlanByKey(PlanKeys.getPlanKey(planKey));
        PlanInformation information = PlanInformation.newFromPlan(plan);
        return Response.ok(information)
                .status(Response.Status.CREATED)
                .build();
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

    private String createPlan(final PlanRequest planRequest, final RepositoryData repositoryData) throws PlanCreationDeniedException {
        HashMap<String,String> configuration = new HashMap<>();
        configuration.put("existingProjectKey", PlanKeys.getProjectKeyPart(PlanKeys.getPlanKey(planRequest.key)));
        configuration.put("chainName", planRequest.name);
        configuration.put("chainKey", PlanKeys.getPlanKeyPart(PlanKeys.getPlanKey(planRequest.key)));
        configuration.put("chainDescription", planRequest.description);
        configuration.put("selectedRepository", Long.toString(repositoryData.getId()));
        configuration.put("repositoryTypeOption", "LINKED");

        BuildConfiguration buildConfiguration = new BuildConfiguration();
        buildConfiguration.setProperty("selectedRepository", Long.toString(repositoryData.getId()));

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

    private TriggerDefinition setupWebhookTrigger(final String planKey) {
        TriggerModuleDescriptor triggerDescriptor = triggerTypeManager.getTriggerDescriptor(githubWebhookTriggerKey);

        HashMap<String, String> configuration = new HashMap<>();

        return triggerConfigurationService.createTrigger(
                PlanKeys.getPlanKey(planKey),
                triggerDescriptor,
                "",
                true,
                null,
                configuration,
                new HashMap<>()
            );
    }

    private TriggerDefinition setupDailyPoll(final String planKey, final RepositoryData repositoryData) {
        TriggerModuleDescriptor triggerDescriptor = triggerTypeManager.getTriggerDescriptor(pollTriggerKey);

        HashSet<Long> triggeringRepositories = new HashSet<>();
        triggeringRepositories.add(repositoryData.getId());

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

    private void configureBranchManagement(final String planKey) {
        Plan plan = planManager.getPlanByKey(PlanKeys.getPlanKey(planKey));
        BuildDefinition buildDefinition = buildDefinitionManager.getBuildDefinition(plan.getPlanKey());

        BranchMonitoringConfiguration branchMonitoringConfiguration = buildDefinition.getBranchMonitoringConfiguration();
        branchMonitoringConfiguration.setPlanBranchCreationEnabled(true);
        branchMonitoringConfiguration.setMatchingPattern(StringUtils.EMPTY);
        branchMonitoringConfiguration.setRemovedBranchCleanUpEnabled(true);
        branchMonitoringConfiguration.setRemovedBranchCleanUpPeriodInDays(BranchMonitoringConfiguration.REMOVED_BRANCH_DAILY_CLEAN_UP_PERIOD);
        branchMonitoringConfiguration.setInactiveBranchCleanUpEnabled(true);
        branchMonitoringConfiguration.setInactiveBranchCleanUpPeriodInDays(30);

        HierarchicalConfiguration integrationConfiguration = new HierarchicalConfiguration();
        integrationConfiguration.setProperty("branches.defaultBranchIntegration.enabled", "true");
        integrationConfiguration.setProperty("branches.defaultBranchIntegration.strategy", "BRANCH_UPDATER");
        integrationConfiguration.setProperty("branches.defaultBranchIntegration.branchUpdater.mergeFromBranch", planKey);
        integrationConfiguration.setProperty("branches.defaultBranchIntegration.branchUpdater.pushEnabled", "true");
        branchMonitoringConfiguration.setDefaultBranchIntegrationConfiguration(
                BuildDefinitionConverter.populate(
                        integrationConfiguration,
                        new BranchIntegrationConfigurationImpl(true)
                )
        );

        buildDefinitionManager.savePlanAndDefinition(plan, buildDefinition);
        eventPublisher.publish(new BuildConfigurationUpdatedEvent(this, plan.getPlanKey()));
    }
}
