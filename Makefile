build-cpu:
	cp llama-cpp-python/Dockerfile.cpu build/Dockerfile
	docker build -t ghcr.io/llm-gitops/serve/llama-cpp-python:v1.0.0-cpu build/.

build-gpu:
	cp llama-cpp-python/Dockerfile.cublas build/Dockerfile
	docker build -t ghcr.io/llm-gitops/serve/llama-cpp-python:v1.0.0-gpu build/.

build-llama-7b-gpu:
	flux pull artifact oci://ghcr.io/llm-gitops/models/llama-2-7b-chat-4k:v1.0.0-q5km-gguf --output ./build
	mv ./build/*.gguf ./build/model.gguf
	cp llama-cpp-python/Dockerfile.cublas-bundle build/Dockerfile
	docker build -t ghcr.io/llm-gitops/serve/llama-2-7b-chat-q5km:v1.0.0-gpu-bundled ./build
	docker push ghcr.io/llm-gitops/serve/llama-2-7b-chat-q5km:v1.0.0-gpu-bundled

build-llama-70b-gpu:
	flux pull artifact oci://ghcr.io/llm-gitops/models/llama-2-70b-chat-4k:v1.0.0-q5km-gguf --output ./build
	mv ./build/*.gguf ./build/model.gguf
	cp llama-cpp-python/Dockerfile.cublas-bundle build/Dockerfile
	docker build -t ghcr.io/llm-gitops/serve/llama-2-70b-chat-q5km:v1.0.0-gpu-bundled ./build
	docker push ghcr.io/llm-gitops/serve/llama-2-70b-chat-q5km:v1.0.0-gpu-bundled
