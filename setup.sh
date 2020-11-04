#!/usr/bin/env bash

# Make sure you've run `boot.sh` in a separate terminal first

export VAULT_ADDR='http://127.0.0.1:8200'

mkdir -p ca

# Configure a backend for the root cert (this might be outside of vault for production..)
vault secrets enable pki
vault secrets tune -max-lease-ttl=87600h pki
# Generate us a root cert/key (vault contains the key). Write the cert out to disk
vault write -field=certificate pki/root/generate/internal common_name="ca.chd.test Root Authority" ttl=8760h > ca/root_cert.crt
# Setup stuff we need setup (?)
vault write pki/config/urls issuing_certificates="http://127.0.0.1:8200/v1/pki/ca" crl_distribution_points="http://127.0.0.1:8200/v1/pki/crl"

# Configure a new backend at a new path for intermediate bits
vault secrets enable -path=pki_inter pki
vault secrets tune -max-lease-ttl=720h pki_inter
# Generate CSR for intermediate
vault write -format=json pki_inter/intermediate/generate/internal common_name="ca.chd.test Intermediate Authority" | \
  jq -r '.data.csr' > ca/intermediate_cert.csr
# Sign the intermediate CSR with the root cert to generate the intermediate cert/key (key is stored in vault)
vault write -format=json pki/root/sign-intermediate csr=@ca/intermediate_cert.csr format=pem_bundle ttl="4380h" | \
  jq -r '.data.certificate' > ca/intermediate.cert.pem

# Save intermediate cert back inside vault
vault write pki_inter/intermediate/set-signed certificate=@ca/intermediate.cert.pem

# Now we have to configure a role, so we can generate leaf certificates from the intermediate
vault write pki_inter/roles/internal-test allowed_domains="internal.test" allow_subdomains=true max_ttl=720h
