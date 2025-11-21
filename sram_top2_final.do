vlib work
vdel -all
vlib work

echo "Compiling Controllers..."
vlog -sv controller.v
vlog -sv power_management_unit.v
vlog -sv memory_bank_2.v 

echo "Compiling Top Level..."
vlog -sv sram_top2.v

echo "Compiling Top-Level Testbench..."
vlog -sv sram_top_tb.v

echo "Starting simulation..."
vsim work.sram_top_tb


run -all

echo "INFO: Simulation finished."
