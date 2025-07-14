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

synth/build/rtl.sv2v.v: ${RTL}
	mkdir -p $(dir $@)
	sv2v ${RTL} -w $@ -DSYNTHESIS

clean:
	rm -rf \
	 *.memh *.memb \
	 *sim_dir *gls_dir \
	 dump.vcd dump.fst \
	 synth/build \
	 synth/yosys_generic/build \
	 synth/icestorm_icebreaker/build \
	 synth/vivado_basys3/build
	clear