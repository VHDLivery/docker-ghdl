# docker-ghdl

Docker environment for VHDL simulation with GHDL, VUnit, fpgather and GTKWave.
GHDL 6.0.0 uses the LLVM backend. The Ubuntu base image is pinned by digest;
explicit Ubuntu packages and Python packages are pinned to exact versions.
Transitive Ubuntu dependencies still resolve from the configured repositories.

## Build and test

From this repository's root:

```sh
./scripts/lint.sh
./scripts/build.sh
./scripts/test.sh
```

The build and test scripts accept an optional image name and tag as their first argument.
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

The container user is `developer`. Its Python environment is under
`/home/developer/.venv`. On macOS, GTKWave requires XQuartz and a suitable
DISPLAY configuration such as `host.docker.internal:0`.

Shared development environments and VS Code configuration are maintained in
[VHDLivery/docker-fpga-env](https://github.com/VHDLivery/docker-fpga-env), which consumes this
image without needing a checkout of this repository.

## GitHub Actions and releases

Pull requests and relevant pushes to `main` build and test the image natively
on Linux AMD64 and ARM64. The checks can also be started manually.

Publishing a GitHub release builds each architecture once on its native
runner, uploads the image by digest and tests that exact image. Only after
both architectures pass are the tested images combined under release tags
at `ghcr.io/vhdlivery/docker-ghdl`. The release tag becomes the image tag with its leading `v` removed.
For example, release `v6.0.0-1` publishes image tag `6.0.0-1`. Stable releases additionally update
`latest`; prereleases only publish their release tag. Draft releases and Git
tag pushes alone do not publish images.

The workflow uses the automatic `GITHUB_TOKEN`, with no Docker Hub credentials
or personal token. Organization settings must allow package creation. Check
package visibility after the first publication if anonymous pulls are desired.
Release builds bypass the build cache. Pinned package versions must remain
available in the upstream repositories; this is not a snapshot-based build.

Release builds do not use QEMU emulation. If either architecture fails its
build or tests, release tags are not updated. Uploaded digest-only images
from a failed run may remain in GHCR without release tags.

Hadolint checks run before CI builds and release builds. The lint image is
pinned by digest. DL3064 is suppressed only for the non-secret USERNAME
argument, which selects the local Linux account.

## Image build stages

GHDL is compiled in a separate builder stage. The final image contains the
installed GHDL files, LLVM and GNAT runtime libraries, GCC, and libc/zlib
development files needed to link simulations. GNAT, Clang and LLVM
development tools are excluded. Python, VUnit, fpgather, GTKWave and Git remain available.
