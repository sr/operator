package com.pardot.bread.bambooplugin.rest;

import com.atlassian.bamboo.repository.RepositoryConfigurationService;
import com.atlassian.bamboo.repository.RepositoryData;
import com.atlassian.bamboo.repository.RepositoryDefinitionManager;
import com.atlassian.bamboo.security.EncryptionService;
import com.atlassian.bamboo.user.BambooAuthenticationContext;
import com.atlassian.bamboo.utils.ConfigUtils;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.pardot.bread.bambooplugin.repository.GithubEnterpriseRepository;
import org.apache.commons.configuration.HierarchicalConfiguration;
import org.apache.log4j.Logger;
import org.springframework.stereotype.Component;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

@Path("/linkedrepos")
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
        public String name;
        public String username;
        public String password;
        public String branch;
        public String repository;
    }

    static class RepositoryInformation {
        public String name;
        public long id;
    }

    @GET
    @Path("/{name}")
    @Produces(MediaType.APPLICATION_JSON)
    public Response get(@PathParam("name") final String name) {
        RepositoryData data = findGlobalRepositoryWithName(name);
        if (data == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        RepositoryInformation information = new RepositoryInformation();
        information.name = name;
        information.id = data.getId();
        return Response.ok(information).build();
    }

    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    public Response create(final Object body) {
        final RepositoryConfiguration repositoryConfiguration = new ObjectMapper()
                .convertValue(body, RepositoryConfiguration.class);

        if (findGlobalRepositoryWithName(repositoryConfiguration.name) != null) {
            return Response.status(Response.Status.CONFLICT).build();
        }

        HierarchicalConfiguration configuration = ConfigUtils.newConfiguration();
        configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_HOSTNAME, GithubEnterpriseRepository.getDefaultHostname());
        configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_USERNAME, repositoryConfiguration.username);
        configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_PASSWORD, encryptionService.encrypt(repositoryConfiguration.password));
        configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_REPOSITORY, repositoryConfiguration.repository);
        configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_BRANCH, repositoryConfiguration.branch);
        configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_USE_SHALLOW_CLONES, true);
        configuration.setProperty("repository.github.useShallowClones", true);
        configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_USE_REMOTE_AGENT_CACHE, false);
        configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_USE_SUBMODULES, false);
        configuration.setProperty("repository.github.useSubmodules", false);
        configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_VERBOSE_LOGS, false);
        configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_FETCH_WHOLE_REPOSITORY, false);
        configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_COMMAND_TIMEOUT, String.valueOf(GithubEnterpriseRepository.DEFAULT_COMMAND_TIMEOUT_IN_MINUTES));

        repositoryConfigurationService.createGlobalRepository(
                repositoryConfiguration.name,
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
