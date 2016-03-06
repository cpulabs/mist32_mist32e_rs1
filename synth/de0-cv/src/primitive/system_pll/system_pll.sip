set_global_assignment -entity "system_pll" -library "lib_system_pll" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "system_pll" -library "lib_system_pll" -name IP_TOOL_VERSION "15.1"
set_global_assignment -entity "system_pll" -library "lib_system_pll" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_system_pll" -name SPD_FILE [file join $::quartus(sip_path) "system_pll.spd"]

set_global_assignment -library "lib_system_pll" -name MISC_FILE [file join $::quartus(sip_path) "system_pll_sim/system_pll.vo"]
