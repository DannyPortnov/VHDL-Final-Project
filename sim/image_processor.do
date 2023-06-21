
if {[file exists sim/work]} {
    vdel -all
}
vlib work
vcom ../src/image_processor_pack.vhd
vcom ../src/stabilizer.vhd
vcom ../src/bcd_to_7seg.vhd 
vcom ../src/controller.vhd 
vcom ../src/timing_generator.vhd 
vcom ../src/data_generator.vhd 
vcom ../src_sim/clock_generator.vhd
vcom ../src/sim_sram.vhd  
vcom ../src/push_button_if.vhd 
-- vcom ../src/hdmi_gen.vhd 
vcom ../src/image_processor.vhd 
vcom ../src/image_processor_tb.vhd 


vsim image_processor_tb

add wave -group push_button image_processor_tb/uut/push_button/*
add wave -group controller image_processor_tb/uut/ctrl/*
add wave -group timing image_processor_tb/uut/timing/*
add wave -group data image_processor_tb/uut/data/*
add wave -group clock image_processor_tb/uut/clock/*
add wave -group enable_stabilizer image_processor_tb/uut/enable_stabilizer/*
add wave -group direction_stabilizer image_processor_tb/uut/direction_stabilizer/*
add wave -group rotation_stabilizer image_processor_tb/uut/rotation_stabilizer/*
add wave -group mode_stabilizer image_processor_tb/uut/mode_stabilizer/*


add wave -group image_processor image_processor_tb/uut/*
config wave -signalnamewidth 1
--restart -f

run 50ms