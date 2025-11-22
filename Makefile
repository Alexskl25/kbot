# How to build:
# make build PLATFORM=TARGETOS/TARGETARCH -> make build PLATFORM=linux/arm64
# https://go.dev/doc/install/source#environment
# OR
# Use short aliases as:
# make linux; make linux-arm64; make windows; make macos; make macos-arm64

#hardcoded defaults entries
APP_NAME=kbot
BUILD_DIR=build
REGISTRY=alexskl25
TARGETOS=linux #default entries for OS
TARGETARCH=amd64 #default entries for ARCH

# Aliases for short targets with platforms
linux:
	$(MAKE) build PLATFORM=linux/amd64
linux-arm64:
	$(MAKE) build PLATFORM=linux/arm64
windows:
	$(MAKE) build PLATFORM=windows/amd64
macos:
	$(MAKE) build PLATFORM=darwin/amd64
macos-arm64:
	$(MAKE) build PLATFORM=darwin/arm64

# Define APP + Version
APP=$(shell basename $(shell git remote get-url origin))
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
# <IMAGE_TAG>
IMAGE_TAG=$(REGISTRY)/$(APP_NAME):$(VERSION)

.PHONY: build clean

deps:
	go mod tidy
	go mod download

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

build:
# Split PLATFORM into OS and ARCH
	@if [ -z "$(PLATFORM)" ]; then echo "PLATFORM not set"; exit 1; fi
	$(eval TARGETOS := $(word 1, $(subst /, ,$(PLATFORM))))
	$(eval TARGETARCH := $(word 2, $(subst /, ,$(PLATFORM))))
	@mkdir -p $(BUILD_DIR)
	@echo "Building $(TARGETOS)/$(TARGETARCH)..."
	$(if $(filter $(TARGETOS),windows),$(eval APP_NAME := $(APP_NAME).exe))
	@echo "TARGET: $(TARGETOS)/$(TARGETARCH), APP_NAME=$(APP_NAME)"
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o $(BUILD_DIR)/$(APP_NAME) -ldflags "-X="github.com/Alexskl25/kbot/cmd.appVersion=${VERSION}

# IMAGE: build for host OS/ARCH on which build started
image:
	@echo "Detecting host Docker platform..."
	$(eval DOCKER_PLATFORM := $(shell docker info --format '{{.OSType}}/{{.Architecture}}'))
	$(eval HOSTOS := $(word 1, $(subst /, ,$(DOCKER_PLATFORM))))
	$(eval HOSTARCH := $(word 2, $(subst /, ,$(DOCKER_PLATFORM))))
	$(if $(filter $(HOSTARCH),x86_64),$(eval HOSTARCH := amd64))
	$(if $(filter $(HOSTARCH),aarch64),$(eval HOSTARCH := arm64))
	@echo "HOST PLATFORM: $(DOCKER_PLATFORM) -> $(HOSTOS)/$(HOSTARCH)"
	$(MAKE) build PLATFORM=$(HOSTOS)/$(HOSTARCH)
	docker build --platform=$(DOCKER_PLATFORM) -t $(IMAGE_TAG) .
	@echo "IMAGE BUILT: $(IMAGE_TAG)"

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-$(PLATFORM)

clean:
	@echo "Removing $(BUILD_DIR)..."
	rm -rf $(BUILD_DIR)
	@echo "Removing image $(IMAGE_TAG)..."
	- docker rmi $(IMAGE_TAG)
	@echo "All files have been removed"