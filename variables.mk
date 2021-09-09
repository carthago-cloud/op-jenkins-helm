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
HELM_VERSION=3.6.3
CHART_VERSION=0.1.0
APP_VERSION=0.8.1