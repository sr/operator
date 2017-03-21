package com.pardot.bread.bambooplugin;

import com.atlassian.bamboo.plugins.git.GitHubRepository;
import com.pardot.bread.bambooplugin.repository.GithubEnterpriseRepository;
import org.kohsuke.github.GHCommitState;
import org.kohsuke.github.GHRepository;
import org.kohsuke.github.GitHub;

import java.io.IOException;

public class GithubStatus {
    public static void create(GitHubRepository repository, String sha, GHCommitState state, String url, String context) throws IOException {
        final int MAX_RETRIES = 3;

        int attempts = 0;
        while (true) {
            try {
                GitHub client = GitHub.connectToEnterprise(
                        GithubEnterpriseRepository.GITHUB_API_BASE_URL,
                        repository.getUsername(),
                        repository.getPassword()
                );

                GHRepository ghRepository = client.getRepository(repository.getRepository());
                ghRepository.createCommitStatus(sha, state, url, null, context);
                return;
            } catch (IOException e) {
                if (++attempts >= MAX_RETRIES) {
                    throw e;
                }
            }
        }
    }
}
