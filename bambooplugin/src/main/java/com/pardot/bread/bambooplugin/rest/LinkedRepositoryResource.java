package com.pardot.bread.bambooplugin.rest;

import com.atlassian.bamboo.plan.branch.VcsBranchImpl;
import com.atlassian.bamboo.repository.*;
import com.atlassian.bamboo.user.BambooAuthenticationContext;
import com.atlassian.bamboo.vcs.configuration.PartialVcsRepositoryData;
import com.atlassian.bamboo.vcs.configuration.PartialVcsRepositoryDataBuilder;
import com.atlassian.bamboo.vcs.configuration.service.VcsRepositoryConfigurationService;
import com.atlassian.bamboo.vcs.module.VcsRepositoryManager;
import com.atlassian.bamboo.vcs.module.VcsRepositoryModuleDescriptor;
import com.atlassian.bamboo.ww2.actions.build.admin.create.BuildConfiguration;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.Maps;
import com.pardot.bread.bambooplugin.repository.GithubEnterpriseRepository;
import org.apache.log4j.Logger;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

@Path("/linkedrepos")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class LinkedRepositoryResource {
    private static final Logger log = Logger.getLogger(LinkedRepositoryResource.class);

    private static final String githubEnterpriseRepositoryKey = "com.pardot.bread.bambooplugin.pardot-bamboo-plugin:github-enterprise-repository";

    private BambooAuthenticationContext authenticationContext;
    private RepositoryDefinitionManager repositoryDefinitionManager;
    private VcsRepositoryConfigurationService vcsRepositoryConfigurationService;
    private VcsRepositoryManager vcsRepositoryManager;

    public void setAuthenticationContext(final BambooAuthenticationContext authenticationContext) {
        this.authenticationContext = authenticationContext;
    }

    public void setVcsRepositoryConfigurationService(VcsRepositoryConfigurationService vcsRepositoryConfigurationService) {
        this.vcsRepositoryConfigurationService = vcsRepositoryConfigurationService;
    }

    public void setRepositoryDefinitionManager(RepositoryDefinitionManager repositoryDefinitionManager) {
        this.repositoryDefinitionManager = repositoryDefinitionManager;
    }

    public void setVcsRepositoryManager(VcsRepositoryManager vcsRepositoryManager) {
        this.vcsRepositoryManager = vcsRepositoryManager;
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

        public static RepositoryResponse newFromRepositoryData(final PartialVcsRepositoryData data) {
            RepositoryResponse information = new RepositoryResponse();
            information.id = data.getId();
            information.name = data.getName();

            BuildConfiguration buildConfiguration = new BuildConfiguration(data.getVcsLocation().getLegacyConfigurationXml());
            information.branch = buildConfiguration.getString(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_BRANCH, null);
            information.repository = buildConfiguration.getString(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_REPOSITORY, null);
            information.shallowClones = buildConfiguration.getBoolean(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_USE_SHALLOW_CLONES, false);
            return information;
        }
    }

    @GET
    @Path("/{id}")
    public Response get(@PathParam("id") final long id) {
        final PartialVcsRepositoryData vcsRepositoryData = repositoryDefinitionManager.getVcsRepositoryDataForEditing(id);
        if (vcsRepositoryData == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        RepositoryResponse information = RepositoryResponse.newFromRepositoryData(vcsRepositoryData);
        return Response.ok(information).build();
    }

    @DELETE
    @Path("/{id}")
    public Response delete(@PathParam("id") final long id) {
        final PartialVcsRepositoryData vcsRepositoryData = repositoryDefinitionManager.getVcsRepositoryDataForEditing(id);
        if (vcsRepositoryData == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        vcsRepositoryConfigurationService.deleteLinkedRepository(id);
        return Response.noContent().build();
    }

    @POST
    public Response create(final RepositoryRequest repositoryRequest) {
        final VcsRepositoryModuleDescriptor vcsDescriptor = vcsRepositoryManager.getVcsRepositoryModuleDescriptor(githubEnterpriseRepositoryKey);
        PartialVcsRepositoryData repositoryData = PartialVcsRepositoryDataBuilder.newBuilder()
                .pluginKey(vcsDescriptor.getCompleteKey())
                .name(repositoryRequest.name)
                .legacyXml(buildConfiguration(repositoryRequest).asXml())
                .serverConfiguration(ImmutableMap.of())
                .vcsBranch(new VcsBranchImpl(repositoryRequest.branch))
                .branchConfiguration(Maps.newHashMap())
                .build();

        repositoryData = vcsRepositoryConfigurationService.createLinkedRepository(
                repositoryData,
                authenticationContext.getUser(),
                RepositoryConfigurationService.LinkedRepositoryAccess.ALL_USERS
        );

        RepositoryResponse information = RepositoryResponse.newFromRepositoryData(repositoryData);
        return Response.ok(information)
                .status(Response.Status.CREATED)
                .build();
    }

    @PUT
    @Path("/{id}")
    public Response update(@PathParam("id") final long id, final RepositoryRequest repositoryRequest) {
        final PartialVcsRepositoryData vcsRepositoryData = repositoryDefinitionManager.getVcsRepositoryDataForEditing(id);
        if (vcsRepositoryData == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        final VcsRepositoryModuleDescriptor vcsDescriptor = vcsRepositoryManager.getVcsRepositoryModuleDescriptor(githubEnterpriseRepositoryKey);
        PartialVcsRepositoryData repositoryData = PartialVcsRepositoryDataBuilder.newBuilder()
                .pluginKey(vcsDescriptor.getCompleteKey())
                .name(repositoryRequest.name)
                .legacyXml(buildConfiguration(repositoryRequest).asXml())
                .serverConfiguration(ImmutableMap.of())
                .vcsBranch(new VcsBranchImpl(repositoryRequest.branch))
                .branchConfiguration(Maps.newHashMap())
                .build();

        repositoryData = vcsRepositoryConfigurationService.editLinkedRepository(
                id,
                repositoryData
        );

        RepositoryResponse information = RepositoryResponse.newFromRepositoryData(repositoryData);
        return Response.ok(information)
                .build();
    }

   private BuildConfiguration buildConfiguration(final RepositoryRequest request) {
       final BuildConfiguration configuration = new BuildConfiguration();
       configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_HOSTNAME, GithubEnterpriseRepository.getDefaultHostname());
       configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_USERNAME, request.username);
       configuration.setProperty(GithubEnterpriseRepository.REPOSITORY_GITHUBENTERPRISE_PASSWORD, request.password);
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
