#!/usr/bin/env bash
set -ex
yosys -p "tcl ../synth/synth_generic.tcl 4 $1.json" $2/$1.v
${NEXTPNR:-../../nextpnr-generic} --no-iobs --pre-pack simple.py --pre-place simple_timing.py --json $1.json --post-route bitstream.py --write pnr$1.json --top $1
yosys -p "read_json pnr$1.json; write_verilog -noattr -norename pnr$1.v"
iverilog -o $4/$3 $4/$1_tb.v $4/$1.v
vvp -N $4/$1_tb
