package com.pardot.bread.bambooplugin;

import com.atlassian.bamboo.plan.PlanHelper;
import com.atlassian.bamboo.plan.cache.ImmutableChain;
import com.atlassian.bamboo.plan.cache.ImmutableTopLevelPlan;
import com.atlassian.bamboo.plugins.git.GitRepository;
import com.atlassian.bamboo.plugins.git.GitRepositoryFacade;
import com.atlassian.bamboo.repository.Repository;
import com.atlassian.bamboo.repository.RepositoryDefinition;
import com.google.common.collect.Iterables;
import com.pardot.bread.bambooplugin.trigger.GithubWebhookTriggerConfigurator;
import org.apache.log4j.Logger;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class GithubTriggeredPlan {
    private static final Logger log = Logger.getLogger(GithubTriggeredPlan.class);

    public static boolean hasActiveGitHubTrigger(final ImmutableTopLevelPlan plan) {
        return Iterables.any(
                plan.getTriggerDefinitions(),
                GithubWebhookTriggerConfigurator.IS_ACTIVE_GITHUB_WEBHOOK_TRIGGER
        );
    }

    public static boolean defaultRepositoryMatchesFullName(final ImmutableChain plan, final String repositoryFullName) {
        final GitRepository gitRepository = getDefaultGitRepositoryOrNull(plan);
        if (gitRepository != null) {
            return repositoryUrlMatchesRepositoryFullName(gitRepository.getRepositoryUrl(), repositoryFullName);
        }

        return false;
    }

    public static boolean defaultRepositoryMatchesBranchName(final ImmutableChain plan, final String branchName) {
        final GitRepository gitRepository = getDefaultGitRepositoryOrNull(plan);
        if (gitRepository != null) {
            return gitRepository.getVcsBranch().getName().equals(branchName);
        }

        return false;
    }

    private static GitRepository getDefaultGitRepositoryOrNull(final ImmutableChain plan) {
        final RepositoryDefinition defaultRepositoryDefinition = PlanHelper.getDefaultRepositoryDefinition(plan);
        if (defaultRepositoryDefinition != null) {
            final Repository repository = defaultRepositoryDefinition.getRepository();
            if (repository instanceof GitRepositoryFacade) {
                return ((GitRepositoryFacade) repository).getGitRepository();
            }
        }

        return null;
    }

    private static boolean repositoryUrlMatchesRepositoryFullName(final String repositoryUrl, final String repositoryFullName) {
        if (repositoryUrl == null || repositoryFullName == null) {
            return false;
        }

        // Notably, we don't check hostname because we have a situation where the hostname of GitHub for most use
        // cases is one string, but the hostname of GitHub for Bamboo is different because it connects over a
        // different (internal) network. This is OK because in the worst case, we would trigger a change event
        // when one is not needed, which is, as far as I can tell, harmless other than a small amount of wasted
        // CPU and network cycles.
        final Pattern p = Pattern.compile(".*[:/]" + Pattern.quote(repositoryFullName) + "(\\.git)?",
                Pattern.CASE_INSENSITIVE);

        Matcher m = p.matcher(repositoryUrl);
        return m.matches();
    }
}
