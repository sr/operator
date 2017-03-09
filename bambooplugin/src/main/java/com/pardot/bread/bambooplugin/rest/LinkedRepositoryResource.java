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

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

@Path("/linkedrepos")
@Component
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
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

    static class RepositoryRequest {
        public String name;
        public String username;
        public String password;
        public String branch;
        public String repository;
        public boolean shallowClones;
    }

    static class RepositoryResponse {
        public long id;
        public String name;
        public String branch;
        public String repository;
        public boolean shallowClones;

        public static RepositoryResponse newFromRepositoryData(final RepositoryData data) {
            RepositoryResponse information = new RepositoryResponse();
            information.id = data.getId();
            information.name = data.getName();
            information.branch = data.getConfiguration().getString(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_BRANCH, null);
            information.repository = data.getConfiguration().getString(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_REPOSITORY, null);
            information.shallowClones = data.getConfiguration().getBoolean(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_USE_SHALLOW_CLONES, false);
            return information;
        }
    }


    @GET
    @Path("/{name}")
    public Response get(@PathParam("name") final String name) {
        RepositoryData data = findGlobalRepositoryWithName(name);
        if (data == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        RepositoryResponse information = RepositoryResponse.newFromRepositoryData(data);
        return Response.ok(information).build();
    }

    @DELETE
    @Path("/{name}")
    public Response delete(@PathParam("name") final String name) {
        RepositoryData data = findGlobalRepositoryWithName(name);
        if (data == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        repositoryConfigurationService.deleteGlobalRepository(data.getId());
        return Response.noContent().build();
    }

    @POST
    public Response create(final RepositoryRequest repositoryRequest) {
        if (findGlobalRepositoryWithName(repositoryRequest.name) != null) {
            return Response.status(Response.Status.CONFLICT).build();
        }

        RepositoryData data = repositoryConfigurationService.createGlobalRepository(
                repositoryRequest.name,
                githubEnterpriseRepositoryKey,
                noWebRepositoryKey,
                buildConfiguration(repositoryRequest),
                true,
                authenticationContext.getUser()
        );

        RepositoryResponse information = RepositoryResponse.newFromRepositoryData(data);
        return Response.ok(information)
                .status(Response.Status.CREATED)
                .build();
    }

    @PUT
    @Path("/{name}")
    public Response update(@PathParam("name") final String name, final RepositoryRequest repositoryRequest) {
        RepositoryData data = findGlobalRepositoryWithName(name);
        if (data == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        data = repositoryConfigurationService.editGlobalRepository(
                name,
                githubEnterpriseRepositoryKey,
                noWebRepositoryKey,
                data,
                buildConfiguration(repositoryRequest)
        );

        RepositoryResponse information = RepositoryResponse.newFromRepositoryData(data);
        return Response.ok(information)
                .build();
    }

   private RepositoryData findGlobalRepositoryWithName(String name) {
       for (RepositoryData repositoryData : repositoryDefinitionManager.getGlobalRepositoryDefinitionsForAdministration()) {
           if (name.equals(repositoryData.getName())) {
               return repositoryData;
           }
       }
       return null;
   }

   private HierarchicalConfiguration buildConfiguration(final RepositoryRequest request) {
       final HierarchicalConfiguration configuration = ConfigUtils.newConfiguration();
       configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_HOSTNAME, GithubEnterpriseRepository.getDefaultHostname());
       configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_USERNAME, request.username);
       configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_PASSWORD, encryptionService.encrypt(request.password));
       configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_REPOSITORY, request.repository);
       configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_BRANCH, request.branch);
       configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_USE_SHALLOW_CLONES, request.shallowClones);
       configuration.setProperty("repository.github.useShallowClones", request.shallowClones);
       configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_USE_REMOTE_AGENT_CACHE, false);
       configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_USE_SUBMODULES, true);
       configuration.setProperty("repository.github.useSubmodules", true);
       configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_VERBOSE_LOGS, false);
       configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_FETCH_WHOLE_REPOSITORY, false);
       configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_COMMAND_TIMEOUT, String.valueOf(GithubEnterpriseRepository.DEFAULT_COMMAND_TIMEOUT_IN_MINUTES));

       return configuration;
   }
}
