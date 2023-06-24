
if {[file exists sim/work]} {
    vdel -all
}
vlib work
vcom ../src/image_processor_pack.vhd
vcom ../src/timing_generator.vhd 
vcom ../src/timing_generator_tb.vhd 

vsim timing_generator_tb

add wave -group timing_generator_test timing_generator_tb/uut/*
config wave -signalnamewidth 1
--restart -f

run 100ms