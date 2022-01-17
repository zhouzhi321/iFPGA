#!/usr/bin/env bash
set -ex
yosys -p "tcl ../synth/synth_generic.tcl 4 $1.json" $2/$1.v
${NEXTPNR:-../../nextpnr-generic} --pre-pack simple.py --pre-place simple_timing.py --json $1.json --post-route bitstream.py --write pnr$1.json --top $1
yosys -p "read_verilog -lib ../synth/prims.v; read_json pnr$1.json; dump -o $1.il; show -format png -prefix $1"
