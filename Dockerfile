
FROM ubuntu:20.04 
ARG FUNCTION_DIR="/app"


# Install aws-lambda-cpp build dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
  apt-get install -y \
  g++ \
  make \
  cmake \
  unzip \
    python3-pip \
  libcurl4-openssl-dev \
  sudo



# Include global arg in this stage of the build
ARG FUNCTION_DIR
# Create function directory
RUN mkdir -p ${FUNCTION_DIR}

# Copy function code
COPY /* ${FUNCTION_DIR}

RUN apt-get update && apt-get install -y software-properties-common && apt-get install -y python3.8 python3-pip python3.8-venv pkg-config libcairo2-dev curl

RUN  python3.8 -m pip install --upgrade pip

RUN python3.8 -m pip install \
        --target ${FUNCTION_DIR} \
        torch torchvision sentence_transformers

RUN python3.8 -m pip install --upgrade pip && pip install \
        --target ${FUNCTION_DIR} \
        chromadb



RUN python3.8 -m  pip install \
        --target ${FUNCTION_DIR} \
        python-dotenv tqdm langchain

RUN python3.8 -m  pip install \
        --target ${FUNCTION_DIR} \
        runpod


ARG FUNCTION_DIR
RUN mkdir -p /home/sbx_user1051
RUN mkdir -p /home/sbx_user1051/.cache
RUN mkdir -p /home/sbx_user1051/.cache/mesa_shader_cache
RUN mkdir -p /home/sbx_user1051/.cache/torch
RUN chmod +w /home/sbx_user1051/.cache/torch
RUN mkdir -p /home/sbx_user1051/.cache/torch/sentence_transformers
RUN chmod +w /home/sbx_user1051/.cache/torch/sentence_transformers
RUN mkdir -p /home/sbx_user1051/.cache/torch/sentence_transformers/sentence-transformers_all-MiniLM-L6-v2
RUN chmod +w /home/sbx_user1051/.cache/torch/sentence_transformers/sentence-transformers_all-MiniLM-L6-v2
RUN chmod -R 777 /home/sbx_user1051/.cache/torch/sentence_transformers/sentence-transformers_all-MiniLM-L6-v2
RUN touch /home/sbx_user1051/.cache/torch/sentence_transformers/sentence-transformers_all-MiniLM-L6-v2/.gitattributes.lock
RUN chmod 777 /home/sbx_user1051/.cache/torch/sentence_transformers/sentence-transformers_all-MiniLM-L6-v2/.gitattributes.lock
ENV TORCH_HOME=/tmp
# RUN chmod -R 777 /home/sbx_user1051/.cache

RUN export TRANSFORMERS_CACHE=/tmp
RUN export HF_HOME=/tmp

# Multi-stage build: grab a fresh copy of the base image



RUN apt install python3-distutils -y

# Include global arg in this stage of the build
ARG FUNCTION_DIR
RUN mkdir -p /home/sbx_user1051
COPY /* /app 
RUN mkdir -p /app/source_documents
COPY source_documents /app/source_documents

RUN mkdir -p /tmp/gpt

RUN python3.8 -m pip install \
        --target ${FUNCTION_DIR} -r /app/requirements.txt

RUN apt update && apt install -y git



# Set working directory to function root directory
RUN git clone --recurse-submodules https://github.com/nomic-ai/gpt4all && \
 cd gpt4all/gpt4all-backend/ && \
  mkdir build && cd build && \
   cmake .. && \
   cmake --build . --parallel && \
   cd ../../gpt4all-bindings/python && \
   pip3 install -e .

WORKDIR ${FUNCTION_DIR}

RUN curl -LO https://huggingface.co/orel12/ggml-gpt4all-j-v1.3-groovy/resolve/main/ggml-gpt4all-j-v1.3-groovy.bin
COPY ggml-gpt4all-j-v1.3-groovy.bin /app/


CMD [ "python3", "-m","privateGPT.py"]


# mkdir -p /.tmp
# ln -s /.tmp /home/sbx_user1051
# ENV TORCH_HOME=/.cache/torch