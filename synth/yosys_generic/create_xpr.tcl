set rtl [lindex $argv 0]

source ../../vivado_config.tcl

create_project project project/ -part $part -force

add_files -fileset constrs_1 ../$fpga/constraint.xdc

add_files -norecurse ../../../../$rtl