.PHONY: build publish play run \
		dbuild-build dbuild-deployer dbuild-release \
		ensure-logs clean deep-clean set-executable

# mount-def = type=bind,source=${PWD}/build_logs,target=//app/build_logs
image-name = double-tap

# execute the application build as part of building the image
# then copy the build logs from the container to the host
build: dbuild-build dbuild-deployer dbuild-release
	docker create --name double-tap-copy-logs double-tap:build
	docker cp double-tap-copy-logs:/app/build_logs .
	docker rm -v double-tap-copy-logs

# publishes the build and release images to the registry via the publish.sh script
# executes the publish script from the host--where the containers were built!
# no dependencies--assumes build rule has been run but doesn't force it
publish: set-executable
	abin/publish.sh

# enter a bash shell in the build container
# assumes build has already run--doesn't force a new one
play:
	docker run \
		--rm \
		-it \
		--entrypoint //bin/bash \
		--mount $(mount-def) \
		$(image-name):build

# eventually will execute publish script in the workspace container
deploy: set-executable
	abin/deploy.sh

# execute the release container locally
# assumes build has already run--doesn't force a new one
run:
	docker run \
		--rm \
		-d \
		--name double-tap \
		--publish 8008:80 \
		--mount type=bind,source=${PWD}/config/config.json,target=//app/config/config.json \
		$(image-name)

# kill the container started by the run rule
kill:
	docker kill double-tap

# build the docker images

dbuild-build: ensure-logs set-executable
	docker build \
		--target build \
		-t $(image-name):build \
		.

dbuild-deployer: ensure-logs set-executable
	docker build \
		--target deployer \
		-t $(image-name):deployer \
		.

dbuild-release: ensure-logs set-executable
	docker build \
		-t $(image-name) \
		.

# utility rules

ensure-logs:
	mkdir -p build_logs

clean:
	rm -rf build_logs
	rm -f double-tap-*.tgz

deep-clean: clean
	rm -rf node_modules

set-executable:
	chmod 755 ./abin/*.sh


