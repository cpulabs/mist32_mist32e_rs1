default:
	vlib work
	
	vlog -work work +incdir+../../mist32e10fa/src/include +incdir+../../mist32e10fa/src/core/include -sv tb/*.sv
	vlog -work work +incdir+../../mist32e10fa/src/include +incdir+../../mist32e10fa/src/core/include -sv model/sim_memory_model/*.sv
	vlog -work work +incdir+../../mist32e10fa/src/include +incdir+../../mist32e10fa/src/core/include -sv model/altera/*.v
	
	vlog -work work +incdir+../../mist32e10fa/src/include +incdir+../../mist32e10fa/src/core/include -sv ../src/*.sv
	vlog -work work +incdir+../../mist32e10fa/src/include +incdir+../../mist32e10fa/src/core/include -sv ../src/dev_interconnect/*.sv
	vlog -work work +incdir+../../mist32e10fa/src/include +incdir+../../mist32e10fa/src/core/include -sv ../src/device/keyboard/*.sv
	vlog -work work +incdir+../../mist32e10fa/src/include +incdir+../../mist32e10fa/src/core/include -sv ../src/device/vga/*.sv
	vlog -work work +incdir+../../mist32e10fa/src/include +incdir+../../mist32e10fa/src/core/include -sv ../src/memory_if/*.sv
	vlog -work work +incdir+../../mist32e10fa/src/include +incdir+../../mist32e10fa/src/core/include -sv ../src/rom/*.sv

	vlog -work work +incdir+../../mist32e10fa/src/include +incdir+../../mist32e10fa/src/core/include -sv ../../mist32e10fa/src/*.sv
	vlog -work work +incdir+../../mist32e10fa/src/include +incdir+../../mist32e10fa/src/core/include -sv ../../mist32e10fa/src/core/*.sv
	vlog -work work +incdir+../../mist32e10fa/src/include +incdir+../../mist32e10fa/src/core/include -sv ../../mist32e10fa/src/core/allocate/*.sv
	vlog -work work +incdir+../../mist32e10fa/src/include +incdir+../../mist32e10fa/src/core/include -sv ../../mist32e10fa/src/core/decode/*.sv
	vlog -work work +incdir+../../mist32e10fa/src/include +incdir+../../mist32e10fa/src/core/include -sv ../../mist32e10fa/src/core/execute/*.sv
	vlog -work work +incdir+../../mist32e10fa/src/include +incdir+../../mist32e10fa/src/core/include -sv ../../mist32e10fa/src/core/fetch/*.sv
	vlog -work work +incdir+../../mist32e10fa/src/include +incdir+../../mist32e10fa/src/core/include -sv ../../mist32e10fa/src/core/instruction_buffer/*.sv
	vlog -work work +incdir+../../mist32e10fa/src/include +incdir+../../mist32e10fa/src/core/include -sv ../../mist32e10fa/src/core/interrupt_control/*.sv
	vlog -work work +incdir+../../mist32e10fa/src/include +incdir+../../mist32e10fa/src/core/include -sv ../../mist32e10fa/src/core/l1_data/*.sv
	vlog -work work +incdir+../../mist32e10fa/src/include +incdir+../../mist32e10fa/src/core/include -sv ../../mist32e10fa/src/core/l1_inst/*.sv
	vlog -work work +incdir+../../mist32e10fa/src/include +incdir+../../mist32e10fa/src/core/include -sv ../../mist32e10fa/src/core/pipeline_control/*.sv
	vlog -work work +incdir+../../mist32e10fa/src/include +incdir+../../mist32e10fa/src/core/include -sv ../../mist32e10fa/src/lib/*.sv
	vlog -work work +incdir+../../mist32e10fa/src/include +incdir+../../mist32e10fa/src/core/include -sv ../../mist32e10fa/src/peripheral_interface_controller/*.sv
	vlog -work work +incdir+../../mist32e10fa/src/include +incdir+../../mist32e10fa/src/core/include -sv ../../mist32e10fa/src/primitive/altera_primitive_sync_fifo_showahead_32in_32out_8depth/*.v
	vlog -work work +incdir+../../mist32e10fa/src/include +incdir+../../mist32e10fa/src/core/include -sv ../../mist32e10fa/src/primitive/altera_primitive_sync_fifo_showahead_97in_97out_32depth/*.v
	vlog -work work +incdir+../../mist32e10fa/src/include +incdir+../../mist32e10fa/src/core/include -sv ../../mist32e10fa/src/primitive/ram_512bit_16word/*.v
	
	
	
	vsim -c -voptargs="+acc" tb_mist32_mist32e_system -do "radix -hexadecimal; log -r /*; run -all; finish"

