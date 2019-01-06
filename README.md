# double tap

Proof of concept for creating a "workspace" container to be published along with the application's main container.

The workspace container can be used to run deploy and test scripts against the main container.

## To Do

* still need to helm install/upgrade from the build image. Will require installing kubectl and helm in the image. Also will need creds to publish

## Building the application

```sh
make build
```

## Running the application locally (not in k8s)

Once built, you can run the application in the container.

```sh
make run
```

This will start the application and leave the container running in the background. You'll have to stop it before you can run it again.

```sh
make kill
```

## Publishing the docker images

On a build server, need to set environment variable APP_VERSION to a valid semantic version value. This will become the tag of the docker image as well as the version of the helm chart.

If the APP_VERSION variable is not set (as when running the build locally), the build will use version 0.0.0, and 'latest' for the docker image tag.

```sh
make publish
```

## Deploying the application

A build server should have the `APP_VERSION` environment variable set as for the Publish step.

On a build server, you need to make sure the environment variable `STAGE` is set to a value that matches one of the filenames in the config folder, excluding the suffix: (e.g. cert, local, prod).

Both variables use default values if not set, but any automation should explicitly set values for these variables--the defaults are intended for local development.

```sh
make deploy
```