vlib work
vdel -all
vlib work

vlog memory_cell.v -sv
vlog row_decoder.v -sv
vlog precharge_ckt.v -sv
vlog coloumn_decoder_mux.v -sv
vlog write_driver_bank.v -sv
vlog sense_amplifier_bank.v -sv
vlog controller.v -sv
vlog power_management_unit.v -sv 
vlog memory_bank.v -sv 

vlog sram_top.v -sv  +acc
vlog sram_top_tb.v -sv +acc

vsim work.sram_top_tb

add wave -divider "SRAM Interface"
add wave sim:/sram_top_tb/clk
add wave sim:/sram_top_tb/rst_n
add wave sim:/sram_top_tb/ce_n_tb
add wave sim:/sram_top_tb/we_n_tb
add wave -radix hex sim:/sram_top_tb/addr_tb
add wave -radix hex sim:/sram_top_tb/din_tb
add wave -radix hex sim:/sram_top_tb/dout_tb

add wave -divider "Controller State"
add wave -radix symbolic sim:/sram_top_tb/DUT/u_controller/current_state

add wave -divider "PMU Status for Bank 10"
add wave {sim:/sram_top_tb/DUT/bank_active_status[10]}
add wave {sim:/sram_top_tb/DUT/bank_active_status[10]}

run -all

echo "INFO: Simulation finished."
