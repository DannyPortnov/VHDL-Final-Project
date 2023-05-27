
if {[file exists sim/work]} {
    vdel -all
}
vlib work
vcom ../src/image_processor_pack.vhd 
vcom ../src/controller.vhd 
vcom ../src/controller_tb.vhd 

vsim controller_tb

add wave -group controller_test controller_tb/uut/*
config wave -signalnamewidth 1
--restart -f

run 7000ns