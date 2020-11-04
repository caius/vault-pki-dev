# Vault TLS sandbox

https://www.vaultproject.io/docs/secrets/pki

Help for PKI engine: `vault path-help pki`

* Boot a dev vault server (everything held in memory, as soon as you kill it you lose anything in it!)

        ./boot.sh

* Open a new tab, run setup to generate a root cert and intermediate signed by the root

        ./setup.sh

```
↳ caius$ tree ca
ca
├── intermediate.cert.pem
├── intermediate_cert.csr
└── root_cert.crt
```

Once you've done this, you can generate certificates under the "internal.test" domain name quite happily. (The private key isn't stored in vault, and is only returned in the write response, so keep them safe.)

  (internal-test is the role name from `setup.sh`)

    vault write -format=json pki_inter/issue/internal-test common_name="001.internal.test" ttl="72h"
