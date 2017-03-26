# Pardot Bamboo Plugin

This [Bamboo plugin] contains customizations to the Bamboo CI server for Salesforce Pardot.

Currently, it adds:
* GitHub Enterprise repository support
* Webhook-based triggers for GitHub Enterprise repositories
* HTTP API for creating linked repositories and build plans

## Building

```bash
atlas-package
# Upload target/pardot-bamboo-plugin-*.jar to Bamboo using the Add-Ons interface
```

## Local Testing

```bash
atlas-debug
# Navigate to http://localhost:6990/bamboo
```

[Bamboo plugin]: https://developer.atlassian.com/bamboodev/bamboo-plugin-guide
