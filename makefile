SHELL := /bin/bash
VERSION := 1.0
KIND_CLUSTER := fd1az-starter-cluster

run:
	go run .

build:
	go build -ldflags "-X main.build=local"

all: service

service:
	docker build \
		-f zarf/docker/dockerfile \
		-t service-amd64:$(VERSION) \
		--build-arg BUILD_REF=$(VERSION) \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		.

kind-up:
	kind create cluster \
		--image kindest/node:v1.23.0@sha256:49824ab1727c04e56a21a5d8372a402fcd32ea51ac96a2706a12af38934f81ac \
		--name $(KIND_CLUSTER) \
		--config zarf/k8s/kind/kind-config.yaml
	kubectl config set-context --current --namespace=service-system

kind-down:
	kind delete cluster --name $(KIND_CLUSTER)

kind-status:
	kubectl get nodes -o wide
	kubectl get svc -o wide

kind-status-service:
	kubectl get pods -o wide --watch
	
kind-load:
	kind load docker-image service-amd64:$(VERSION) --name $(KIND_CLUSTER)
	
kind-apply:
	cat zarf/k8s/kind/base/service-pod/base-service.yaml | kubectl apply -f -

kind-logs:
	kubectl logs -l app=service --all-containers=true -f --tail=100

kind-restart:
	kubectl rollout restart deployment service-pod

kind-update: all kind-load kind-restart

kind-describe:
	kubectl describe nodes
	kubectl describe svc
	kubectl describe pod -l app=sales