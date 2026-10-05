# Built by .github/workflows/deploy.yml (context ., file Dockerfile) and pushed
# to Artifact Registry.
#
# A job image, not a server: Prezto is installed in the image (git clone --recursive,
# pinned commit — scripts/install.sh) for a non-root user, this repo's zsh/ is its
# ZDOTDIR, and the default command starts an interactive zsh and checks that the setup
# loaded (scripts/check.sh). Exits 0 when it did.

FROM debian:bookworm-slim
ARG BUILD_ID=""
RUN apt-get update \
 && apt-get install -y --no-install-recommends zsh git ca-certificates \
 && rm -rf /var/lib/apt/lists/*
RUN useradd -m -u 10001 -s /usr/bin/zsh app && mkdir /app && chown app:app /app
ENV BUILD_ID=$BUILD_ID ZDOTDIR=/app/zsh ZPREZTODIR=/home/app/.zprezto TERM=xterm-256color

WORKDIR /app
USER app
COPY --chown=app:app scripts/install.sh scripts/install.sh
RUN sh scripts/install.sh
COPY --chown=app:app . .
CMD ["sh", "scripts/check.sh"]
