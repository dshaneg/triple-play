# ---- Base Node ----
FROM node:10.15.0-jessie AS base

# need to install helm and kubectl
# would rather do this later in a specific deploy image,
# but to keep builds fast, need to do it early.
# It won't go into the release image either way

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

COPY .eslintrc.yaml ./
COPY abin abin/
COPY config/config.json config/config.json
COPY src src/
# If using a compile language, we would compile here

# Running the build script in the running container so we can capture the output files in the host via volume mount
CMD ["./abin/build.sh"]

# ----------------
# -- Prerelease --
# ----------------
FROM build as prerelease

# don't want to prune the build image, because I need to run tests in it.
# don't want to prune the release image, since alpine is missing some tools to do it with
RUN npm prune --production

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
