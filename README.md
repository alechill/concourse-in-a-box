# concourse-in-a-box

All-in-one [Concourse] CI/CD system based on Docker Compose, with Minio S3-compatible storage and HashiCorp Vault secret manager. This enables to:

1. Learn Concourse pipelines from scratch in a simple environment.
2. Troubleshoot production Concourse pipelines in a stand-alone environment.
3. Write Concourse pipelines that can be reused as-is in your production environment, since it comes with S3 and secret store.

# Security considerations

This project is NOT adapted for production or networked use.

Among other non-production ready settings, it contains hard-coded secrets, stored in the git repo. For production use, all secrets must be regenerated and must not be stored in the git repo!

# What's in the box

* [Concourse] v7.8.2 (ATC and web UI)
* Concourse worker (platform: Linux)
* [PostgreSQL] v13.2 (needed by Concourse web)
* [Minio] latest stable S3-compatible object storage. With this, you can learn writing real-world Concourse pipelines using the [concourse-s3-resource] without the need of setting up an AWS S3 (or any other cloud provider) account.
* [HashiCorp Vault] v1.7.1 secret and credential manager. With this, you can learn writing real-world Concourse pipelines following security and operations best practices. See also [Concourse credential management] for how Concourse uses Vault.
* the incomplete [Concourse primer](doc/concourse-primer.md) tutorial.

# Usage

The various credentials are in file [.env.example](./.env.example) and can be changed if you wish. They will be read automatically by `docker compose`.

Before first use `cp .env.example .env` and add your extra values to `.env`, this will not be committed.

To add new secrets, they must be added as env vars in the .env file, mapped to Docker env vars in `docker-compose.yaml`, and added to `vault-setup.sh`.

## Common setup and teardown

### Setup

* Download the images:
  ```
  $ docker compose pull
  ```

* Start the containers:
  ```
  $ docker compose up
  ```

### Verify setup

The docker-compose file uses some short-lived containers to perform initialization. Given the amount of log output from `docker compose up`, failures can be hard to notice.

Run `docker compose ps` and confirm that the containers ending with `-setup` have exited with a `0` state. If any of them exited with a different code, then look back at the logs from `docker compose up` and identify the problem.

For example:

```
$ docker compose ps | grep setup
concourse-in-a-box_minio-setup_1   /scripts/minio-setup.sh          Exit 1
concourse-in-a-box_vault-setup_1   /scripts/vault-setup.sh          Exit 0
```

The minio setup failed.

### Teardown

* When done, remember to stop the containers:
  ```
  $ docker compose stop
  ```
* If you want to also delete the persistent volumes, in order to delete the Concourse build history and the contents of the Minio S3 buckets:
  ```
  $ docker compose down
  ```

## Concourse setup

* Point your web browser to http://localhost:8080 and follow the instructions there:
  * Download the `fly` command-line tool and put it in your $PATH.
  * Login to the web interface.
* In another terminal, login with `fly` (will open the web browser to finish authentication):
  ```
  $ fly --target=main login --concourse-url=http://localhost:8080 --open-browser
  ```
* You can use anything as the value for `--target`, it is an alias for the connection to the given Concourse with the given credentials (see file `$HOME/.flyrc`).

## Minio S3 setup

* The `minio-setup` container creates a bucket named `concourse`.
* Optional: point your browser to http://localhost:9001 and login.
* Optional: follow [mc documentation] and install the command-line client `mc`.
* If you want to create additional buckets, you can add to [scripts/minio-setup.sh](scripts/minio-setup.sh).

## Vault setup

* For the time being vault is configured in dev mode, which means that the storage backend is in memory and will not be persisted to disk.
* The `vault-setup` container adds the S3 secrets to vault.
* Optional: point your browser to http://localhost:8200 and login.
* Optional: follow [vault download], install the command-line utility `vault` and login.
* If you want to create more secrets, see [scripts/vault-setup.sh](scripts/vault-setup.sh).

# Concourse primer

Have a look at [Concourse incomplete primer](./doc/concourse-primer.md).

# Known issues

* The scheduling of Concourse 7.x is slow, it takes 5-10 seconds to decide what to do next. There are various open tickets about this behavior.

# History and credits

This project builds upon what I learned in my previous approach, VM-based: [concourse-ci-formula](https://github.com/marco-m/concourse-ci-formula).

This project is just an humble collection of great open source software.

# License

[MIT](LICENSE).


[concourse]: https://concourse-ci.org/
[concourse credential management]: https://concourse-ci.org/creds.html
[concourse-s3-resource]: https://github.com/concourse/s3-resource/
[minio]: https://min.io/
[mc documentation]: https://docs.min.io/minio/baremetal/reference/minio-cli/minio-mc.html
[HashiCorp Vault]: https://www.hashicorp.com/products/vault
[vault download]: https://www.vaultproject.io/downloads
[PostgreSQL]: https://www.postgresql.org/
