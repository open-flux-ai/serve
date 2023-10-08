# Stage 0
FROM ghcr.io/open-flux-ai/serve/build:latest

ARG VERSION
ARG CMAKE_ARGS

WORKDIR /work

RUN git clone --recurse-submodules https://github.com/abetlen/llama-cpp-python

WORKDIR /work/llama-cpp-python

RUN git checkout -b v${VERSION} v${VERSION}
COPY 10-llama-cpp-python-server.patch .
RUN git apply --3way 10-llama-cpp-python-server.patch \
  && rm 10-llama-cpp-python-server.patch

RUN pip install --upgrade pip
RUN pip install build
RUN make deps
RUN make build.sdist

# Stage 1
FROM ghcr.io/open-flux-ai/serve/build:latest

ARG VERSION
ARG CMAKE_ARGS

COPY --from=0 /work/llama-cpp-python/dist/llama_cpp_python-${VERSION}.tar.gz /work

WORKDIR /work

RUN CMAKE_ARGS="${CMAKE_ARGS}" pip install /work/llama_cpp_python-${VERSION}.tar.gz[server] --user

# Stage 2
FROM ghcr.io/open-flux-ai/images/python:3.11

COPY --from=1 /root/.local/lib/python3.11/site-packages /home/nonroot/.local/lib/python3.11/site-packages

ENV HOST 0.0.0.0
ENV PORT 8000

ENTRYPOINT ["python3", "-m", "llama_cpp.server"]
