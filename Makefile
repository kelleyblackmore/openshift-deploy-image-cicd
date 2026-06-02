IMAGE_NAME ?= ubi9-openshift-cicd
IMAGE_TAG ?= local
REGISTRY ?= registry.example.com/devsecops

.PHONY: build run test push

build:
	podman build \
		--build-arg HELM_VERSION=3.20.2 \
		--build-arg OC_VERSION=stable-4.17 \
		-t $(IMAGE_NAME):$(IMAGE_TAG) \
		-f Containerfile .

run:
	podman run --rm -it \
		-v "$$(pwd):/workspace:Z" \
		$(IMAGE_NAME):$(IMAGE_TAG)

test:
	podman run --rm $(IMAGE_NAME):$(IMAGE_TAG) helm version --client
	podman run --rm $(IMAGE_NAME):$(IMAGE_TAG) oc version --client
	podman run --rm $(IMAGE_NAME):$(IMAGE_TAG) kubectl version --client=true
	podman run --rm $(IMAGE_NAME):$(IMAGE_TAG) jq --version
	podman run --rm $(IMAGE_NAME):$(IMAGE_TAG) yq --version

push:
	podman tag $(IMAGE_NAME):$(IMAGE_TAG) $(REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)
	podman push $(REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)
