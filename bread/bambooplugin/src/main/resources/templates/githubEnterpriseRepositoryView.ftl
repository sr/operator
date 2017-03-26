[#-- @ftlvariable name="repository" type="com.pardot.bread.bambooplugin.repository.GithubEnterpriseRepository" --]

[@ww.label labelKey='repository.githubenterprise.hostname' value=repository.hostname?html /]
[@ww.label labelKey='repository.githubenterprise.repository' value=repository.repository?html /]
[@ww.label labelKey='repository.githubenterprise.branch' value=repository.branch!?html hideOnNull=true /]
[@ww.label labelKey='repository.githubenterprise.useShallowClones' value=repository.useShallowClones?string hideOnNull=true /]
[@ww.label labelKey='repository.githubenterprise.useSubmodules' value=repository.useSubmodules?string hideOnNull=true /]
[@ww.label labelKey='repository.githubenterprise.commandTimeout' value=repository.commandTimeout! hideOnNull=true /]
[@ww.label labelKey='repository.githubenterprise.verbose.logs' value=repository.verboseLogs?string hideOnNull=true /]

