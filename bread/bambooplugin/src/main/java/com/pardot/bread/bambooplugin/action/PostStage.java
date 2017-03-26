package com.pardot.bread.bambooplugin.action;

import com.atlassian.bamboo.chains.ChainExecution;
import com.atlassian.bamboo.chains.ChainResultsSummary;
import com.atlassian.bamboo.chains.ChainStageResult;
import com.atlassian.bamboo.chains.StageExecution;
import com.atlassian.bamboo.chains.plugins.PostStageAction;
import com.atlassian.bamboo.configuration.AdministrationConfigurationAccessor;
import com.atlassian.bamboo.plan.PlanHelper;
import com.atlassian.bamboo.plan.PlanKey;
import com.atlassian.bamboo.plan.PlanResultKey;
import com.atlassian.bamboo.plan.cache.CachedPlanManager;
import com.atlassian.bamboo.plan.cache.ImmutablePlan;
import com.atlassian.bamboo.plugins.git.GitHubRepository;
import com.atlassian.bamboo.repository.Repository;
import com.atlassian.bamboo.repository.RepositoryData;
import com.atlassian.bamboo.utils.BambooUrl;
import com.pardot.bread.bambooplugin.GithubStatusBuildConfiguration;
import com.pardot.bread.bambooplugin.GithubStatus;
import org.apache.log4j.Logger;
import org.jetbrains.annotations.NotNull;
import org.kohsuke.github.GHCommitState;

import java.io.IOException;

public class PostStage implements PostStageAction {
    private static Logger log = Logger.getLogger(PostStage.class);

    private AdministrationConfigurationAccessor administrationConfigurationAccessor;
    private CachedPlanManager cachedPlanManager;

    public void setAdministrationConfigurationAccessor(AdministrationConfigurationAccessor administrationConfigurationAccessor) {
        this.administrationConfigurationAccessor = administrationConfigurationAccessor;
    }

    public void setCachedPlanManager(CachedPlanManager cachedPlanManager) {
        this.cachedPlanManager = cachedPlanManager;
    }

    @Override
    public void execute(@NotNull ChainResultsSummary chainResultsSummary, @NotNull ChainStageResult chainStageResult, @NotNull StageExecution stageExecution) throws InterruptedException, Exception {
        if (stageExecution.isSuccessful()) {
            setGithubStatus(stageExecution, GHCommitState.SUCCESS);
        } else {
            setGithubStatus(stageExecution, GHCommitState.FAILURE);
        }
    }

    private void setGithubStatus(final StageExecution stageExecution, final GHCommitState state) {
        final ChainExecution chainExecution = stageExecution.getChainExecution();
        final PlanResultKey planResultKey = chainExecution.getPlanResultKey();
        final PlanKey planKey = planResultKey.getPlanKey();
        final ImmutablePlan plan = cachedPlanManager.getPlanByKey(planKey);

        if (plan == null) {
            return;
        }

        if (!GithubStatusBuildConfiguration.isGithubStatusEnabled(plan.getBuildDefinition().getCustomConfiguration())) {
            return;
        }

        final RepositoryData defaultRepositoryData = PlanHelper.getDefaultRepositoryDefinition(plan);
        if (defaultRepositoryData == null) {
            return;
        }

        final Repository defaultRepository = defaultRepositoryData.getRepository();
        if (defaultRepository instanceof GitHubRepository) {
            final GitHubRepository gitHubRepository = (GitHubRepository) defaultRepository;
            final String sha = chainExecution.getBuildChanges().getVcsRevisionKey(defaultRepositoryData.getId());
            final String url = new BambooUrl(administrationConfigurationAccessor).withBaseUrlFromConfiguration("/browse/" + planResultKey.toString());

            try {
                log.info("Setting GitHub commit status for '" + planKey + "'/'" + stageExecution.getName() + "' to " + state);
                GithubStatus.create(
                        gitHubRepository,
                        sha,
                        state,
                        url,
                        stageExecution.getName()
                );
            } catch (IOException e) {
                log.error("Unable to set GitHub commit status: " + e);
            }
        }
    }
}
