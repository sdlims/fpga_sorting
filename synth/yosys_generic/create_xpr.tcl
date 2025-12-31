set rtl [lindex $argv 0]
set fpga [lindex $argv 1]

source ../vivado_config.tcl

create_project project project/ -part $part -force

add_files -fileset constrs_1 ../../$fpga/constraint.xdc

add_files -norecurse ../../../$rtl

launch_runs synth_1

wait_on_run synth_1
launch_runs impl_1 -to_step write_bitstream

wait_on_run impl_1