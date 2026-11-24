#!/bin/sh
set -eu
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
image=${1:-docker-ghdl:local}

docker run --rm --user "$(id -u):$(id -g)" \
  -e HOME=/tmp \
  -v "$repo_root:/workspace" \
  -w /workspace/examples/vhdl \
  "$image" bash -c '
    set -eu
    ghdl --version
    python3 -c "import vunit, fpgather"
    fpgather --help
    python3 src/sim/scripts/run.py -o build/ghdl/vunit
  '
