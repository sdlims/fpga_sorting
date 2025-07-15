TOP := tb
RTL_TOP := uart_comm

export YOSYS_DATDIR := $(shell yosys-config --datdir)
export ALEX_UART_DIR = $(abspath third_party/verilog-uart)

RTL := $(shell \
 YOSYS_DATDIR=$(YOSYS_DATDIR) \
 python3 misc/convert_filelist.py Makefile rtl/rtl.f \
)

SV2V_ARGS := $(shell \
 python3 misc/convert_filelist.py sv2v rtl/rtl.f \
)


.PHONY: lint sim synth clean

lint: 
	verilator lint.vlt -f rtl/rtl.f -f dv/dv.f --lint-only --top $(RTL_TOP)

sim: 
	verilator lint.vlt --Mdir ${TOP}_$@_dir -f rtl/rtl.f -f dv/dv.f --binary --top ${TOP}
	./${TOP}_$@_dir/V${TOP} +verilator+rand+reset+2

gls: synth/yosys_generic/build/synth.v
	verilator lint.vlt --Mdir ${TOP}_$@_dir -f synth/yosys_generic/gls.f -f dv/dv.f --binary -Wno-fatal --top ${TOP}
	./${TOP}_$@_dir/V${TOP} +verilator+rand+reset+2

gls_xc7: synth/yosys_xc7/build/xc7.v
	verilator lint.vlt --Mdir ${TOP}_$@_dir -f synth/yosys_xc7/gls_xc7.f -f dv/dv.f --binary --top ${TOP}
	./${TOP}_$@_dir/V${TOP} +verilator+rand+reset+2

synth/build/rtl.sv2v.v: ${RTL}
	mkdir -p $(dir $@)
	sv2v ${RTL} -w $@ -DSYNTHESIS

synth/yosys_generic/build/synth.v: synth/build/rtl.sv2v.v synth/yosys_generic/yosys.tcl ${MEMS}
	mkdir -p $(dir $@)
	yosys -p 'tcl synth/yosys_generic/yosys.tcl synth/build/rtl.sv2v.v' -l synth/yosys_generic/build/yosys.log

icestorm_icebreaker_gls: synth/icestorm_icebreaker/build/synth.v
	verilator lint.vlt --Mdir ${TOP}_$@_dir -f synth/icestorm_icebreaker/gls.f -f dv/dv.f --binary -Wno-fatal --top ${TOP}
	./${TOP}_$@_dir/V${TOP} +verilator+rand+reset+2

synth/icestorm_icebreaker/build/synth.v synth/icestorm_icebreaker/build/synth.json: synth/build/rtl.sv2v.v synth/icestorm_icebreaker/icebreaker.v synth/icestorm_icebreaker/yosys.tcl
	mkdir -p $(dir $@)
	yosys -p 'tcl synth/icestorm_icebreaker/yosys.tcl' -l synth/icestorm_icebreaker/build/yosys.log

synth/icestorm_icebreaker/build/icebreaker.asc: synth/icestorm_icebreaker/build/synth.json synth/icestorm_icebreaker/icebreaker.py synth/icestorm_icebreaker/icebreaker.pcf
	nextpnr-ice40 \
	 --json synth/icestorm_icebreaker/build/synth.json \
	 --up5k \
	 --package sg48 \
	 --pre-pack synth/icestorm_icebreaker/icebreaker.py \
	 --pcf synth/icestorm_icebreaker/icebreaker.pcf \
	 --asc $@

%.bit: %.asc
	icepack $< $@

clean:
	rm -rf \
	 *.memh *.memb \
	 *sim_dir *gls_dir \
	 dump.vcd dump.fst \
	 synth/build \
	 synth/yosys_generic/build \
	 synth/icestorm_icebreaker/build \
	 synth/vivado_basys3/build