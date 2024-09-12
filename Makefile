# See https://www.gnu.org/software/make/manual/make.html

SHELL = /usr/bin/env bash

# environment
PREFIX_KRB5 = $(shell echo $${PREFIX_KRB5:-krb5})
REALM_KRB5 = $(shell echo $${REALM_KRB5:-EXAMPLE.COM})
# only IPv4
NETWORK_CONTAINER = $(shell echo $${NETWORK_CONTAINER:-10.5.0.0})/24
DOMAIN_CONTAINER = $(shell echo $${DOMAIN_CONTAINER:-example.com})
OS_CONTAINER = $(shell echo $${OS_CONTAINER:-ubuntu})
SHARED_FOLDER = $(shell echo $${SHARED_FOLDER:-${{PWD}}})

TEST = ./test
SCRIPT = ./script
DEVSCRIPT = ./dev-local

# check minimal installation
ifeq ($(shell which docker),)
  $(error docker is not installed, please install it before using project)
endif

ifeq ($(shell which docker-compose),)
  $(error docker-compose is not installed, please install it before using project)
endif

# check variables coherence
ifeq ($(filter $(OS_CONTAINER), ubuntu centos),)
  $(error variable OS_CONTAINER is bad defined '$(OS_CONTAINER)', do make <option> <target> ... OS_CONTAINER=<os> possible values: ubuntu centos)
endif

.PHONY: usage
usage:
	@echo "targets include: usage pre-build build install stop start init_local_env status restart clean"

.PHONY: pre-build
pre-build:
	@$(SCRIPT)/pre-build.sh

.PHONY: build
build: pre-build
	@$(SCRIPT)/create-network.sh
	@$(SCRIPT)/build.sh

.PHONY: create
create: build
	@$(SCRIPT)/create.sh

.PHONY: init
init: start
	@$(SCRIPT)/init.sh

.PHONY: install
install: create init init_local_env

.PHONY: stop
stop:
	@$(SCRIPT)/stop.sh

.PHONY: start
start:
	@$(SCRIPT)/start.sh

.PHONY: init_local_env
init_local_env:
	@$(DEVSCRIPT)/ubuntu/init_dev_env.sh

.PHONY: status
status:
	@$(SCRIPT)/status.sh

.PHONY: restart
restart: stop start

.PHONY: clean
clean: status stop
	@$(SCRIPT)/clean.sh
