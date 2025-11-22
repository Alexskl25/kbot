# How to build:
# make build PLATFORM=TARGETOS/TARGETARCH -> make build PLATFORM=linux/arm64
# https://go.dev/doc/install/source#environment
# OR
# Use short aliases as:
# make linux; make linux-arm64; make windows; make macos; make macos-arm64

# hardcoded defaults entries
APP_NAME=kbot
BUILD_DIR=build
REGISTRY=ghcr.io/alexskl25# customize you container registry

# Define APP + Version
APP=$(shell basename $(shell git remote get-url origin))
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)

# Define platform for Docker
DOCKER_PLATFORM=$(shell docker info --format '{{.OSType}}/{{.Architecture}}')
TARGETOS=$(word 1, $(subst /, ,$(DOCKER_PLATFORM)))
TARGETARCH=$(word 2, $(subst /, ,$(DOCKER_PLATFORM)))

# Maping Docker arch to Go arch according to https://go.dev/doc/install/source#environment
ifeq ($(TARGETARCH),x86_64)
  TARGETARCH=amd64
endif
ifeq ($(TARGETARCH),aarch64)
  TARGETARCH=arm64
endif

# Write GO type platfomr to PLATFORM
PLATFORM=$(TARGETOS)/$(TARGETARCH)

# <IMAGE_TAG>
IMAGE_TAG = $(REGISTRY)/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH)

.PHONY: build clean

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
	@echo "DOCKER type PLATFORM is: $(DOCKER_PLATFORM)"
	@echo "GO type PLATFORM: $(PLATFORM) -> $(HOSTOS)/$(HOSTARCH)"
	$(MAKE) build PLATFORM=$(HOSTOS)/$(HOSTARCH)
	docker build --platform=$(PLATFORM) -t $(IMAGE_TAG) .
	@echo "IMAGE BUILT: $(IMAGE_TAG)"

push:
	@echo "Pushing image to $(REGISTRY)..."
	docker push $(IMAGE_TAG)

clean:
	@echo "Removing $(BUILD_DIR)..."
	rm -rf $(BUILD_DIR)
	@echo "Removing image $(IMAGE_TAG)..."
	- docker rmi $(IMAGE_TAG)
	@echo "All files have been removed"