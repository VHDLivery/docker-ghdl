# VHDL simulation example

Run from this directory inside the GHDL container:

```sh
python3 src/sim/scripts/run.py -o build/ghdl/vunit
```

VUnit compiles the counter and testbench, then runs the reset, counting and
clock-enable tests. No UVVM checkout or other HDL library is required.
Waveforms are written into the test output directories under `build/ghdl/vunit`.
Pass additional VUnit arguments, for example `--list`, to the same command.

Project sources and their VHDL versions are declared in `sources.yml`.
fpgather resolves this manifest and generates `build/ghdl/fpgather/sources.csv` and
its settings file, which the runner imports into VUnit. Generated files contain
absolute local paths and must not be committed.

The image includes unpinned `fpgather` and `vunit_hdl` packages. Both versions
are selected at image build time; existing images do not update automatically.

## Waveform viewer on macOS

Start XQuartz on the host and allow the required local display connection.
Add `-e DISPLAY=host.docker.internal:0` to `docker run`, then open the desired
waveform with `gtkwave path/to/wave.vcd` inside the container.
