# Build Worker

The scripts in this directory build the 'base box' we use as our continuous integration (CI) worker machines.

Most builds use Docker these days, so the CI machine itself basically only needs [a Bamboo agent](https://confluence.atlassian.com/bamboo/creating-a-custom-elastic-image-linux-296093037.html) and [Docker](https://www.docker.com). We add a few more things for convenience, but nothing build-specific.

## Building

Add AWS credentials for the `pardot-ci` AWS account to `~/.aws/credentials`

```ini
[pardot-ci]
aws_access_key_id = ABC123
aws_secret_access_key = ebf567
```

Install [packer](https://www.packer.io):

```bash
brew install packer
```

**Drop off the aloha-* VPN**. For some reason, the VPN interferes with `packer`'s ability to maintain communication with the EC2 instance.

Build the AMI:

```bash
AWS_PROFILE=pardot-ci packer build -only=amazon-ebs instance.json
```

Replace the AMI identifier spit out by the `packer` build in the [Bamboo elastic image configuration page](https://bamboo.dev.pardot.com/admin/elastic/image/configuration/editElasticImageConfiguration.action?configurationId=37814274&returnUrl=%2Fadmin%2Felastic%2Fimage%2Fconfiguration%2FviewElasticImageConfigurations.action).

Tada!

## Future Work

Building and running a smoke test or two on the instance should be completely automated at some point. As in, there should be a CI job that builds the CI image and releases it. But using `packer` locally reduces 80% of the friction we used to have when building the base box and we have other priorities. But if you have some extra time and want to push this over the finish line, feel free.
