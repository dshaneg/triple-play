# ---- Base Node ----
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

# ----------------------
# ---- Dependencies ----
# ----------------------
FROM base AS dependencies

# A wildcard is used to ensure both package.json AND package-lock.json are copied
COPY package*.json ./

RUN npm install

# ---------------
# ---- Build ----
# ---------------
FROM dependencies AS build

RUN mkdir build_logs

COPY .eslintrc.yaml ./
COPY chart chart/
COPY abin abin/
COPY config/config.json config/config.json
COPY src src/

# If using a compile language, we would compile here
RUN ./abin/build.sh

# Running the build script in the running container so we can capture the output files in the host via volume mount
# CMD ["./abin/build.sh"]

# ----------------
# -- Prerelease --
# ----------------
FROM build as prerelease

# don't want to prune the build image, because I need to run tests in it.
# don't want to prune the release image, since alpine is missing some tools to do it with
RUN npm prune --production

# --------------
# -- Deployer --
# --------------
FROM alpine:3.8 as deployer

RUN apk add --no-cache ca-certificates bash

# Note: Latest version of kubectl may be found at:
# https://aur.archlinux.org/packages/kubectl-bin/
ENV KUBE_VERSION="v1.13.1"

RUN wget -q https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl \
  && chmod +x /usr/local/bin/kubectl

# Create app directory
WORKDIR /app

COPY --from=build /usr/local/bin/helm /usr/local/bin/helm
COPY --from=build /root/.helm /root/.helm/
COPY --from=build /app/abin abin/
COPY --from=build /app/*.tgz ./

CMD ["./abin/deploy.sh"]

# ----------------
# --- Release ----
# ----------------
FROM node:10.15.0-alpine AS release

# Create app directory
WORKDIR /app

# production dependencies
COPY --from=prerelease /app/node_modules ./node_modules/
COPY --from=prerelease /app/package.json ./
COPY --from=prerelease /app/src ./src/

EXPOSE 80

ENTRYPOINT [ "node", "src/index.js" ]
