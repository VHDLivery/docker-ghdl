"""Resolve project sources with fpgather and run the VUnit counter tests."""

import os
from pathlib import Path

from fpgather import export_sources, resolve
from fpgather.vunit import import_vunit_csv
from vunit import VUnit


def main():
    root = Path(__file__).resolve().parents[3]
    # Resolve relative VUnit output options against the example root.
    os.chdir(root)
    vu = VUnit.from_argv(compile_builtins=False)
    vu.add_vhdl_builtins()

    sources = resolve(root / "sources.yml", project_root=root, library="lib")
    csv_path = export_sources(
        sources, tool="vunit", file_type="csv",
        output=root / "build" / "ghdl" / "fpgather" / "sources.csv",
    )
    import_vunit_csv(vu, csv_path)

    vu.set_compile_option("ghdl.a_flags", ["--std=08", "-frelaxed"])
    vu.set_sim_option("ghdl.elab_flags", ["-frelaxed"])
    vu.set_sim_option("ghdl.sim_flags", ["--vcd=wave.vcd"])

    vu.main()


if __name__ == "__main__":
    main()
