#!/bin/bash -e

readonly VAULT_SERVER="https://vault.dev.pardot.com"
readonly ARTIFACTORY_ENV_FILE="/etc/env/artifactoryenv"
readonly BAMBOO_ENV_FILE="/etc/env/bambooenv"
readonly SA_BREAD_ENV_FILE="/etc/env/sa_bread"
readonly AWS_CRED_FILE="/etc/aws/credentials"
readonly HIPCHAT_FILE="/etc/hipchat"
readonly MVN_SETTINGS_FILE="/etc/mvn/settings_xmls/sa_bamboo.xml"
readonly CLOVER_FILE="/etc/clover/clover.license"
readonly DOCKER_CONFIG_FILE="/etc/docker/config.json"
readonly BAMBOO_HOME="/home/bamboo"
readonly ROOT_HOME="/root"

# perform vault authentication
pkcs7="$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/pkcs7 | tr -d '\n')"
nonce="$(uuidgen)"

result="$(curl -s -XPOST "$VAULT_SERVER/v1/auth/aws-ec2/login" \
  -d '{"role":"ci-role","pkcs7":"'"$pkcs7"'","nonce":"'"$nonce"'"}"')"

token="$(jq -r .auth.client_token <<< "$result")"
if [ -z "$token" ] || [ "$token" = "null" ]; then
  echo "Unable to generate an auth token: $result" 2>&1
  exit 1
fi

# retrieve bamboo secrets
ci_secrets="$(curl -s "$VAULT_SERVER/v1/secret/ci/bamboo" -H "X-Vault-Token: $token")"
if [ -z "$ci_secrets" ]; then
  echo "Unable to retrieve CI secrets" 2>&1
  exit 1
fi

# create or ensure existence of required directories
for dir in /etc/env /etc/aws /etc/mvn /etc/mvn/settings_xmls /etc/clover /etc/docker; do
  mkdir -p "$dir"
  chmod 0755 "$dir"
done

# populate files
echo "PROTOCOL=https" > $ARTIFACTORY_ENV_FILE
# shellcheck disable=SC2129
echo "ARTIFACTORYHOST=artifactory-internal.dev.pardot.com" >> $ARTIFACTORY_ENV_FILE
echo "CONTEXTPATH=artifactory" >> $ARTIFACTORY_ENV_FILE
echo "USERNAME=\"$(echo "$ci_secrets" | jq -r .data.artifactory.username)\"" >> $ARTIFACTORY_ENV_FILE
echo "PASSWORD=\"$(echo "$ci_secrets" | jq -r .data.artifactory.password)\"" >> $ARTIFACTORY_ENV_FILE

echo "BAMBOO_USERNAME='$(echo "$ci_secrets" | jq -r .data.bamboo.username)'" > $BAMBOO_ENV_FILE
echo "BAMBOO_PASSWORD='$(echo "$ci_secrets" | jq -r .data.bamboo.password)'" >> $BAMBOO_ENV_FILE

mkdir -p "$BAMBOO_HOME/.ssh"
echo "$ci_secrets" | jq -r .data.bamboo.rsa | base64 --decode > "$BAMBOO_HOME/.ssh/id_rsa"
chown bamboo: "$BAMBOO_HOME/.ssh" "$BAMBOO_HOME/.ssh/id_rsa"
chmod 0700 "$BAMBOO_HOME/.ssh"
chmod 0600 "$BAMBOO_HOME/.ssh/id_rsa"

mkdir -p "$ROOT_HOME/.ssh"
echo "$ci_secrets" | jq -r .data.bamboo.rsa | base64 --decode > "$ROOT_HOME/.ssh/id_rsa"
chown bamboo: "$ROOT_HOME/.ssh" "$ROOT_HOME/.ssh/id_rsa"
chmod 0700 "$ROOT_HOME/.ssh"
chmod 0600 "$ROOT_HOME/.ssh/id_rsa"

echo "[default]" > $SA_BREAD_ENV_FILE
echo "aws_access_key_id = $(echo "$ci_secrets" | jq -r .data.aws_sa_bread.access_key)" >> $SA_BREAD_ENV_FILE
echo "aws_secret_access_key = $(echo "$ci_secrets" | jq -r .data.aws_sa_bread.secret_key)" >> $SA_BREAD_ENV_FILE

echo "[pardotops]" > $AWS_CRED_FILE
echo "aws_access_key_id = $(echo "$ci_secrets" | jq -r .data.aws_pardotops.access_key)" >> $AWS_CRED_FILE
echo "aws_secret_access_key = $(echo "$ci_secrets" | jq -r .data.aws_pardotops.secret_key)" >> $AWS_CRED_FILE

echo "HIPCHAT_TOKEN=\"$(echo "$ci_secrets" | jq -r .data.hipchat.token)\"" > $HIPCHAT_FILE
# shellcheck disable=SC2129
echo "HIPCHAT_ROOM_ID=\"82\"" >> $HIPCHAT_FILE
echo "HIPCHAT_FROM=\"Bamboo\"" >> $HIPCHAT_FILE
echo "HIPCHAT_COLOR=\"random\"" >> $HIPCHAT_FILE
echo "HIPCHAT_FORMAT=\"html\"" >> $HIPCHAT_FILE
echo "HIPCHAT_MESSAGE=\"unconfigured hipchat message\"" >> $HIPCHAT_FILE
echo "HIPCHAT_NOTIFY=\"false\"" >> $HIPCHAT_FILE
echo "HIPCHAT_HOST=\"hipchat.dev.pardot.com\"" >> $HIPCHAT_FILE
echo "HIPCHAT_API=\"v1\"" >> $HIPCHAT_FILE

echo "$ci_secrets" | jq -r .data.mvn.settings.sa_bamboo | base64 --decode > $MVN_SETTINGS_FILE

echo "$ci_secrets" | jq -r .data.clover.license | base64 --decode > $CLOVER_FILE

echo "$ci_secrets" | jq -r .data.docker.config | base64 --decode > $DOCKER_CONFIG_FILE
