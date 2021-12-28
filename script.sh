#!/usr/bin/env bash

set -euo pipefail

GNUPGHOME=$(mktemp -d)
echo $GNUPGHOME

while read -r line;
do
	echo ${line}
  NAME="$(echo ${line} | cut -d, -f1)"
  EMAIL="$(echo ${line} | cut -d, -f2)"
  gpg --homedir ${GNUPGHOME} --quiet \
  		--batch --no-tty --gen-key <<EOF
      Key-Type: RSA
      Key-Length: 4096
      Subkey-Type: RSA
      Subkey-Length: 4096
      Name-Real: ${NAME}
      Name-Email: ${EMAIL}
      Expire-Date: 0
      Passphrase: ${EMAIL}
      %commit
EOF
  SHORT="$(echo $EMAIL | cut -d@ -f1)"
  rm -f config/gpg/${SHORT}_{public,private}.key
  gpg --homedir ${GNUPGHOME} \
			--output config/gpg/${SHORT}_public.key \
			--pinentry-mode loopback \
			--armor --export --quiet \
			${EMAIL}
  echo ${EMAIL} | gpg --output config/gpg/${SHORT}_private.key \
    --armor --homedir ${GNUPGHOME} --pinentry-mode loopback \
    --batch --quiet --yes --passphrase-fd 0 --export-secret-keys ${EMAIL}
done < users.list
