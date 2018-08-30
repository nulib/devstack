# devstack
A dockerized development stack for the Northwestern University Library Repository Development & Administration Team

## Setup

```bash
$ git clone git@github.com:nulib/devstack.git
$ cd devstack
# the next command might require sudo depending on your homebrew setup
$ ln -s $(pwd)/bin/devstack /usr/local/bin/devstack
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

* `devstack up [-d] [SERVICE|APPLICATION...]`: Bring up all requested services (default: all services).
  `-d` will run everything in the background.
* `devstack logs [-f] [SERVICE|APPLICATION...]`: Show the container logs for the specified services (default:
  all running services). `-f` behaves the way it does for the `tail` command.
* `devstack down [-v]`: Bring down the stack. Adding `-v` will destroy the stack's persistent data volumes as
  well, resulting in a clean slate on the next `up`.
* `devstack ps`: View the current state of running containers
* `devstack update`: Upgrade to the latest revision of `devstack`

### Tips and Tricks

* Setting the `COMPOSE_PROJECT_NAME` environment variable will change the prefix `docker-compose` uses when
  creating containers and volumes, allowing you to create a temporary stack without interfering with your
  main stack. This can be useful for one-off debugging.

## Known Issues

* Application names will always expand to the list of their dependent services. So `devstack up donut glaze`
  followed by `devstack stop glaze` will stop all of Glaze's dependencies, even those DONUT might still need.
