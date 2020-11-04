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
