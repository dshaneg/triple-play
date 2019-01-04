.PHONY: build publish play run \
		dbuild-build dbuild-release \
		ensure-logs clean deep-clean set-executable

mount-def = type=bind,source=${PWD}/build_logs,target=//app/build_logs
image-name = double-tap

# execute the build step in the build container
build: dbuild-build dbuild-release
	docker run \
		--rm \
		--mount $(mount-def) \
		$(image-name):build \
		auto/build.sh

# publishes the build and release images to the registry via the publish.sh script
# executes the publish script from the host--where the containers were built!
# no dependencies--assumes build rule has been run but doesn't force it
publish:
	auto/publish.sh

# enter a bash shell in the build container
play: dbuild-build
	docker run \
		--rm \
		-it \
		--entrypoint //bin/bash \
		--mount $(mount-def) \
		$(image-name):build

# execute the release container locally
run: dbuild-release
	docker run \
		--rm \
		--sig-proxy=true \
		--publish 80:80 \
		--mount type=bind,source=${PWD}/configurations/local.json,target=//app/config/config.json \
		$(image-name)

# build the docker images

dbuild-build: ensure-logs set-executable
	docker build \
		--target build \
		-t $(image-name):build \
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

deep-clean: clean
	rm -rf node_modules

set-executable:
	chmod 755 ./auto/*.sh


