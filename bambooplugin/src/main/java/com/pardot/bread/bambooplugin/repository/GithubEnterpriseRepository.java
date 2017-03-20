package com.pardot.bread.bambooplugin.repository;

import com.atlassian.bamboo.crypto.instance.SecretEncryptionService;
import com.atlassian.bamboo.plan.branch.VcsBranchImpl;
import com.atlassian.bamboo.plugins.git.GitAuthenticationType;
import com.atlassian.bamboo.plugins.git.GitHubRepository;
import com.atlassian.bamboo.plugins.git.GitHubRepositoryAccessData;
import com.atlassian.bamboo.plugins.git.GitRepositoryAccessData;
import com.atlassian.bamboo.repository.Repository;
import com.atlassian.bamboo.security.EncryptionException;
import com.atlassian.bamboo.security.MigratingEncryptionService;
import com.atlassian.bamboo.spring.ComponentAccessor;
import com.atlassian.bamboo.utils.SystemProperty;
import com.atlassian.bamboo.utils.error.ErrorCollection;
import com.atlassian.bamboo.utils.error.SimpleErrorCollection;
import com.atlassian.bamboo.ww2.actions.build.admin.create.BuildConfiguration;
import com.atlassian.sal.api.message.I18nResolver;
import org.apache.commons.configuration.HierarchicalConfiguration;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.eclipse.jgit.lib.Constants;
import org.jetbrains.annotations.NotNull;

import java.net.MalformedURLException;
import java.net.URL;

public class GithubEnterpriseRepository extends GitHubRepository {
    private static final Logger log = Logger.getLogger(GithubEnterpriseRepository.class);

    public static final int DEFAULT_COMMAND_TIMEOUT_IN_MINUTES = 180;

    public static final String REPOSITORY_GITHUBENTERPRISE_HOSTNAME = "repository.githubenterprise.hostname";
    public static final String REPOSITORY_GITHUBENTERPRISE_USERNAME = "repository.githubenterprise.username";
    public static final String REPOSITORY_GITHUBENTERPRISE_PASSWORD = "repository.githubenterprise.password";
    public static final String REPOSITORY_GITHUBENTERPRISE_REPOSITORY = "repository.githubenterprise.repository";
    public static final String REPOSITORY_GITHUBENTERPRISE_BRANCH = "repository.githubenterprise.branch";
    public static final String REPOSITORY_GITHUBENTERPRISE_USE_SHALLOW_CLONES = "repository.githubenterprise.useShallowClones";
    public static final String REPOSITORY_GITHUBENTERPRISE_USE_SUBMODULES = "repository.githubenterprise.useSubmodules";
    public static final String REPOSITORY_GITHUBENTERPRISE_USE_REMOTE_AGENT_CACHE = "repository.githubenterprise.useRemoteAgentCache";
    public static final String REPOSITORY_GITHUBENTERPRISE_COMMAND_TIMEOUT = "repository.githubenterprise.commandTimeout";
    public static final String REPOSITORY_GITHUBENTERPRISE_VERBOSE_LOGS = "repository.githubenterprise.verbose.logs";
    public static final String REPOSITORY_GITHUBENTERPRISE_FETCH_WHOLE_REPOSITORY = "repository.githubenterprise.fetch.whole.repository";
    public static final String REPOSITORY_GITHUBENTERPRISE_LFS_REPOSITORY = "repository.githubenterprise.lfs";

    private static final String REPOSITORY_GITHUBENTERPRISE_TEMPORARY_PASSWORD = "repository.githubenterprise.temporary.password";
    private static final String TEMPORARY_GITHUBENTERPRISE_PASSWORD_CHANGE = "temporary.githubenterprise.password.change";

    private static final String REPOSITORY_GITHUBENTERPRISE_ERROR_MISSING_HOSTNAME = "repository.githubenterprise.error.missingHostname";
    private static final String REPOSITORY_GITHUBENTERPRISE_ERROR_MISSING_REPOSITORY = "repository.githubenterprise.error.missingRepository";

    public static final String GITHUB_API_BASE_URL = new SystemProperty(false, "atlassian.bamboo.github.api.base.url",
            "ATLASSIAN_BAMBOO_GITHUB_API_BASE_URL").getValue("https://api.github.com/");

    // The only difference between a GitHubRepository and a GitHubEnterpriseRepository is the ability to specify
    // hostname. As such, we maintain the host field, delegating most everything else to GitHubRepository.
    private String hostname;

    private I18nResolver i18nResolver;
    private MigratingEncryptionService migratingEncryptionService;

    @Override
    public void setI18nResolver(I18nResolver i18nResolver) {
        super.setI18nResolver(i18nResolver);
        this.i18nResolver = i18nResolver;
    }

    @NotNull
    @Override
    public String getName() {
        return "GitHub Enterprise";
    }

    @Override
    public boolean isRepositoryDifferent(@NotNull Repository repository) {
        if (!(repository instanceof GithubEnterpriseRepository) || super.isRepositoryDifferent(repository)) {
            return true;
        } else {
            GithubEnterpriseRepository gheRepository = (GithubEnterpriseRepository) repository;
            return !StringUtils.equals(getHostname(), gheRepository.getHostname());
        }
    }

    // host is not the same as hostname. We must return null here for legacy reasons.
    @Override
    public String getHost() {
        return null;
    }

    public String getHostname() {
        return hostname;
    }

    public static String getDefaultHostname() {
        try {
            URL apiBaseUrl = new URL(GITHUB_API_BASE_URL);
            return apiBaseUrl.getHost();
        } catch (MalformedURLException e) {
            return "";
        }
    }

    @Override
    public void addDefaultValues(@NotNull BuildConfiguration buildConfiguration)
    {
        buildConfiguration.setProperty(REPOSITORY_GITHUBENTERPRISE_HOSTNAME, getDefaultHostname());
        buildConfiguration.setProperty(REPOSITORY_GITHUBENTERPRISE_COMMAND_TIMEOUT, String.valueOf(DEFAULT_COMMAND_TIMEOUT_IN_MINUTES));
        buildConfiguration.clearTree(REPOSITORY_GITHUBENTERPRISE_VERBOSE_LOGS);
        buildConfiguration.clearTree(REPOSITORY_GITHUBENTERPRISE_FETCH_WHOLE_REPOSITORY);
        buildConfiguration.clearTree(REPOSITORY_GITHUBENTERPRISE_LFS_REPOSITORY);
        buildConfiguration.setProperty(REPOSITORY_GITHUBENTERPRISE_USE_SHALLOW_CLONES, true);
        buildConfiguration.setProperty(REPOSITORY_GITHUBENTERPRISE_USE_REMOTE_AGENT_CACHE, false);
        buildConfiguration.clearTree(REPOSITORY_GITHUBENTERPRISE_USE_SUBMODULES);
    }

    @Override
    public void prepareConfigObject(@NotNull BuildConfiguration buildConfiguration)
    {
        buildConfiguration.setProperty(REPOSITORY_GITHUBENTERPRISE_HOSTNAME, buildConfiguration.getString(REPOSITORY_GITHUBENTERPRISE_HOSTNAME, "").trim());
        buildConfiguration.setProperty(REPOSITORY_GITHUBENTERPRISE_USERNAME, buildConfiguration.getString(REPOSITORY_GITHUBENTERPRISE_USERNAME, "").trim());
        if (buildConfiguration.getBoolean(TEMPORARY_GITHUBENTERPRISE_PASSWORD_CHANGE)) {
            buildConfiguration.setProperty(REPOSITORY_GITHUBENTERPRISE_PASSWORD, getMigratingEncryptionService().encrypt(buildConfiguration.getString(REPOSITORY_GITHUBENTERPRISE_TEMPORARY_PASSWORD)));
        }
        buildConfiguration.setProperty(REPOSITORY_GITHUBENTERPRISE_REPOSITORY, buildConfiguration.getString(REPOSITORY_GITHUBENTERPRISE_REPOSITORY, "").trim());
        buildConfiguration.setProperty(REPOSITORY_GITHUBENTERPRISE_BRANCH, buildConfiguration.getString(REPOSITORY_GITHUBENTERPRISE_BRANCH, "").trim());
    }

    @Override
    public void populateFromConfig(@NotNull HierarchicalConfiguration config)
    {
        super.populateFromConfig(config);

        this.hostname = config.getString(REPOSITORY_GITHUBENTERPRISE_HOSTNAME);
        final GitHubRepositoryAccessData accessData = GitHubRepositoryAccessData.builder(getAccessData())
                .repository(config.getString(REPOSITORY_GITHUBENTERPRISE_REPOSITORY))
                .username(config.getString(REPOSITORY_GITHUBENTERPRISE_USERNAME))
                .password(decryptPassword(config.getString(REPOSITORY_GITHUBENTERPRISE_PASSWORD)))
                .branch(new VcsBranchImpl(config.getString(REPOSITORY_GITHUBENTERPRISE_BRANCH)))
                .useShallowClones(config.getBoolean(REPOSITORY_GITHUBENTERPRISE_USE_SHALLOW_CLONES))
                .useRemoteAgentCache(config.getBoolean(REPOSITORY_GITHUBENTERPRISE_USE_REMOTE_AGENT_CACHE, false))
                .useSubmodules(config.getBoolean(REPOSITORY_GITHUBENTERPRISE_USE_SUBMODULES))
                .commandTimeout(config.getInt(REPOSITORY_GITHUBENTERPRISE_COMMAND_TIMEOUT, DEFAULT_COMMAND_TIMEOUT_IN_MINUTES))
                .verboseLogs(config.getBoolean(REPOSITORY_GITHUBENTERPRISE_VERBOSE_LOGS, false))
                .refSpecOverride(config.getBoolean(REPOSITORY_GITHUBENTERPRISE_FETCH_WHOLE_REPOSITORY, false) ? Constants.R_HEADS + "*" : null)
                .lfs(config.getBoolean(REPOSITORY_GITHUBENTERPRISE_LFS_REPOSITORY, false))
                .build();

        setAccessData(accessData);
    }

    @NotNull
    @Override
    public HierarchicalConfiguration toConfiguration()
    {
        HierarchicalConfiguration configuration = super.toConfiguration();
        configuration.setProperty(REPOSITORY_GITHUBENTERPRISE_HOSTNAME, getHostname());
        configuration.setProperty(REPOSITORY_GITHUBENTERPRISE_USERNAME, getUsername());
        configuration.setProperty(REPOSITORY_GITHUBENTERPRISE_PASSWORD, getMigratingEncryptionService().encrypt(getPassword()));
        configuration.setProperty(REPOSITORY_GITHUBENTERPRISE_REPOSITORY, getRepository());
        configuration.setProperty(REPOSITORY_GITHUBENTERPRISE_BRANCH, getBranch());
        configuration.setProperty(REPOSITORY_GITHUBENTERPRISE_USE_SHALLOW_CLONES, isUseShallowClones());
        configuration.setProperty(REPOSITORY_GITHUBENTERPRISE_USE_REMOTE_AGENT_CACHE, isUseRemoteAgentCache());
        configuration.setProperty(REPOSITORY_GITHUBENTERPRISE_USE_SUBMODULES, isUseSubmodules());
        configuration.setProperty(REPOSITORY_GITHUBENTERPRISE_COMMAND_TIMEOUT, getCommandTimeout());
        configuration.setProperty(REPOSITORY_GITHUBENTERPRISE_VERBOSE_LOGS, getVerboseLogs());
        configuration.setProperty(REPOSITORY_GITHUBENTERPRISE_FETCH_WHOLE_REPOSITORY, getAccessData().getRefSpecOverride() != null);
        configuration.setProperty(REPOSITORY_GITHUBENTERPRISE_LFS_REPOSITORY, getAccessData().isLfs());

        return configuration;
    }

    @Override
    @NotNull
    public ErrorCollection validate(@NotNull BuildConfiguration buildConfiguration)
    {
        // HACK: We need to ignore GitHubRepository validations because we changed all the fields names. We changed all
        // the field names because otherwise the form submission would send duplicate values.
        ErrorCollection errorCollection = new SimpleErrorCollection();
        if (StringUtils.isBlank(buildConfiguration.getString(REPOSITORY_GITHUBENTERPRISE_REPOSITORY))) {
            errorCollection.addError(REPOSITORY_GITHUBENTERPRISE_REPOSITORY, i18nResolver.getText(REPOSITORY_GITHUBENTERPRISE_ERROR_MISSING_REPOSITORY));
        }
        if (StringUtils.isBlank(buildConfiguration.getString(REPOSITORY_GITHUBENTERPRISE_HOSTNAME))) {
            errorCollection.addError(REPOSITORY_GITHUBENTERPRISE_HOSTNAME, i18nResolver.getText(REPOSITORY_GITHUBENTERPRISE_ERROR_MISSING_HOSTNAME));
        }

        return errorCollection;
    }

    @Override
    public void setAccessData(GitHubRepositoryAccessData gitHubAccessData)
    {
        super.setAccessData(gitHubAccessData);

        getGitRepository().setAccessData(GitRepositoryAccessData.builder(getGitRepository().getAccessData())
                .repositoryUrl("https://" + this.hostname + "/" + gitHubAccessData.getRepository() + ".git")
                .username(gitHubAccessData.getUsername())
                .password(gitHubAccessData.getPassword())
                .branch(gitHubAccessData.getVcsBranch())
                .sshKey(null)
                .sshPassphrase(null)
                .authenticationType(GitAuthenticationType.PASSWORD)
                .useShallowClones(gitHubAccessData.isUseShallowClones())
                .useSubmodules(gitHubAccessData.isUseSubmodules())
                .useRemoteAgentCache(gitHubAccessData.isUseRemoteAgentCache())
                .commandTimeout(gitHubAccessData.getCommandTimeout())
                .verboseLogs(gitHubAccessData.isVerboseLogs())
                .lfs(gitHubAccessData.isLfs())
                .refSpecOverride(gitHubAccessData.getRefSpecOverride())
                .build());
    }

    private String decryptPassword(final String possiblyEncryptedPassword) {
        try {
            return getMigratingEncryptionService().decrypt(possiblyEncryptedPassword);
        } catch (EncryptionException e) {
            return possiblyEncryptedPassword;
        }
    }

    public MigratingEncryptionService getMigratingEncryptionService() {
        if (migratingEncryptionService == null) {
            migratingEncryptionService = new MigratingEncryptionService(ComponentAccessor.SECRET_ENCRYPTION_SERVICE.get());
        }

        return migratingEncryptionService;
    }
}
