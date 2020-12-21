#!/usr/bin/env bats

load "$BATS_PATH/load.bash"

environment_hook="$PWD/hooks/environment"

@test "Fetches values from GCP Secret Manager into env" {
  export BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_CREDENTIALS_FILE="/tmp/credentials.json"
  export BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_ENV_TARGET1="secret1"

  stub which \
    "gcloud : echo /test/gcloud" \
    "jq : echo /test/jq"

  stub gcloud \
    "auth activate-service-account --key-file /tmp/credentials.json : echo OK" \
    "secrets versions list secret1 --format=json : echo '[{\"name\":\"secret1/versions/10\"}]'" \
    "secrets versions access 10 --secret=secret1 '--format=get(payload.data)' : echo 'dGVzdC12YWx1ZTEK'"

  run "${environment_hook}"

  assert_success
  assert_output --partial "Exporting secret secret1 from GCP Secret Manager into environment variable TARGET1"

  unstub gcloud
  unstub which

  unset BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_CREDENTIALS_FILE
  unset BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_ENV_TARGET1
}