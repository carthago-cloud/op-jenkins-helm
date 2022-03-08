include variables.mk

.PHONY: helm-install
HAS_HELM := $(shell which $(PROJECT_DIR)/bin/helm)
helm-install: ## Download helm if it's not present
	@echo "+ $@"
ifndef HAS_HELM
	mkdir -p $(PROJECT_DIR)/bin
	curl -Lo bin/helm.tar.gz https://get.helm.sh/helm-v$(HELM_VERSION)-$(PLATFORM)-amd64.tar.gz && tar xzfv bin/helm.tar.gz -C $(PROJECT_DIR)/bin
	mv $(PROJECT_DIR)/bin/$(PLATFORM)-amd64/helm $(PROJECT_DIR)/bin/helm
	rm -rf $(PROJECT_DIR)/bin/$(PLATFORM)-amd64
	rm -rf $(PROJECT_DIR)/bin/helm.tar.gz
endif

.PHONY: helm-lint
helm-lint: helm-install
	@echo "+ $@"
	bin/helm lint charts/carthago-op-jenkins
	bin/helm lint charts/carthago-op-jenkins-crs

.PHONY: sembump
HAS_SEMBUMP := $(shell which $(PROJECT_DIR)/bin/sembump)
sembump: ## Download sembump locally if necessary
	@echo "+ $@"
ifndef HAS_SEMBUMP
	@mkdir -p bin
	wget -O $(PROJECT_DIR)/bin/sembump https://github.com/justintout/sembump/releases/download/v0.1.0/sembump-$(PLATFORM)-amd64
	chmod +x $(PROJECT_DIR)/bin/sembump
endif

.PHONY: bump-version
BUMP := patch
bump-version: sembump ## Bump the version in the version file. Set BUMP to [ patch | major | minor ]
	@echo "+ $@"
	$(eval NEW_VERSION=$(shell bin/sembump --kind $(BUMP) $(VERSION)))
	@echo "Bumping VERSION.txt from $(VERSION) to $(NEW_VERSION)"
	echo $(NEW_VERSION) > VERSION.txt
	@echo "Updating version from $(VERSION) to $(NEW_VERSION) in README.md"
	perl -i -pe 's/$(VERSION)/$(NEW_VERSION)/g' README.md

.PHONE: change-chart-version
change-chart-version: bump-version
	@echo "+ $@"
	$(eval VERSION=$(shell cat VERSION.txt))
	sed -i "/version:/c\version: $(VERSION)" charts/carthago-op-jenkins/Chart.yaml
	@if [ $(APP_VERSION) != $(OLD_APP_VERSION) ] ; then \
		sed -i "/appVersion:/c\appVersion: \"$(APP_VERSION)\"" charts/carthago-op-jenkins/Chart.yaml ;\
	fi

	sed -i "/version:/c\version: $(VERSION)" charts/carthago-op-jenkins-crs/Chart.yaml
	@if [ $(APP_VERSION) != $(OLD_APP_VERSION) ] ; then \
		sed -i "/appVersion:/c\appVersion: \"$(APP_VERSION)\"" charts/carthago-op-jenkins-crs/Chart.yaml ;\
		echo $(APP_VERSION) > APP_VERSION.txt ;\
	fi

.PHONY: unit-test-plugin
HELM_PLUGINS := $(PROJECT_DIR)/bin
unit-test-plugin:
	@echo "+ $@"
	bin/helm plugin install https://github.com/quintush/helm-unittest

.PHONY: unit-test
unit-test:
	@echo "+ $@"
	bin/helm unittest charts/carthago-op-jenkins-crs/ -3 --debug

.PHONY: minikube
HAS_MINIKUBE := $(shell which $(PROJECT_DIR)/bin/minikube)
minikube: ## Download minikube if it's not present
	@echo "+ $@"
ifndef HAS_MINIKUBE
	mkdir -p $(PROJECT_DIR)/bin
	wget -O $(PROJECT_DIR)/bin/minikube https://github.com/kubernetes/minikube/releases/download/v$(MINIKUBE_VERSION)/minikube-$(PLATFORM)-amd64
	chmod +x $(PROJECT_DIR)/bin/minikube
endif

.PHONY: minikube-start
minikube-start: minikube ## Start minikube
	@echo "+ $@"
	bin/minikube status && exit 0 || \
	bin/minikube start --kubernetes-version $(MINIKUBE_KUBERNETES_VERSION) --dns-domain=$(CLUSTER_DOMAIN) --extra-config=kubelet.cluster-domain=$(CLUSTER_DOMAIN) --driver=$(MINIKUBE_DRIVER) --memory $(MEMORY_AMOUNT) --cpus $(CPUS_NUMBER)
