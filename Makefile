include variables.mk

.PHONY: helm
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
	bin/helm lint chart/jenkins-operator

.PHONE: change-chart-version
change-chart-version:
	sed -i "/version:/c\version: $(CHARTVERSION)" chart/op-svc-jenkins/Chart.yaml
	if [ $(CHARTVERSION) ] ; then
		sed -i "/appVersion:/c\appVersion: \"$(CHARTVERSION)\"" chart/op-svc-jenkins/Chart.yaml
	fi

	sed -i "/version:/c\version: $(CHARTVERSION)" chart/op-svc-jenkins-crs/Chart.yaml
	if [ $(CHARTVERSION) ] ; then
		sed -i "/appVersion:/c\appVersion: \"$(CHARTVERSION)\"" chart/op-svc-jenkins-crs/Chart.yaml
	fi

.PHONY: helm-package-latest
helm-release-latest: helm
	@echo "+ $@"
	bin/helm package chart/op-svc-jenkins
	bin/helm package chart/op-svc-jenkins-crs

.PHONY: helm-save-local
helm-save-local:
	bin/helm chart save op-svc-jenkins-$(CHARTVERSION).tgz operatorservice.azurecr.io/helm/op-svc-jenkins:$(CHARTVERSION)
	bin/helm chart save op-svc-jenkins-crs-$(CHARTVERSION).tgz operatorservice.azurecr.io/helm/op-svc-jenkins-crs:$(CHARTVERSION)
	bin/helm chart save op-svc-jenkins-$(CHARTVERSION).tgz operatorservice.azurecr.io/helm/op-svc-jenkins:latest
	bin/helm chart save op-svc-jenkins-crs-$(CHARTVERSION).tgz operatorservice.azurecr.io/helm/op-svc-jenkins-crs:latest