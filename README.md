# Canoe

:ship:

## Development Setup

```
script/bootstrap
```

### Secrets

Canoe uses the GitHub API to get information about branches, tags, etc. For local development, you can use your own user to authenticate against that API.

First, copy the `.env.sample` file to `.env`:

```
cp .env.sample .env
```

[Create a Personal Access Token](https://git.dev.pardot.com/settings/applications) and provide it as `GITHUB_PASSWORD` in `.env`:

```
# .env
GITHUB_USER=my_ldap_username
GITHUB_PASSWORD=my_personal_access_token
```
