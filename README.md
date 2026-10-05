# Prezto template

Provisioned from [`Qode-Fleet-Control/fleet-template-v1`](https://github.com/Qode-Fleet-Control/fleet-template-v1) — the fleet
lifecycle contract (`bin/`, `fleet.conf`, `compose.yaml`, deploy workflows) with a
Prezto starter laid on top. **A job, not a service**: the image's default command runs the
check and exits 0 on success; nothing listens on `$PORT`.

## What it is

A versioned zsh setup (`VERSION`, currently 1.0.0) on [Prezto](https://github.com/sorin-ionescu/prezto):

| path | what |
|---|---|
| `zsh/.zshrc` | sources Prezto's `init.zsh` |
| `zsh/.zpreztorc` | Prezto's config: the module list, the prompt theme |
| `zsh/modules/qode/` | the setup's own Prezto module: `init.zsh` (`mkcd`, `ll`), autoloaded `functions/qode_hello` |
| `zsh/modules/qode/functions/prompt_qode_setup` | the setup's own prompt theme: `qode <cwd> (<branch>) %` |
| `scripts/install.sh` | clones Prezto (with submodules) at a pinned commit |
| `scripts/check.sh` | **the job**: interactive zsh, checks the setup loaded |

`zsh/` is the ZDOTDIR; `.zpreztorc` adds `zsh/modules` to `pmodule-dirs`, so custom
modules live in the repo.

## Run it

**With docker** (what the fleet does):

    docker compose build
    docker compose run --rm app        # the check; exit 0 = setup loaded
    docker compose run --rm app zsh    # try the shell itself

**Without docker** (needs zsh and git; your `~/.zshrc` is left alone):

    ZPREZTODIR="$PWD/.zprezto" sh scripts/install.sh   # = fleet.conf INSTALL_CMD
    ZPREZTODIR="$PWD/.zprezto" sh scripts/check.sh
    ZDOTDIR="$PWD/zsh" ZPREZTODIR="$PWD/.zprezto" zsh  # use it

## Origin

Prezto's documented install (its README), pinned to commit `cff2d01871425b1b80710f8ec6a475c5a53145b4`:

    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

`zsh/.zshrc` and `zsh/.zpreztorc` are cut down from Prezto's `runcoms/`; the `qode`
module follows Prezto's module layout (`init.zsh` + `functions/`), and the prompt
follows its `prompt_<name>_setup` convention.

## Deviations from stock output, and why

- **Runcoms are not symlinked.** The README links every `runcoms/*` file into
  `$ZDOTDIR`; here `zsh/` *is* the ZDOTDIR with its own `.zshrc`/`.zpreztorc`, so the
  setup is versioned in the repo and Prezto stays a pinned dependency.
- Prezto is cloned into `$ZPREZTODIR` (default `~/.zprezto`, `./.zprezto` locally)
  rather than inside ZDOTDIR; `init.zsh` locates itself, so this works unchanged.
- Submodules are fetched `--depth 1` to keep the image small.
## Verified

**The docker image has NOT been built or run yet**: on 2026-10-05 the shared build host's docker disk was full (0-2 GB free for over 8 hours), so `docker compose build` was never attempted. Run `docker compose build && docker compose run --rm app` once before trusting it.

Without docker (2026-10-05, zsh 5.9, throwaway `$HOME`): `scripts/install.sh` cloned
Prezto at the pinned commit (with submodules) into `./.zprezto`, and
`ZPREZTODIR=$PWD/.zprezto sh scripts/check.sh` passed — prezto, git + qode modules,
qode prompt theme, prompt renders, nothing on stderr.


## Fleet lifecycle

`fleet.conf` drives every script in `bin/` (see `docs/fleet-lifecycle.md`). On the fleet
the docker runtime runs `DOCKER_BUILD_CMD` (`docker compose build`) and, because this is
a job and not a service, stops there: `DOCKER_START_CMD` is empty, the same as
`START_CMD`. Run the job itself with `docker compose run --rm app`.

    ./bin/run                    # docker runtime: builds the image, then stops (no server)
    docker compose run --rm app  # runs the job; exit code 0 = pass
    FLEET_RUNTIME=process ./bin/run   # no docker: runs INSTALL_CMD, then stops at start

`bin/run` ends with the template's own "no START_CMD" message — that is intentional.

## Serving over HTTP

Fleet apps are served at the root of their own hostname
(`https://<hash>.<FLEET_APP_DOMAIN>/`). **This repo has no HTTP surface**: `PORT`,
`HEALTH_PATH` and `START_CMD` are empty and `compose.yaml` publishes nothing. If you add
an HTTP endpoint, listen on `0.0.0.0:$PORT` (read at runtime), serve at `/`, set `PORT`,
`HEALTH_PATH`, `START_CMD` and `DOCKER_START_CMD='docker compose up --remove-orphans'`
in `fleet.conf`, and publish `"${PORT:-N}:${PORT:-N}"` in `compose.yaml`.

`compose.yaml` passes the fleet's variables (`DATABASE_URL`, `REDIS_URL`, `S3_*`,
`SMTP_*` …) through to the container without values; this template reads none of them.
