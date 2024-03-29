# devstack
A dockerized development stack for the Northwestern University Library Repository Development & Administration Team

## Setup

```bash
$ git clone git@github.com:nulib/devstack.git
$ cd devstack
# the next command might require sudo depending on your homebrew setup
$ bin/devstack link
```

Add the following line to your `~/.bashrc` or `~/.zshrc` file:
```
source $(devstack utils)
```

## Use

The `devstack` command is a thin wrapper around [`docker-compose`](https://docs.docker.com/compose/reference/), and accepts
all of the same subcommands, parameters, and arguments, with a few notable enhancements:

* The `update` command will update the devstack command and configs in place.
* `docker-compose` commands that accept service names as arguments can also accept application names
  (`arch`, `avalon`, `donut`, and/or `glaze`) that will be expanded to the list of services those
  applications depend on. For example, `devstack up donut glaze` will bring up all services required
  to run both DONUT and Glaze.

### Cheat Sheet

#### `devstack` Commands

* `devstack -t [rest-of-command]` will run `devstack` in test mode. That means:
  * All services run on test ports instead of dev ports (e.g., `solr` on `8985` instead of `8983`)
  * The `COMPOSE_PROJECT_NAME` will have `_test` appended (e.g., the default container names will be 
    `devstack_test_*` instead of `devstack_*`)
  * The stack will clean itself up (delete all volumes and persistent data) when it spins down.
* `devstack up [-d] [SERVICE|APPLICATION...]`: Bring up all requested services (default: all services).
  `-d` will run everything in the background.
* `devstack logs [-f] [SERVICE|APPLICATION...]`: Show the container logs for the specified services (default:
  all running services). `-f` behaves the way it does for the `tail` command.
* `devstack down [-v]`: Bring down the stack. Adding `-v` will destroy the stack's persistent data volumes as
  well, resulting in a clean slate on the next `up`.
* `devstack provision [APPLICATION]`: Use terraform to provision `localstack` for the specified application.
* `devstack ps`: View the current state of running containers
* `devstack update`: Upgrade to the latest revision of `devstack`
* `devstack branch [BRANCH]`: Switch devstack to `BRANCH` (for development and testing). If `BRANCH` is not 
  specified, list existing branches.
* `source $(devstack utils)`: Install additional devstack utility functions in the current shell

#### Other Utilities and Functions

##### Tool Management

* `asdf-install-plugins`: Install all plugins needed for the current working directory's application 
  environment
* `asdf-install-npm`: Install the correct `npm` version for the current working directory's application
  environment

##### Remote Service Access

* `es-proxy`: Run an Elasticsearch proxy to access the staging or production index, as well as a Kibana front-end
* `ecr-login`: Log into the AWS-hosted Docker repository (Elastic Container Repository) using profile credentials
* `ecr-push [IMAGE] [NAME]`: Push a local Docker image to the ECR repository as `NAME`
* `ecs-exec [SERVICE]`: Attach to a running AWS service container. Valid values for `SERVICE` are:
  * `arch-webapp`
  * `arch-worker`
  * `avr-weball`
  * `avr-worker`
  * `fcrepo`
  * `meadow`
  * `solr`
  * `zookeeper`

##### Convenience Scripts

* `awslocal`: Command wrapper to run `aws` CLI commands against the running localstack container
* `tfselect [ENVIRONMENT]`: Set `AWS_PROFILE`, log in, and switch the current Terraform
  workspace to `ENVIRONMENT`.

### Tips and Tricks

* Setting the `COMPOSE_PROJECT_NAME` environment variable will change the prefix `docker-compose` uses when
  creating containers and volumes, allowing you to create a temporary stack without interfering with your
  main stack. This can be useful for one-off debugging.
* It’s a good idea to run `docker system prune` once in a while to get rid of stopped containers, dangling
  images, and unused networks & volumes. If you run it while the stack is up, it won’t remove your current
  set of data volumes (because they'll be in use).

## Known Issues

* Application names will always expand to the list of their dependent services. So `devstack up donut glaze`
  followed by `devstack stop glaze` will stop all of Glaze's dependencies, even those DONUT might still need.
