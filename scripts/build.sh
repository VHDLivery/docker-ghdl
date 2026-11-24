#!/bin/sh
set -eu
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
docker build -f "$repo_root/Dockerfile" \
  -t "${1:-docker-ghdl:local}" "$repo_root"
