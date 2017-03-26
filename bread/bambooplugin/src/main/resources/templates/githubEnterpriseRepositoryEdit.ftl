[#-- @ftlvariable name="repository" type="com.pardot.bread.bambooplugin.repository.GithubEnterpriseRepository" --]

[@ww.textfield labelKey='repository.githubenterprise.hostname' name='repository.githubenterprise.hostname' value=repository.hostname readonly=true required=true /]

[@ww.textfield labelKey='repository.githubenterprise.username' name='repository.githubenterprise.username' required=true /]
[#if buildConfiguration.getString('repository.githubenterprise.password')?has_content]
    [@ww.checkbox labelKey='repository.password.change' toggle=true name='temporary.githubenterprise.password.change' /]
    [@ui.bambooSection dependsOn='temporary.githubenterprise.password.change']
        [@ww.password labelKey='repository.githubenterprise.password' name='repository.githubenterprise.temporary.password' /]
    [/@ui.bambooSection]
[#else]
    [@ww.hidden name='temporary.githubenterprise.password.change' value='true' /]
    [@ww.password labelKey='repository.githubenterprise.password' name='repository.githubenterprise.temporary.password' /]
[/#if]

[@s.select labelKey='repository.githubenterprise.repository' name='repository.githubenterprise.repository' descriptionKey='repository.githubenterprise.repository.description' fieldClass='github-repository'
    cssClass='select2-container aui-select2-container']
    [@s.param name='disabled' value=!(buildConfiguration.getString('repository.githubenterprise.repository')?has_content) /]
    [@s.param name='extraUtility'][@ui.displayButton id='repository-githubenterprise-load-repositories' valueKey='repository.githubenterprise.loadRepositories'/][/@s.param]
    [#if buildConfiguration.getString('repository.githubenterprise.repository')?has_content]
        [@s.param name='headerKey2' value=buildConfiguration.getString('repository.githubenterprise.repository') /]
        [@s.param name='headerValue2' value=buildConfiguration.getString('repository.githubenterprise.repository') /]
    [/#if]
[/@s.select]

[@ww.select labelKey='repository.githubenterprise.branch' name='repository.githubenterprise.branch' descriptionKey='repository.githubenterprise.branch.description' fieldClass='github-branch']
    [@ww.param name='hidden' value=!(buildConfiguration.getString('repository.githubenterprise.branch')?has_content) /]
    [#if buildConfiguration.getString('repository.githubenterprise.branch')?has_content]
        [@ww.param name='headerKey2' value=buildConfiguration.getString('repository.githubenterprise.branch') /]
        [@ww.param name='headerValue2' value=buildConfiguration.getString('repository.githubenterprise.branch') /]
    [/#if]
[/@ww.select]

[@ww.checkbox labelKey='repository.githubenterprise.useShallowClones' toggle=true name='repository.githubenterprise.useShallowClones' /]
[#if (plan.buildDefinition.branchIntegrationConfiguration.enabled)!false ]
    [@ui.bambooSection dependsOn='repository.githubenterprise.useShallowClones']
        [@ui.messageBox type='info' titleKey='repository.git.messages.branchIntegration.shallowClonesWillBeDisabled' /]
    [/@ui.bambooSection]
[/#if]

[@ww.checkbox labelKey='repository.githubenterprise.useRemoteAgentCache' toggle=false name='repository.githubenterprise.useRemoteAgentCache' /]

<script type="text/javascript">
(function () {
    BAMBOO = window.BAMBOO || window.parent.BAMBOO;
    var rf = new BAMBOO.GITHUBENTERPRISE.RepositoryForm({
        repositoryKey: '${repository.key?js_string}',
        repositoryId: ${(repositoryId)!0},
        selectors: {
            repositoryType: '#selectedRepository',
            username: 'input[name="repository.githubenterprise.username"]',
            password: 'input[name="repository.githubenterprise.temporary.password"]',
            loadRepositoriesButton: '#repository-githubenterprise-load-repositories',
            repository: 'select[name="repository.githubenterprise.repository"]',
            branch: 'select[name="repository.githubenterprise.branch"]'
        }
    });
    rf.init();
}());
</script>

