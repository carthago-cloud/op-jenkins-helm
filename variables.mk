SHELL := /bin/bash
PATH  := $(GOPATH)/bin:$(PATH)

OSFLAG 				:=
ifeq ($(OS),Windows_NT)
	OSFLAG = WIN32
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		OSFLAG = LINUX
	endif
	ifeq ($(UNAME_S),Darwin)
		OSFLAG = OSX
	endif
endif

PROJECT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
PLATFORM = $(shell echo $(UNAME_S) | tr A-Z a-z)
VERSION := $(shell cat VERSION.txt)
HELM_VERSION=3.6.3
APP_VERSION := $(shell cat APP_VERSION.txt)
OLD_APP_VERSION := $(shell cat APP_VERSION.txt)

MINIKUBE_VERSION=1.21.0
MINIKUBE_KUBERNETES_VERSION=v1.21.0
CLUSTER_DOMAIN=cluster.local

DOCKER_ORGANIZATION=carthago.azurecr.io
DOCKER_REGISTRY=carthago-op-jenkins