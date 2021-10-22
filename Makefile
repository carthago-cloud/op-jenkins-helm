include variables.mk

.PHONY: helm-install
HAS_HELM := $(shell which $(PROJECT_DIR)/bin/helm)
helm: ## Download helm if it's not present
	@echo "+ $@"
ifndef HAS_HELM
	mkdir -p $(PROJECT_DIR)/bin
	curl -Lo bin/helm.tar.gz https://get.helm.sh/helm-v$(HELM_VERSION)-$(PLATFORM)-amd64.tar.gz && tar xzfv bin/helm.tar.gz -C $(PROJECT_DIR)/bin
	mv $(PROJECT_DIR)/bin/$(PLATFORM)-amd64/helm $(PROJECT_DIR)/bin/helm
	rm -rf $(PROJECT_DIR)/bin/$(PLATFORM)-amd64
	rm -rf $(PROJECT_DIR)/bin/helm.tar.gz
endif

.PHONY: helm-lint
helm-lint: helm
	@echo "+ $@"
	bin/helm lint chart/op-svc-jenkins
	bin/helm lint chart/op-svc-jenkins-crs

.PHONE: change-chart-version
change-chart-version: bump-version
	@echo "+ $@"
	$(eval VERSION=$(shell cat VERSION.txt))
	sed -i "/version:/c\version: $(VERSION)" chart/op-svc-jenkins/Chart.yaml
	@if [ $(APP_VERSION) != $(OLD_APP_VERSION) ] ; then \
		sed -i "/appVersion:/c\appVersion: \"$(APP_VERSION)\"" chart/op-svc-jenkins/Chart.yaml ;\
	fi

	sed -i "/version:/c\version: $(VERSION)" chart/op-svc-jenkins-crs/Chart.yaml
	@if [ $(APP_VERSION) != $(OLD_APP_VERSION) ] ; then \
		sed -i "/appVersion:/c\appVersion: \"$(APP_VERSION)\"" chart/op-svc-jenkins-crs/Chart.yaml ;\
		echo $(APP_VERSION) > APP_VERSION.txt ;\
	fi


.PHONY: helm-package-latest
helm-package-latest:
	@echo "+ $@"
	bin/helm package chart/op-svc-jenkins
	bin/helm package chart/op-svc-jenkins-crs

.PHONY: helm-save-local
helm-save-local:
	@echo "+ $@"
	bin/helm chart save op-svc-jenkins-$(VERSION).tgz operatorservice.azurecr.io/helm/op-svc-jenkins:$(VERSION)
	bin/helm chart save op-svc-jenkins-crs-$(VERSION).tgz operatorservice.azurecr.io/helm/op-svc-jenkins-crs:$(VERSION)
	bin/helm chart save op-svc-jenkins-$(VERSION).tgz operatorservice.azurecr.io/helm/op-svc-jenkins:latest
	bin/helm chart save op-svc-jenkins-crs-$(VERSION).tgz operatorservice.azurecr.io/helm/op-svc-jenkins-crs:latest


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
	git log  --pretty=format:' * %s' $(VERSION)...HEAD > CHANGELOG.txt