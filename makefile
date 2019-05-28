APP_VERSION ?= `grep 'version:' mix.exs | cut -d '"' -f2`
BUILD ?= `git rev-parse --short=7 HEAD`

help:
	@echo "union:$(APP_VERSION)-$(BUILD)"
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## Build the Docker image
	docker pull happysalada/union:builder
	docker build -t union:builder --target=builder .
	docker tag union:builder happysalada/union:builder
	docker push happysalada/union:builder

	docker pull happysalada/union:deps
	docker build -t union:deps --target=deps .
	docker tag union:deps happysalada/union:deps
	docker push happysalada/union:deps

	docker pull happysalada/union:frontend
	docker build -t union:frontend --target=frontend .
	docker tag union:frontend happysalada/union:frontend
	docker push happysalada/union:frontend

	docker pull happysalada/union:releaser
	docker build -t union:releaser --target=releaser .
	docker tag union:releaser happysalada/union:releaser
	docker push happysalada/union:releaser

	docker build -t union:$(BUILD) .
	docker tag union:$(BUILD) happysalada/union:$(BUILD)
	docker push happysalada/union:$(BUILD)

deploy_staging:
	git push staging master
	ssh debian@51.83.107.149 "/etc/union/circle_deployer.sh ${BUILD}"

deploy_prod:
	ssh root@167.99.200.41 "/etc/union/circle_deployer.sh ${BUILD}"

