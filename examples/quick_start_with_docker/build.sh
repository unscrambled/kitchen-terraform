#!/bin/sh

set -e

KITCHEN_TERRAFORM_CERTIFICATE="ncs-alane-public_cert.pem"

TERRAFORM_ARCHIVE="terraform_${TERRAFORM_VERSION}_linux_amd64.zip"

TERRAFORM_SHASUM="terraform_${TERRAFORM_VERSION}_SHA256SUMS"

TERRAFORM_SHASUM_SIGNATURE="${TERRAFORM_SHASUM}.sig"

TERRAFORM_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}"

apk add --no-cache --virtual .build-dependencies build-base gnupg unzip

apk add --no-cache --virtual .production-dependencies bash curl git

curl https://keybase.io/hashicorp/pgp_keys.asc | gpg --import

curl --silent --remote-name "${TERRAFORM_URL}/${TERRAFORM_SHASUM_SIGNATURE}"

curl --silent --remote-name "${TERRAFORM_URL}/${TERRAFORM_SHASUM}"

gpg --verify "${TERRAFORM_SHASUM_SIGNATURE}" "${TERRAFORM_SHASUM}"

curl --silent --remote-name "${TERRAFORM_URL}/${TERRAFORM_ARCHIVE}"

sha256sum -c "${TERRAFORM_SHASUM}" 2>&1 | grep "12 of 13 computed"

unzip "${TERRAFORM_ARCHIVE}" -d /usr/local/bin

curl --silent --remote-name \
  "https://raw.githubusercontent.com/newcontext-oss/kitchen-terraform/master/certs/${KITCHEN_TERRAFORM_CERTIFICATE}"

gem cert --add "${KITCHEN_TERRAFORM_CERTIFICATE}"

gem install kitchen-terraform --minimal-deps --no-document \
  --trust-policy AlmostNoSecurity --version "${KITCHEN_TERRAFORM_VERSION}"

apk del .build-dependencies

rm "${KITCHEN_TERRAFORM_CERTIFICATE}" "${TERRAFORM_ARCHIVE}" \
  "${TERRAFORM_SHASUM}" "${TERRAFORM_SHASUM_SIGNATURE}"
