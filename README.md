# docker-ghdl

Docker environment for VHDL simulation with GHDL, VUnit, fpgather and GTKWave.
GHDL uses the LLVM backend. VUnit and fpgather are installed without version
pins and are resolved when the image is built.

## Build and test

From this repository's root:

```sh
./scripts/build.sh
./scripts/test.sh
```

Both scripts accept an optional image name and tag as their first argument.
The test script checks the tools and runs three VUnit counter tests.
Results are written under `examples/vhdl/build/ghdl/`.
See [the example documentation](examples/vhdl/README.md) for the source manifest
and direct simulation commands.

## Use the published image

After the first GitHub release has published the image:

```sh
docker run --rm -it -v "$PWD:/workspace" -w /workspace \
  ghcr.io/vhdlivery/docker-ghdl:latest bash
```

The container user is `fpga-env`. Its Python environment is under
`/home/fpga-env/.venv`. On macOS, GTKWave requires XQuartz and a suitable
DISPLAY configuration such as `host.docker.internal:0`.

Shared development environments and VS Code configuration are maintained in
[VHDLivery/docker-fpga-env](https://github.com/VHDLivery/docker-fpga-env), which consumes this
image without needing a checkout of this repository.

## GitHub Actions and releases

Pull requests and relevant pushes to `main` build and test the image natively
on Linux AMD64 and ARM64. The checks can also be started manually.

Publishing a GitHub release runs those checks before building and publishing
both architectures to `ghcr.io/vhdlivery/docker-ghdl`. The release tag is used
as the image tag, for example `v1.0.0`. Stable releases additionally update
`latest`; prereleases only publish their release tag. Draft releases and Git
tag pushes alone do not publish images.

The workflow uses the automatic `GITHUB_TOKEN`, with no Docker Hub credentials
or personal token. Organization settings must allow package creation. Check
package visibility after the first publication if anonymous pulls are desired.
Release builds bypass the build cache, so rebuilding the same release can
resolve newer unpinned Python packages.
