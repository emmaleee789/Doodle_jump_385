transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/kangx/Documents/_Project/ECE_385_sp24/lab4.2 {C:/Users/kangx/Documents/_Project/ECE_385_sp24/lab4.2/HexDriver.sv}
vlog -sv -work work +incdir+C:/Users/kangx/Documents/_Project/ECE_385_sp24/lab4.2 {C:/Users/kangx/Documents/_Project/ECE_385_sp24/lab4.2/full_adder.sv}
vlog -sv -work work +incdir+C:/Users/kangx/Documents/_Project/ECE_385_sp24/lab4.2 {C:/Users/kangx/Documents/_Project/ECE_385_sp24/lab4.2/carry_select_adder.sv}
vlog -sv -work work +incdir+C:/Users/kangx/Documents/_Project/ECE_385_sp24/lab4.2 {C:/Users/kangx/Documents/_Project/ECE_385_sp24/lab4.2/lab4_adders_toplevel.sv}

vlog -sv -work work +incdir+C:/Users/kangx/Documents/_Project/ECE_385_sp24/lab4.2 {C:/Users/kangx/Documents/_Project/ECE_385_sp24/lab4.2/testbench_adder.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  testbench

add wave *
view structure
view signals
run 1000 ns
