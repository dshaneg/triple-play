# ----------------------------------------------------------------------------------------------------------
# -- Base Node
# ----------------------------------------------------------------------------------------------------------
FROM node:10.15.0-jessie AS base

# install helm

# This section (and the kube install later) was lifted from https://hub.docker.com/r/dtzar/helm-kubectl/dockerfile
# helm is needed for the linting step in the build image

# Note: Latest version of helm may be found at:
# https://github.com/kubernetes/helm/releases
ENV HELM_VERSION="v2.12.1"

RUN wget -q https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
  && chmod +x /usr/local/bin/helm

RUN helm init --client-only

# Create app directory
WORKDIR /app

# ----------------------------------------------------------------------------------------------------------
# -- Dependencies
# ----------------------------------------------------------------------------------------------------------
FROM base AS dependencies

# A wildcard is used to ensure both package.json AND package-lock.json are copied
COPY package*.json ./

RUN npm install

# ----------------------------------------------------------------------------------------------------------
# -- Build (we build this one as a target, but don't publish it)
# ----------------------------------------------------------------------------------------------------------
FROM dependencies AS build

ARG APP_VERSION

# this image won't be run, but we'll create a container from it and copy out the build_logs directory
RUN mkdir build_logs

COPY .eslintrc.yaml ./
COPY chart chart/
COPY abin abin/
COPY config config/
COPY src src/

RUN ./abin/build.sh

ENTRYPOINT ["bash"]

# ----------------------------------------------------------------------------------------------------------
# -- Deploy (we'll publish this one)
# ----------------------------------------------------------------------------------------------------------
# contains the deploy script and the helm chart package
# used to deploy in any environment
FROM alpine:3.8 as deploy

RUN apk add --no-cache ca-certificates bash jq

# Note: Latest version of kubectl may be found at:
# https://aur.archlinux.org/packages/kubectl-bin/
ENV KUBE_VERSION="v1.13.1"

# kube config file needs to be mounted to /root/.kube
RUN wget -q https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl \
  && chmod +x /usr/local/bin/kubectl

# Create app directory
WORKDIR /app

COPY --from=build /usr/local/bin/helm /usr/local/bin/helm
COPY --from=build /root/.helm /root/.helm/
COPY --from=build /app/abin abin/
COPY --from=build /app/config config/
COPY --from=build /app/*.tgz ./

# Be sure to set required environment variables (they default to local developer values)
# - APP_VERSION: set to the tag name of the application image you want to deploy
# - STAGE: set to the proper stage name--drives which configuration file overides you get. See ./config directory (e.g. cert, prod, etc.)
CMD ["./abin/deploy.sh"]

# ----------------------------------------------------------------------------------------------------------
# -- Test (we'll publish this one)
# ----------------------------------------------------------------------------------------------------------
FROM node:10.15.0-alpine AS test

RUN apk add --no-cache ca-certificates bash jq

# Create app directory
WORKDIR /app

# dev dependencies for test tooling.
# what if we had a separate package.json just for the tests? Woudldn't need the production dependencies in the image...
# but that would cause us to have to npm install twice--though the dependencies should be cached after the first pull
COPY --from=build /app/node_modules ./node_modules/
COPY --from=build /app/abin/tests abin/tests
COPY --from=build /app/src/tests ./src/tests/

# Be sure to set required environment variables (they default to local developer values)
# - APP_VERSION: set to the tag name of the application image you want to deploy
# - STAGE: set to the proper stage name--drives which configuration file overides you get. See ./config directory (e.g. cert, prod, etc.)
CMD [ "bash" ]

# ----------------------------------------------------------------------------------------------------------
# -- Prerelease
# ----------------------------------------------------------------------------------------------------------
FROM build as prerelease

# don't want to prune the build image, because I need to run tests in it.
# don't want to prune the release image, since alpine is missing some tools to do it with
RUN npm prune --production

# ----------------------------------------------------------------------------------------------------------
# -- Release (we'll publish this one)
# ----------------------------------------------------------------------------------------------------------
FROM node:10.15.0-alpine AS release

# Create app directory
WORKDIR /app

# production dependencies
COPY --from=prerelease /app/package.json ./
COPY --from=prerelease /app/node_modules ./node_modules/
COPY --from=prerelease /app/src ./src/

# exposes a port (default 80) but it is configurable

ENTRYPOINT [ "node", "src/app/index.js" ]
