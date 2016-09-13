.PHONY: all install install-dependencies install-tools test test-throughout test-verbose

export ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(ARGS):;@:) # turn arguments into do-nothing targets
export ARGS

DOCKER_BUILD_FLAGS := --rm
ifeq ($(NOCACHE),true)
DOCKER_BUILD_FLAGS += --no-cache
endif

all: install test

install:
	CGO_LDFLAGS="-L`llvm-config --libdir`" go install ./...
install-dependencies:
	go get -u github.com/stretchr/testify/...
install-tools:

test:
	CGO_LDFLAGS="-L`llvm-config --libdir`" go test -timeout 60s -race ./...
test-throughout:
	$(ROOT_DIR)/scripts/test-throughout.sh
test-verbose:
	CGO_LDFLAGS="-L`llvm-config --libdir`" go test -timeout 60s -race -v ./...

docker-build:
	docker build $(DOCKER_BUILD_FLAGS) -f docker/Dockerfile -t goclang/v$(LLVM_VERSION) --build-arg LLVM_VERSION=$(LLVM_VERSION) .
docker-test:
	docker run -it --rm -w /go/src/github.com/go-clang/v$(LLVM_VERSION) -v $(shell pwd):/go/src/github.com/go-clang/v$(LLVM_VERSION) goclang/v$(LLVM_VERSION) make ci

ci:
	llvm-config --version
	llvm-config --includedir
	llvm-config --libdir
	clang --version
	make install-dependencies
	make install-tools
	make install
	make test-throughout
