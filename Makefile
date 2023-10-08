# Common Variables
REPO       := ghcr.io/open-flux-ai/serve
MODEL_REPO := ghcr.io/open-flux-ai/models
VERSION    := 0.2.18
BUILD_DIR  := build
LLAMA_DIR  := llama-cpp-python

# Phony Targets Declaration
.PHONY: cpu cpu-source gpu-source llama-7b-gpu llama-70b-gpu copy-dockerfile pull-artifact push-image

# Targets for copying dockerfiles based on the specified type
copy-dockerfile:
	@cp $(LLAMA_DIR)/Dockerfile.$(TYPE) $(BUILD_DIR)/Dockerfile

# Target for pulling artifacts
pull-artifact:
	@if [ -z "$(MODEL)" ] || [ -z "$(HASH)" ]; then \
		echo "MODEL and HASH variables must be set"; \
		exit 1; \
	fi
	@flux pull artifact --timeout=120m0s --output ./$(BUILD_DIR) oci://$(MODEL_REPO)/$(MODEL):v$(VERSION)-$(HASH)
	@mv ./$(BUILD_DIR)/*.gguf ./$(BUILD_DIR)/model.gguf

# Target for building docker image
build-image:
	@docker build --build-arg VERSION=$(VERSION) -t $(REPO)/$(IMAGE_NAME):v$(VERSION)-$(TAG_SUFFIX) ./$(BUILD_DIR)

# Target for pushing docker image
push-image:
	@docker push $(REPO)/$(IMAGE_NAME):v$(VERSION)-$(TAG_SUFFIX)

# Original Targets Refactored
cpu: TYPE=cpu
cpu: IMAGE_NAME=llama-cpp-python
cpu: TAG_SUFFIX=cpu
cpu: copy-dockerfile build-image push-image

cpu-source: TYPE=cpu-source
cpu-source: IMAGE_NAME=llama-cpp-python
cpu-source: TAG_SUFFIX=cpu-master
cpu-source: copy-dockerfile build-image push-image

gpu: TYPE=cublas
gpu: IMAGE_NAME=llama-cpp-python
gpu: TAG_SUFFIX=gpu
gpu: copy-dockerfile build-image push-image

gpu-source: TYPE=cublas-source
gpu-source: IMAGE_NAME=llama-cpp-python
gpu-source: TAG_SUFFIX=gpu-master
gpu-source: copy-dockerfile build-image push-image

mistral-7b-gpu:  TYPE=cublas-bundle
mistral-7b-gpu:  IMAGE_NAME=llama-2-7b-chat-q5km
mistral-7b-gpu:  TAG_SUFFIX=gpu-bundled
mistral-7b-gpu:  MODEL=llama-2-7b-chat-4k
mistral-7b-gpu:  HASH=q5km-gguf
mistral-7b-gpu:  pull-artifact copy-dockerfile build-image push-image

llama-7b-gpu:  TYPE=cublas-bundle
llama-7b-gpu:  IMAGE_NAME=llama-2-7b-chat-q5km
llama-7b-gpu:  TAG_SUFFIX=gpu-bundled
llama-7b-gpu:  MODEL=llama-2-7b-chat-4k
llama-7b-gpu:  HASH=q5km-gguf
llama-7b-gpu:  pull-artifact copy-dockerfile build-image push-image

llama-70b-gpu: TYPE=cublas-bundle
llama-70b-gpu: IMAGE_NAME=llama-2-70b-chat-q5km
llama-70b-gpu: TAG_SUFFIX=gpu-bundled
llama-70b-gpu: MODEL=llama-2-70b-chat-4k
llama-70b-gpu: HASH=q5km-gguf
llama-70b-gpu: pull-artifact copy-dockerfile build-image push-image
