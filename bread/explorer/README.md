# Pardot Explorer

<https://explorer.pardot.com>

# How to update the shards list

The database configuration and list of shards is manually synced from the main
Pardot/pardot repository. To do so, use the `script/pi-dbconfig` script. On a
macOS machine install the PHP7 and the YAML extension:

```
$ brew install php71-yaml
```

Then checkout the script usage and follow instructions:

```
$ script/pi-dbconfig --help
```

Finally, commit the updated config at `config/pi/production.yml` and open a pull
request.
