.PHONY: build publish play playtest deploy run kill \
		dbuild-build dbuild-deploy dbuild-test dbuild-release \
		ensure-logs clean deep-clean set-executable

image-name = double-tap

# execute the application build as part of building the image
# then copy the build logs from the container to the host
build: clean dbuild-build dbuild-deploy dbuild-test dbuild-release
	docker create --name double-tap-copy-logs double-tap:build
	docker cp double-tap-copy-logs:/app/build_logs .
	docker rm -v double-tap-copy-logs
	@echo "Build logs copied to build_logs directory."

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
		$(image-name):build

# enter a bash shell in the test container
# assumes build has already run--doesn't force a new one
playtest:
	docker run \
		--rm \
		-it \
		$(image-name):test

# execute deploy script in the deploy container
deploy: set-executable
	# would need a step to retrieve kubernetes config file from a secret store
	docker run \
		--rm \
		-it \
		-e STAGE \
		-e APP_VERSION \
		--mount type=bind,source=${HOME}/.kube,target=//root/.kube \
		double-tap:deploy

# execute the release container locally
# assumes build has already run--doesn't force a new one
run:
	docker run \
		--rm \
		-d \
		--name double-tap \
		--publish 8008:80 \
		--mount type=bind,source=${PWD}/config/config.json,target=//app/config/config.json \
		$(image-name):latest

# kill the container started by the run rule
kill:
	docker kill double-tap

# build the docker images

dbuild-build: ensure-logs set-executable
	@echo "\n***************************************************************"
	@echo "** Building (target=build) image"
	@echo "***************************************************************\n"
	docker build \
		--target build \
		--build-arg APP_VERSION \
		-t $(image-name):build \
		.

dbuild-deploy: ensure-logs set-executable
	@echo "\n***************************************************************"
	@echo "** Building (target=deploy) image"
	@echo "***************************************************************\n"
	docker build \
		--target deploy \
		--build-arg APP_VERSION \
		-t $(image-name):deploy \
		.

dbuild-test: ensure-logs set-executable
	@echo "\n***************************************************************"
	@echo "** Building (target=test) image"
	@echo "***************************************************************\n"
	docker build \
		--target test \
		--build-arg APP_VERSION \
		-t $(image-name):test \
		.

dbuild-release: ensure-logs set-executable
	@echo "\n***************************************************************"
	@echo "** Building (target=release) image"
	@echo "***************************************************************\n"
	docker build \
		--build-arg APP_VERSION \
		-t $(image-name):latest \
		.

# utility rules

ensure-logs:
	mkdir -p build_logs

clean:
	rm -rf build_logs
	rm -rf .kube
	rm -f double-tap-*.tgz

deep-clean: clean
	rm -rf node_modules

set-executable:
	chmod 755 ./abin/*.sh
