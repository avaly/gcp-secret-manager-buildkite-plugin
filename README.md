# GCP Secret Manager Buildkite Plugin

Use secrets from GCP Secret Manager in your environment variables.

This plugin requires a Google Cloud credentials file to be available on your Buildkite Agent machines.

Other preinstalled requirements:

- `gcloud`
- `jq`

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
