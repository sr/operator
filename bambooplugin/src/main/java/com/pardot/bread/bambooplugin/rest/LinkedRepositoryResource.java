package com.pardot.bread.bambooplugin.rest;

import com.atlassian.bamboo.repository.RepositoryConfigurationService;
import com.atlassian.bamboo.repository.RepositoryData;
import com.atlassian.bamboo.repository.RepositoryDefinitionManager;
import com.atlassian.bamboo.security.EncryptionService;
import com.atlassian.bamboo.user.BambooAuthenticationContext;
import com.atlassian.bamboo.utils.ConfigUtils;
import com.pardot.bread.bambooplugin.repository.GithubEnterpriseRepository;
import org.apache.commons.configuration.HierarchicalConfiguration;
import org.apache.log4j.Logger;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.RequestBody;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

@Path("/linkedrepos/{name}")
@Component
public class LinkedRepositoryResource {
    private static final Logger log = Logger.getLogger(LinkedRepositoryResource.class);

    private static final String githubEnterpriseRepositoryKey = "com.pardot.bread.bambooplugin.pardot-bamboo-plugin:github-enterprise-repository";

    // The webRepositoryKey indicating no web repository reviewer.
    private static final String noWebRepositoryKey = "bamboo.webrepositoryviewer.provided:noRepositoryViewer";

    private BambooAuthenticationContext authenticationContext;
    private RepositoryConfigurationService repositoryConfigurationService;
    private RepositoryDefinitionManager repositoryDefinitionManager;
    private EncryptionService encryptionService;

    public void setAuthenticationContext(final BambooAuthenticationContext authenticationContext) {
        this.authenticationContext = authenticationContext;
    }

    public void setRepositoryConfigurationService(RepositoryConfigurationService repositoryConfigurationService) {
        this.repositoryConfigurationService = repositoryConfigurationService;
    }

    public void setRepositoryDefinitionManager(RepositoryDefinitionManager repositoryDefinitionManager) {
        this.repositoryDefinitionManager = repositoryDefinitionManager;
    }

    public void setEncryptionService(EncryptionService encryptionService) {
        this.encryptionService = encryptionService;
    }

    static class RepositoryConfiguration {
        private String username;
        private String password;
        private String branch;
        private String repository;

        public String getUsername() {
            return username;
        }

        public void setUsername(String username) {
            this.username = username;
        }

        public String getPassword() {
            return password;
        }

        public void setPassword(String password) {
            this.password = password;
        }

        public String getBranch() {
            return branch;
        }

        public void setBranch(String branch) {
            this.branch = branch;
        }

        public String getRepository() {
            return repository;
        }

        public void setRepository(String repository) {
            this.repository = repository;
        }
    }

    @GET
    public Response get(@PathParam("name") final String name) {
        if (findGlobalRepositoryWithName(name) != null) {
            return Response.status(Response.Status.OK).build();
        }
        return Response.status(Response.Status.NOT_FOUND).build();
    }

    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    public Response create(@PathParam("name") final String name,
                           @RequestBody final RepositoryConfiguration body) {
        if (findGlobalRepositoryWithName(name) != null) {
            return Response.status(Response.Status.CONFLICT).build();
        }

        HierarchicalConfiguration configuration = ConfigUtils.newConfiguration();
        configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_HOSTNAME, GithubEnterpriseRepository.getDefaultHostname());
        configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_USERNAME, body.getUsername());
        configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_PASSWORD, encryptionService.encrypt(body.getPassword()));
        configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_REPOSITORY, body.getRepository());
        configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_BRANCH, body.getBranch());
        configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_USE_SHALLOW_CLONES, true);
        configuration.setProperty("repository.github.useShallowClones", true);
        configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_USE_REMOTE_AGENT_CACHE, false);
        configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_USE_SUBMODULES, false);
        configuration.setProperty("repository.github.useSubmodules", false);
        configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_VERBOSE_LOGS, false);
        configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_FETCH_WHOLE_REPOSITORY, false);
        configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_COMMAND_TIMEOUT, String.valueOf(GithubEnterpriseRepository.DEFAULT_COMMAND_TIMEOUT_IN_MINUTES));

        repositoryConfigurationService.createGlobalRepository(
                name,
                githubEnterpriseRepositoryKey,
                noWebRepositoryKey,
                configuration,
                true,
                authenticationContext.getUser()
        );

        return Response.status(Response.Status.CREATED).build();
    }

   private RepositoryData findGlobalRepositoryWithName(String name) {
       for (RepositoryData repositoryData : repositoryDefinitionManager.getGlobalRepositoryDefinitionsForAdministration()) {
           log.info("Looking at " + repositoryData.getName());
           if (repositoryData.getName().equals(name)) {
               return repositoryData;
           }
       }
       return null;
   }

}
