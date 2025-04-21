FROM ubuntu:22.04

# Evita prompts interativos na instalação
ENV DEBIAN_FRONTEND=noninteractive

# Atualiza pacotes e instala dependências necessárias
RUN apt-get update && apt-get install -y \
    build-essential \
    libncurses-dev \
    flex \
    bison \
    libssl-dev \
    bc \
    git \
    wget \
    cpio \
    curl \
    vim \
    make \
    gcc \
    libc6-dev \
    crossbuild-essential-amd64 \
    && rm -rf /var/lib/apt/lists/*

# Cria diretório de trabalho dentro do container
WORKDIR /src

# Comando padrão ao entrar no container
CMD ["bash"]
