transcript on
if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vlog -sv -work work +incdir+. {lab4_7_1200mv_85c_slow.svo}

vlog -sv -work work +incdir+C:/Users/kangx/Documents/_Project/ECE_385_sp24/lab4.2 {C:/Users/kangx/Documents/_Project/ECE_385_sp24/lab4.2/testbench_adder.sv}

vsim -t 1ps +transport_int_delays +transport_path_delays -L altera_ver -L cycloneive_ver -L gate_work -L work -voptargs="+acc"  testbench

source lab4_dump_all_vcd_nodes.tcl
add wave *
view structure
view signals
run 1000 ns
