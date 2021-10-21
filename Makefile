.PHONY: all destroy
all:
	civo kubernetes create interesting-times-gang -n5 --wait 
	civo kubernetes config interesting-times-gang -s
	helm repo add grafana https://grafana.github.io/helm-charts
	kubectl create ns observability || true
	kubectl apply -f resources/datasources.yaml -n observability
	helm upgrade --install grafana grafana/grafana -n observability
	helm upgrade --install promtail grafana/promtail -f resources/promtail-values.yaml -n observability
	helm upgrade --install loki grafana/loki-distributed -n observability
	kubectl get secret --namespace observability grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
destroy: 
	civo kubernetes delete interesting-times-gang
