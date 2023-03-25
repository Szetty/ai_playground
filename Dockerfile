# First stage: build
FROM elixir:1.14 as build

# Update and install required build dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Elixir package managers
RUN mix local.hex --force && mix local.rebar --force

# Install libtorch
WORKDIR /libtorch
RUN wget https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-1.13.1%2Bcpu.zip
RUN unzip libtorch-cxx11-abi-shared-with-deps-1.13.1+cpu.zip && rm libtorch-cxx11-abi-shared-with-deps-1.13.1+cpu.zip
RUN mv ./libtorch/* ./ && rmdir libtorch
ENV LD_LIBRARY_PATH="/libtorch/lib:${LD_LIBRARY_PATH}"

# Copy Elixir project files and build
WORKDIR /ai_playground

# Copy dependencies and build them
COPY config ./config
COPY mix.exs .
COPY mix.lock .
COPY assets ./assets

RUN mix setup

# Copy app
COPY lib ./lib
COPY native ./native
COPY priv ./priv
# COPY rel ./rel

# Release the app
ENV MIX_ENV=prod
RUN mix assets.deploy && mix release

# Second stage: run
FROM debian:latest as run

# Locales and libtorch dependencies
RUN apt-get update && apt-get install -y \
    locales \
    libgomp1 \
    ca-certificates

# Uncomment desired locale and generate it
RUN sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
RUN locale-gen

# Set the locale environment variables
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Copy libtorch
COPY --from=build /libtorch /libtorch
ENV LD_LIBRARY_PATH="/libtorch/lib:${LD_LIBRARY_PATH}"

# Copy Elixir runtime files
COPY --from=build /ai_playground/_build/prod/rel/ai_playground /ai_playground

# Expose required ports for the Elixir Phoenix server
EXPOSE 7860

# Set the Elixir server as the entrypoint
CMD ["/ai_playground/bin/ai_playground", "start"]
