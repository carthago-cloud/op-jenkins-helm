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
CHART_VERSION=0.1.0
APP_VERSION := $(shell cat APP_VERSION.txt)
OLD_APP_VERSION := $(shell cat APP_VERSION.txt)

# this all might not be necessary
KUBERNETES_PROVIDER=minikube
MINIKUBE_VERSION=1.21.0
MINIKUBE_KUBERNETES_VERSION=v1.21.0
MINIKUBE_DRIVER=virtualbox
#KUBECTL_CONTEXT=minikube
CPUS_NUMBER = 3
MEMORY_AMOUNT = 4096
CLUSTER_DOMAIN=cluster.local