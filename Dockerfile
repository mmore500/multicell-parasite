FROM ubuntu:22.04

# Install necessary packages
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    g++ \
    make \
    ccache \
    libncurses5-dev \
    && rm -rf /var/lib/apt/lists/*

COPY . /multicell-parasite
WORKDIR "/multicell-parasite"

RUN git submodule update --init --recursive

# Build Avida
RUN \
  . ./pipeline/snippets/install_avida.sh && \
  echo "AVIDA ${AVIDA}" && \
  cp "${AVIDA}" /multicell-parasite/avida


# Set Avida executable as entrypoint
ENTRYPOINT ["/multicell-parasite/avida"]
