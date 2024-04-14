FROM ubuntu:23.04 as builder
SHELL ["/bin/bash", "-c"]
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y python3 python3-pip python3-dev python3-venv \
                    gcc-arm-none-eabi build-essential libxml2-utils ccache \
                    ncurses-dev librsvg2-bin device-tree-compiler cmake \
                    ninja-build curl zlib1g-dev texlive-fonts-recommended \
                    texlive-latex-extra texlive-metapost texlive-bibtex-extra \
                    haskell-stack repo mlton-compiler
RUN python3 -m venv l4venv
RUN ./l4venv/bin/pip install sel4-deps
RUN source ./l4venv/bin/activate
RUN stack upgrade --binary-only
RUN stack install cabal-install
RUN mkdir verification
WORKDIR verification
RUN repo init -u https://git@github.com/seL4/verification-manifest.git
RUN repo sync
RUN mkdir -p ~/.isabelle/etc
RUN cp -i l4v/misc/etc/settings ~/.isabelle/etc/settings
RUN ./l4v/isabelle/bin/isabelle components -a
RUN ./l4v/isabelle/bin/isabelle jedit -bf
RUN ./l4v/isabelle/bin/isabelle build -bv HOL

FROM builder AS finalbuild
RUN ls
