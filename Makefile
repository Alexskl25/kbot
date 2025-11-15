#hardcoded defaults entries
APP_NAME=kbot
BUILD_DIR=build
REGISTRY=alexskl25
TARGETOS=linux #default entries for OS
TARGETARCH=amd64 #default entries for ARCH

APP=$(shell basename $(shell git remote get-url origin))
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)

# Set EXT based on TARGETOS
#ifeq ($(TARGETOS),windows)
#APP_NAME:=$(APP_NAME).exe
#echo "APP_NAME $(APP_NAME)..."
#endif

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

image:
	docker build --platform $(PLATFORM) -t ${REGISTRY}/${APP}:${VERSION}-$(PLATFORM) .

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-$(PLATFORM)

clean:
	rm -rf $(BUILD_DIR)