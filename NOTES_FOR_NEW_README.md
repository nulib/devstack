# DevStack v2.0

`devstack` v2.0 is designed to be more modular and flexible than v1.x. It uses discrete service files that are combined into stacks on the fly.

## Services, Stacks, and Environments

### Services

A _service_ is a single `docker-compose` service specification with some extra configuration sprinkled in. Services are combined at runtime into `stacks`.

`devstack` services don't forward ports; they forward _base ports_ which are then _offset_ by whatever value is specified by the _environment_. For example, if the `postgres` service (with a base port of 5432) is run in the `dev` environment (with a port offset of 1), the server will be accessible from the host on port 5433.

Services can also define variables and environment settings that can be overridden by the stack configuration, and they can even include files to be mounted into the service container at runtime.

See the `services` directory off the root of the `devstack` installation for examples. (`services/pgadmin.yml` includes examples of both service-defined variables and mounted files.)

To see a list of known, pre-installed services, run

```
devstack --list services
```

### Environment

The _environment_ defines certain characteristics of the stack to be run. These include:

* The name of the environment (e.g., `dev`, `test`)
* The mapped port offset applied to the services within the stack
* Whether the volumes created by the stack will be automatically destroyed on `devstack down`

The environment can be specified 4 different ways. In order of precedence:

* Switch:

  ```
  $ devstack -e test up
  ```

* Shorthand switch for test environment:

  ```
  $ devstack -t up
  ```

* `.devstack` file in current or any parent directory:

  ```
  $ cat .devstack
  ---
  environment: test

  $ devstack up
  ```

* Environment variable:

  ```
  $ DEVSTACK_ENV=test
  $ devstack up
  ```

See the `environments` directory off the root of the `devstack` installation for examples.

To see a list of known, pre-installed environments, run

```
devstack --list environments
```

### Stack

The _stack_ is the list of services and configurations that make up the runtime environment.

The stack can be specified 4 different ways. In order of precedence:

* The first non-switch command line argument after the `docker-compose` subcommand:

  ```
  $ devstack up -d my_stack
  ```

* Switch:

  ```
  $ devstack -s my_stack up
  ```

* `.devstack` file in current or any parent directory:

  ```
  $ cat .devstack
  ---
  stack: my_stack

  $ devstack up
  ```

* Environment variable:

  ```
  $ DEVSTACK_STACK=my_stack
  $ devstack up
  ```

There is a special stack called `_all` that simply contains a list of all known services. The `_all` stack is used by default if no other stack is specified.

See the `stacks` directory off the root of the `devstack` installation for examples.

To see a list of known, pre-installed stacks, run

```
devstack --list stacks
```

## `.devstack` file

When `devstack` is run, it will look for a file called `.devstack` in the current directory or any of its parents, and use it to set the default environment and stack. The file is simply a YAML file with two top-level keys:

```
---
environment: dev
stack: my_stack
```

With this `.devstack` file, running `devstack up` will bring up the `my_stack` services using the `dev` environment.

`devstack -t up` or `devstack -e test up` will bring up the same services in the `test` environment (i.e., keeping the `stack` value from the file and overriding the environment on the command line).

`.devstack` files aren't cumulative – that is, given the structure:

```
dir1
├── .devstack
└── dir2
    ├── .devstack
    └── dir3
```

If `dir3` is the current directory, `devstack` will use the config file in `dir2` and never even look at the one in `dir1`.

## Other Details

In addition to pre-installed services, stacks, and environments, `devstack` will attempt to load any file path or URL for any of them, e.g.:

```
devstack \
  -e /path/to/staging_environment.yml \
  -s http://stacks.example.edu/custom.yml \
  up -d
```
