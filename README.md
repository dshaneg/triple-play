# double tap

Proof of concept for creating a "workspace" container to be published along with the application's main container.

The workspace container can be used to run deploy and test scripts against the main container.

## Notes

* chart version doesn't matter since it is deployed with the build container. don't even have to publish it
* is there a better way to include files dynamically in configmap? This way forced me to add a top level container entry in each file
* still need to helm install/upgrade from the build image. Will require installing kubectl and helm in the image. Also will need creds to publish
* deploy using `helm upgrade -f config/${ENV}.json {release-name} chart/double-tap
* need to figure out how to define the release name instead of getting the random one

## Building the application

```sh
make build
```

## Publishing the docker images

On a build server, you need to make sure the environment varialbe `STAGE` is set to a value that matches one of the filenames in the config folder, excluding the suffix: (e.g. cert, local, prod). When running the build locally, the build will use version 0.0.0.

```sh
make publish
```

## Deploying the application

TODO: Not yet working from the workspace container. Have to run it locally.

```sh
make deploy
```