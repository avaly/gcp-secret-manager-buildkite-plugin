# GCP Secret Manager Buildkite Plugin

[![GitHub Release](https://img.shields.io/github/release/avaly/gcp-secret-manager-buildkite-plugin.svg)](https://github.com/avaly/gcp-secret-manager-buildkite-plugin/releases) [![Build status](https://badge.buildkite.com/2d6dda24352064bc947c7affb868734d615bafeecb22102007.svg?branch=master)]()

A [Buildkite plugin](https://buildkite.com/docs/agent/v3/plugins) to read secrets from [GCP Secret Manager](https://cloud.google.com/secret-manager).

This plugin requires a Google Cloud credentials file to be available on your Buildkite Agent machines.

Other preinstalled requirements:

- [`gcloud`](https://cloud.google.com/sdk/)
- [`jq`](https://stedolan.github.io/jq/)

## Example

Add the following to your `pipeline.yml`:

```yml
steps:
  - command: 'echo \$SECRET_VAR'
    plugins:
      - avaly/gcp-secret-manager#v1.0.0:
          credentials_file: /etc/gcloud-credentials.json
          env:
            SECRET_VAR: my-secret-name
            OTHER_SECRET_VAR: my-other-secret-name
```

## Configuration

### `credentials_file` (Required, string)

The file path of a Google Cloud credentials file, which is used to access the secrets. The account of the credentials file needs to have the Secret Manager Secret Accessor role (`roles/secretmanager.secretAccessor`).

### `env` (object)

An object defining the export variables names and the secret names which will populate the values.

## Developing

To run the tests:

```shell
docker-compose run --rm shellcheck
docker-compose run --rm tests
```

## Contributing

1. Fork the repo
2. Make the changes
3. Run the tests
4. Commit and push your changes
5. Send a pull request
