#!/usr/bin/env bats

setup() {
  load "$BATS_PLUGIN_PATH/load.bash"

  # Uncomment to enable stub debugging
  # export GCLOUD_STUB_DEBUG=/dev/tty

  stub which \
    "gcloud : echo /test/gcloud" \
    "jq : echo /test/jq"
}

teardown() {
  unstub gcloud
  unstub which
}

function stub_gcloud_secrets() {
  stub gcloud \
    "secrets versions access latest --secret=secret1 '--format=get(payload.data)' : echo 'dGVzdC12YWx1ZTEK'" \
    "secrets versions access latest --secret=secret2 '--format=get(payload.data)' : echo 'dGVzdC12YWx1ZTI='"
}

function stub_gcloud_secrets_fqn() {
  local project=$1

  stub gcloud \
    "secrets versions access projects/${project}/secrets/SECRET_NAME1/versions/latest --secret=SECRET_NAME1 '--format=get(payload.data)' : echo 'dGVzdC12YWx1ZTEK'" \
    "secrets versions access projects/${project}/secrets/SECRET_NAME2/versions/1 --secret=SECRET_NAME2 '--format=get(payload.data)' : echo 'dGVzdC12YWx1ZTI='" 
}

environment_hook="$PWD/hooks/environment"

@test "Exports values from GCP Secret Manager into env - output" {
  export BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_CREDENTIALS_FILE="/tmp/credentials.json"
  export BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_ENV_TARGET1="secret1"
  export BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_ENV_TARGET2="secret2"

  stub gcloud "auth activate-service-account --key-file /tmp/credentials.json : "
  stub_gcloud_secrets

  run "${environment_hook}"

  assert_success
  assert_output --partial "Exporting secret secret1 from GCP Secret Manager into environment variable TARGET1"
  assert_output --partial "Exporting secret secret2 from GCP Secret Manager into environment variable TARGET2"

  unset BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_CREDENTIALS_FILE
  unset BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_ENV_TARGET1
  unset BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_ENV_TARGET2
}

@test "Fetches values from GCP Secret Manager into env - variables" {
  export BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_CREDENTIALS_FILE="/tmp/credentials.json"
  export BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_ENV_TARGET1="secret1"
  export BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_ENV_TARGET2="secret2"

  stub gcloud "auth activate-service-account --key-file /tmp/credentials.json : "
  stub_gcloud_secrets

  # Using `run` will not populate these variables in the current shell
  source "${environment_hook}"

  assert_equal $TARGET1 "test-value1"
  assert_equal $TARGET2 "test-value2"

  unset BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_CREDENTIALS_FILE
  unset BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_ENV_TARGET1
  unset BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_ENV_TARGET2
}

@test "Exports values from GCP Secret Manager into env via Application Default Credentials - output" {
  export BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_ENV_TARGET1="secret1"
  export BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_ENV_TARGET2="secret2"

  stub_gcloud_secrets

  run "${environment_hook}"

  assert_success
  assert_output --partial "Exporting secret secret1 from GCP Secret Manager into environment variable TARGET1"
  assert_output --partial "Exporting secret secret2 from GCP Secret Manager into environment variable TARGET2"

  unset BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_ENV_TARGET1
  unset BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_ENV_TARGET2
}

@test "Exports values from GCP Secret Manager into env via Application Default Credentials - variables" {
  export BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_ENV_TARGET1="secret1"
  export BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_ENV_TARGET2="secret2"

  stub_gcloud_secrets

  # Using `run` will not populate these variables in the current shell
  source "${environment_hook}"

  assert_equal $TARGET1 "test-value1"
  assert_equal $TARGET2 "test-value2"

  unset BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_ENV_TARGET1
  unset BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_ENV_TARGET2
}


@test "Supports fully qualified names without version" {
  export BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_ENV_TARGET1="projects/test-project/secrets/SECRET_NAME1"

  stub_gcloud_secrets_fqn test-project

  # Using `run` will not populate these variables in the current shell
  source "${environment_hook}"

  assert_equal $TARGET1 "test-value1"

  unset BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_ENV_TARGET1
}

@test "Supports fully qualified names with specific version" {
  export BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_ENV_TARGET1="projects/test-project/secrets/SECRET_NAME1/versions/latest"
  export BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_ENV_TARGET2="projects/test-project/secrets/SECRET_NAME2/versions/1"

  stub_gcloud_secrets_fqn test-project

  # Using `run` will not populate these variables in the current shell
  source "${environment_hook}"

  assert_equal $TARGET1 "test-value1"
  assert_equal $TARGET2 "test-value2"

  unset BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_ENV_TARGET1
  unset BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_ENV_TARGET2
}


@test "Supports fully qualified names with project number" {
  export BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_ENV_TARGET1="projects/01726654/secrets/SECRET_NAME1"

  stub_gcloud_secrets_fqn 01726654

  # Using `run` will not populate these variables in the current shell
  source "${environment_hook}"

  assert_equal $TARGET1 "test-value1"

  unset BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_ENV_TARGET1
}
