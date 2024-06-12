validate-manifest:
	oc process --local=true -f openshift/template.yaml | kubeconform -strict -verbose -skip ServiceMonitor -

validate-dashboards:
	kubeconform -strict -verbose dashboards/

KIBANA_DASHBOARDS=$(CURDIR)/kibana/dashboards

create-backups:
	@rm -fr $(KIBANA_DASHBOARDS)
	@$(CURDIR)/scripts/createBackup.sh -o $(KIBANA_DASHBOARDS) -u $(URL)
