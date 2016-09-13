# goclang/base
#  Ubuntu xenial based docker container with Go runtime.
#  goclang/base inheritance container will install the libclang of $LLVM_VERSION environment variable.
#
# build-arg
# usage: --build-arg KEY=VALUE
#  APT_MIRROR: if 1, use region based mirror url that fast fetching apt-packages for non US users.
#  GOLANG_VERSION: version of Go runtime.
#  GOLANG_DOWNLOAD_SHA256: sha256 for tarball of Go pre-compile binary.

FROM ubuntu:xenial
MAINTAINER go-clang-devs@github.com/go-clang

ARG APT_MIRROR
ARG GOLANG_VERSION
ARG GOLANG_DOWNLOAD_SHA256

ENV GOLANG_VERSION=${GOLANG_VERSION:-1.7.1} \
	GOLANG_DOWNLOAD_SHA256=${GOLANG_DOWNLOAD_SHA256:-43ad621c9b014cde8db17393dc108378d37bc853aa351a6c74bf6432c1bbd182} \
	GOPATH=/go \
	PATH=/go/bin:/usr/local/go/bin:$PATH \
	CC=clang \
	CXX=clang++

# install packages for git, fetch the Go pre-compile binary and make based unit test
RUN set -ex \
	&& if [ "$APT_MIRROR" = "1" ]; then sed -i 's/http:\/\/archive.ubuntu.com\/ubuntu\//mirror:\/\/mirrors.ubuntu.com\/mirrors.txt/g' /etc/apt/sources.list; fi \
	&& sed -i 's/deb-src/# deb-src/g' /etc/apt/sources.list \
	\
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		bc \
		ca-certificates \
		curl \
		git \
		make \
	&& rm -rf /var/lib/apt/lists/* \
	\
	&& export GOROOT_BOOTSTRAP="/usr/local/go$GOLANG_BOOTSTRAP_VERSION" \
	&& curl -fsSL "https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz" -o golang.tar.gz \
	&& echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
	&& tar -C /usr/local -xzf golang.tar.gz \
	&& rm golang.tar.gz \
	\
	&& go version \
	&& go env \
	\
	&& mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

# automatically setup the LLVM compiler toolchain use ONBUILD
#  TODO(sbinet): remove `ln -s ...`. see go-clang/design#3 go-clang/gen#102
ONBUILD ARG LLVM_VERSION
ONBUILD ENV LLVM_VERSION=${LLVM_VERSION:-3.9}
ONBUILD RUN set -ex \
	&& if [ "$LLVM_VERSION" = "4.0" ]; then echo "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial main" >> /etc/apt/sources.list; \
		else echo "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-$LLVM_VERSION main" >> /etc/apt/sources.list; fi \
	&& curl http://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
	\
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		clang-$LLVM_VERSION \
		libclang-$LLVM_VERSION-dev \
		libclang-common-$LLVM_VERSION-dev \
		libclang1-$LLVM_VERSION \
		llvm-$LLVM_VERSION \
		llvm-$LLVM_VERSION-dev \
		llvm-$LLVM_VERSION-runtime \
	&& rm -rf /var/lib/apt/lists/* \
	\
	&& ln -s /usr/bin/clang-$LLVM_VERSION /usr/bin/clang \
	&& ln -s /usr/bin/clang++-$LLVM_VERSION /usr/bin/clang++ \
	&& ln -s /usr/bin/llvm-config-$LLVM_VERSION /usr/bin/llvm-config \
	&& ln -s /usr/lib/x86_64-linux-gnu/libclang-$LLVM_VERSION.so /usr/lib/x86_64-linux-gnu/libclang.so
