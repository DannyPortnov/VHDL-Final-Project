
if {[file exists sim/work]} {
    vdel -all
}
vlib work
vcom ../src/push_button_if.vhd 
vcom ../src/push_button_if_tb.vhd 

vsim push_button_if_tb

add wave -group push_button_test push_button_if_tb/uut/*
config wave -signalnamewidth 1
--restart -f

run 1000ns