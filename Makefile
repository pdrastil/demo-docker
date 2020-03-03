# Provided application
APP_NAME		:= hello-world
APP_VERSION		:= 1.0

# Dependencies
BASE_IMAGE		:= alpine:3.11
GLIBC_VERSION	:= 2.30-r0
JAVA_VERSION	:= 8u241
JAVA_BUILD		:= 07

# Image arguments
IMAGE_REPO		:= pdrastil
IMAGE_NAME		:= $(IMAGE_REPO)/$(APP_NAME)
IMAGE_TAG		:= $(IMAGE_NAME):$(APP_VERSION)

# Build arguments
BUILD_FLAGS		:= --no-cache=true --pull \
	--rm --force-rm --compress \
	-f Dockerfile \
	-t $(IMAGE_TAG) \
	--build-arg BASE_IMAGE=$(BASE_IMAGE) \
	--build-arg GLIBC_VERSION=$(GLIBC_VERSION) \
	--build-arg JAVA_VERSION=$(JAVA_VERSION) \
	--build-arg JAVA_BUILD=$(JAVA_BUILD) \
	--label io.glibc.version="${GLIBC_VERSION}" \
	--label io.jre.version="${JAVA_VERSION}-b${JAVA_BUILD}" \
	--label org.opencontainers.image.version="$(APP_VERSION)" \
	--label org.opencontainers.image.source="https://github.com/pdrastil/demo-docker.git" \
	--label org.opencontainers.image.created="$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")" \
	--label org.opencontainers.image.revision="$(shell git rev-parse --short HEAD)"

all: build

build:
	@echo "==============================================================================="
	@echo "| Building image:"
	@echo "| ${IMAGE_TAG}"
	@echo "================================= START ======================================="
	docker build $(BUILD_FLAGS) .

clean:
	docker images | awk '(NR>1) && ($$2!~/none/) {print $$1":"$$2}' | grep "$(IMAGE_NAME)" | xargs -r -n1 docker rmi
	docker container prune -f
	docker image prune -f

pull:
	docker pull $(IMAGE_TAG)

push:
	@echo "Pushing images..."
	docker push $(IMAGE_TAG)

	@echo "Updating latest tag ..."
	docker tag $(IMAGE_TAG) $(IMAGE_NAME):latest
	docker push ${IMAGE_NAME}:latest
