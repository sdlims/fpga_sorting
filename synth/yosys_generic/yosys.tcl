yosys -import

read_verilog synth/build/rtl.sv2v.v
# read_verilog -sv rtl/uart_comm.sv
# read_verilog -sv rtl/uart_comm.sv
# read_verilog third_party/verilog-uart/rtl/uart_rx.v
# read_verilog third_party/verilog-uart/rtl/uart_tx.v

prep
opt -full
stat

write_verilog -noexpr -noattr -simple-lhs synth/yosys_generic/build/synth.v