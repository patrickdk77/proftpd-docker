.PHONY: buildx rm stop build run env_run logs curl_list curl_put

SHORT_SHA1 := $(shell git rev-parse --short HEAD)
TAG := $(shell git describe --tags --abbrev=0)
ORIGIN := $(shell git remote get-url origin)
NAME = proftpd
PUBLIC_REPO := patrickdk/proftpd-docker
DOCKER_REPO := docker.patrickdk.com/dswett/$(NAME)
SOURCE_COMMIT_SHORT := $(SHORT_SHA1)
BUILD_DATE = $(shell date -u +'%Y-%m-%dT%H:%M:%Sz')

PROFTPD_VERSION := v1.3.9
VROOT_VERSION   := v0.9.12

all: buildx

build:
	docker build -t proftpd .

buildx:
	docker buildx build --pull --platform linux/amd64,linux/arm64 --build-arg "BUILD_DATE=$(BUILD_DATE)" --build-arg "BUILD_VERSION=$(TAG)" --build-arg "BUILD_REF=$(SOURCE_COMMIT_SHORT)" --build-arg "BUILD_ORIGIN=$(ORIGIN)" --build-arg "PROFTPD_VERSION=$(PROFTPD_VERSION)" --build-arg "VROOT_VERSION=$(VROOT_VERSION)" --push -f Dockerfile -t $(DOCKER_REPO):$(TAG) .
	docker buildx build --pull --platform linux/amd64,linux/arm64 --build-arg "BUILD_DATE=$(BUILD_DATE)" --build-arg "BUILD_VERSION=$(TAG)" --build-arg "BUILD_REF=$(SOURCE_COMMIT_SHORT)" --build-arg "BUILD_ORIGIN=$(ORIGIN)" --build-arg "PROFTPD_VERSION=$(PROFTPD_VERSION)" --build-arg "VROOT_VERSION=$(VROOT_VERSION)" --push -f Dockerfile -t $(DOCKER_REPO):latest .
	docker buildx build --pull --platform linux/amd64,linux/arm64 --build-arg "BUILD_DATE=$(BUILD_DATE)" --build-arg "BUILD_VERSION=$(TAG)" --build-arg "BUILD_REF=$(SOURCE_COMMIT_SHORT)" --build-arg "BUILD_ORIGIN=$(ORIGIN)" --build-arg "PROFTPD_VERSION=$(PROFTPD_VERSION)" --build-arg "VROOT_VERSION=$(VROOT_VERSION)" --push -f Dockerfile -t $(PUBLIC_REPO):$(TAG) .
	docker buildx build --pull --platform linux/amd64,linux/arm64 --build-arg "BUILD_DATE=$(BUILD_DATE)" --build-arg "BUILD_VERSION=$(TAG)" --build-arg "BUILD_REF=$(SOURCE_COMMIT_SHORT)" --build-arg "BUILD_ORIGIN=$(ORIGIN)" --build-arg "PROFTPD_VERSION=$(PROFTPD_VERSION)" --build-arg "VROOT_VERSION=$(VROOT_VERSION)" --push -f Dockerfile -t $(PUBLIC_REPO):latest .
	docker buildx build --pull --platform linux/amd64,linux/arm64 --build-arg "BUILD_DATE=$(BUILD_DATE)" --build-arg "BUILD_VERSION=$(TAG)" --build-arg "BUILD_REF=$(SOURCE_COMMIT_SHORT)" --build-arg "BUILD_ORIGIN=$(ORIGIN)" --build-arg "PROFTPD_VERSION=$(PROFTPD_VERSION)" --build-arg "VROOT_VERSION=$(VROOT_VERSION)" --push -f Dockerfile.alpine -t $(DOCKER_REPO):alpine-$(TAG) .
	docker buildx build --pull --platform linux/amd64,linux/arm64 --build-arg "BUILD_DATE=$(BUILD_DATE)" --build-arg "BUILD_VERSION=$(TAG)" --build-arg "BUILD_REF=$(SOURCE_COMMIT_SHORT)" --build-arg "BUILD_ORIGIN=$(ORIGIN)" --build-arg "PROFTPD_VERSION=$(PROFTPD_VERSION)" --build-arg "VROOT_VERSION=$(VROOT_VERSION)" --push -f Dockerfile.alpine -t $(DOCKER_REPO):alpine .
	docker buildx build --pull --platform linux/amd64,linux/arm64 --build-arg "BUILD_DATE=$(BUILD_DATE)" --build-arg "BUILD_VERSION=$(TAG)" --build-arg "BUILD_REF=$(SOURCE_COMMIT_SHORT)" --build-arg "BUILD_ORIGIN=$(ORIGIN)" --build-arg "PROFTPD_VERSION=$(PROFTPD_VERSION)" --build-arg "VROOT_VERSION=$(VROOT_VERSION)" --push -f Dockerfile.alpine -t $(PUBLIC_REPO):alpine-$(TAG) .
	docker buildx build --pull --platform linux/amd64,linux/arm64 --build-arg "BUILD_DATE=$(BUILD_DATE)" --build-arg "BUILD_VERSION=$(TAG)" --build-arg "BUILD_REF=$(SOURCE_COMMIT_SHORT)" --build-arg "BUILD_ORIGIN=$(ORIGIN)" --build-arg "PROFTPD_VERSION=$(PROFTPD_VERSION)" --build-arg "VROOT_VERSION=$(VROOT_VERSION)" --push -f Dockerfile.alpine -t $(PUBLIC_REPO):alpine .

stop:
	docker stop proftpd

rm:
	docker rm proftpd

run:
	docker run --name proftpd --net=host \
		-e FTP_DB_HOST=$$FTP_DB_HOST -e FTP_DB_NAME=$$FTP_DB_NAME -e FTP_DB_USER=$$FTP_DB_USER -e FTP_DB_PASS=$$FTP_DB_PASS \
		-e MASQ_ADDR=$$MASQ_ADDR \
		-v $$FTP_ROOT:/srv/ftp \
		-v $$LOGS:/var/log/proftpd \
		-v $$(pwd)/.salt:/etc/proftpd/.salt \
		-e MOD_TLS=ON \
		-v $$(pwd)/tls.conf:/etc/proftpd/tls.conf \
		-v $$(pwd)/certs:/etc/proftpd/certs \
		-e MOD_EXEC=ON \
		-v $$(pwd)/exec:/etc/proftpd/exec \
		-e MOD_VROOT=ON \
		-v $$(pwd)/.vroot.conf:/etc/proftpd/vroot.conf \
		-d proftpd

env_run:
	(export $$(cat .env | grep -v ^\# | xargs) && make run)

logs:
	docker logs proftpd

curl_list:
	curl -v --ssl --insecure --disable-epsv ftp://my-ftp-server.com:21 -u user:pwd

curl_put:
	curl -v -T </path/to/file> --ssl --insecure --disable-epsv ftp://my-ftp-server.com:21 -u user:pwd
