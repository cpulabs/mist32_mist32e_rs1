set_global_assignment -entity "altera_asmi_rom" -library "lib_altera_asmi_rom" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "altera_asmi_rom" -library "lib_altera_asmi_rom" -name IP_TOOL_VERSION "15.1"
set_global_assignment -entity "altera_asmi_rom" -library "lib_altera_asmi_rom" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_altera_asmi_rom" -name SPD_FILE [file join $::quartus(sip_path) "../altera_asmi_rom.spd"]
set_global_assignment -library "lib_altera_asmi_rom" -name MISC_FILE [file join $::quartus(sip_path) "../../altera_asmi_rom.qsys"]

set_global_assignment -library "lib_altera_asmi_rom" -name MISC_FILE [file join $::quartus(sip_path) "altera_asmi_rom.v"]
set_global_assignment -library "lib_altera_asmi_rom" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_asmi_rom_asmi_parallel_0.v"]
