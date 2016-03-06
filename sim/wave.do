onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb_mist32_mist32e_system/TARGET/MIST32E10FA/CORE/CORE_PIPELINE/EXECUTE/oBRANCH_ADDR
add wave -noupdate -radix hexadecimal /tb_mist32_mist32e_system/TARGET/MIST32E10FA/CORE/CORE_PIPELINE/EXECUTE/oJUMP_VALID
add wave -noupdate -radix hexadecimal /tb_mist32_mist32e_system/TARGET/MIST32E10FA/CORE/CORE_PIPELINE/EXECUTE/oNEXT_PC
add wave -noupdate /tb_mist32_mist32e_system/TARGET/MIST32E10FA/CORE/CORE_PIPELINE/EXECUTE/iPREV_SOURCE0
add wave -noupdate /tb_mist32_mist32e_system/TARGET/MIST32E10FA/CORE/CORE_PIPELINE/EXECUTE/iPREV_SOURCE1
add wave -noupdate -radix hexadecimal /tb_mist32_mist32e_system/TARGET/MIST32E10FA/CORE/CORE_PIPELINE/oDATA_REQ
add wave -noupdate -radix hexadecimal /tb_mist32_mist32e_system/TARGET/MIST32E10FA/CORE/CORE_PIPELINE/oDATA_RW
add wave -noupdate -radix hexadecimal /tb_mist32_mist32e_system/TARGET/MIST32E10FA/CORE/CORE_PIPELINE/oDATA_ADDR
add wave -noupdate -radix hexadecimal /tb_mist32_mist32e_system/TARGET/MIST32E10FA/CORE/CORE_PIPELINE/oDATA_DATA
add wave -noupdate -radix hexadecimal /tb_mist32_mist32e_system/TARGET/MIST32E10FA/CORE/CORE_PIPELINE/ALLOCATE/FRCR/b_counter
add wave -noupdate -radix hexadecimal /tb_mist32_mist32e_system/TARGET/MIST32E10FA/CORE/CORE_PIPELINE/ALLOCATE/FRCHR/b_data
add wave -noupdate -radix hexadecimal /tb_mist32_mist32e_system/TARGET/MIST32E10FA/CORE/CORE_PIPELINE/ALLOCATE/FRCLR/b_data
add wave -noupdate -radix hexadecimal /tb_mist32_mist32e_system/TARGET/MIST32E10FA/CORE/CORE_PIPELINE/EXECUTE/iPREV_VALID
add wave -noupdate -radix hexadecimal /tb_mist32_mist32e_system/TARGET/MIST32E10FA/CORE/CORE_PIPELINE/EXECUTE/iPREV_SOURCE0
add wave -noupdate -radix hexadecimal /tb_mist32_mist32e_system/TARGET/MIST32E10FA/CORE/CORE_PIPELINE/EXECUTE/iPREV_SOURCE1
add wave -noupdate -radix hexadecimal /tb_mist32_mist32e_system/TARGET/MIST32E10FA/CORE/CORE_PIPELINE/EXECUTE/iPREV_PC
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {781962 ps} 0} {{Cursor 2} {782776 ps} 0} {{Cursor 3} {782341 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {781737 ps} {783295 ps}
